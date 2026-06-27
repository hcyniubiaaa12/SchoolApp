#!/bin/bash
# 提交前验证脚本 — 检查 implement-by-blueprint 验收清单中的可自动化项
# 用法: bash .claude/skills/implement-by-blueprint/scripts/check-before-commit.sh

set -e
ROOT="D:/schoolApp"
ERRORS=0

echo "============================================"
echo " implement-by-blueprint 提交前验证"
echo "============================================"

# 1. 检查 main_pages.json 中是否注册了所有 @Entry 页面
echo ""
echo "[1/4] 检查 main_pages.json 页面注册..."
MAIN_PAGES="$ROOT/entry/src/main/resources/base/profile/main_pages.json"

# 查找 pages/ 下所有 .ets 文件
declare -A REGISTERED
while IFS= read -r line; do
    # 从 main_pages.json 提取 "src/..." 路径
    page=$(echo "$line" | grep -oP '"src/\K[^"]+' | sed 's|src/||' | sed 's|$|.ets|')
    if [ -n "$page" ]; then
        REGISTERED["$page"]=1
    fi
done < <(cat "$MAIN_PAGES")

# 扫描 pages/ 下的 @Entry 文件
while IFS= read -r file; do
    relpath="${file#$ROOT/}"
    if grep -q '@Entry' "$file" 2>/dev/null; then
        if [ -z "${REGISTERED[$relpath]}" ]; then
            echo "  ❌ 未注册: $relpath (含 @Entry 但不在 main_pages.json 中)"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done < <(find "$ROOT/entry/src/main/ets/pages" -name "*.ets" -type f)

# 也检查 common/components/ 下的 @Entry 文件（理论上不应有 @Entry）
while IFS= read -r file; do
    relpath="${file#$ROOT/}"
    if grep -q '@Entry' "$file" 2>/dev/null; then
        echo "  ⚠️  组件含 @Entry: $relpath (components 目录不应有 @Entry)"
    fi
done < <(find "$ROOT/entry/src/main/ets/common/components" -name "*.ets" -type f 2>/dev/null || true)

echo "  ✅ 页面注册检查完成"

# 2. 检查 ArkTS 禁止模式
echo ""
echo "[2/4] 检查常见 ArkTS 编译约束违规..."
VIOLATIONS=0

# 检查 ForEach 是否只传 2 个参数
while IFS= read -r file; do
    # 查找 ForEach(..., ...) 且不是 ForEach(..., ..., ...) 的形式
    # 即匹配 ForEach(XXXX, XXXX) 但没有第三个参数
    if grep -Pz 'ForEach\([^)]+\)' "$file" 2>/dev/null | grep -vP 'ForEach\([^)]+,[^)]+,[^)]+\)' > /dev/null; then
        # 更精确：找 ForEach 调用行，看有没有第三个参数
        matches=$(grep -n 'ForEach(' "$file" 2>/dev/null || true)
        echo "$matches" | while IFS= read -r line; do
            linenum=$(echo "$line" | cut -d: -f1)
            content=$(echo "$line" | cut -d: -f2-)
            # 数括号内的逗号数量来推断参数个数（粗略检查）
            inner="${content#ForEach(}"
            inner="${inner%)*}"
            commas=$(echo "$inner" | grep -o ',' | wc -l)
            if [ "$commas" -lt 2 ]; then
                echo "  ⚠️  $relpath:$linenum ForEach 可能缺少第三个参数(keyGenerator)"
                VIOLATIONS=$((VIOLATIONS + 1))
            fi
        done
    fi
done < <(find "$ROOT/entry/src/main/ets/pages" -name "*.ets" -type f)

if [ "$VIOLATIONS" -eq 0 ]; then
    echo "  ✅ 未发现明显 ArkTS 约束违规"
else
    echo "  ⚠️  发现 $VIOLATIONS 处潜在违规，请人工确认"
fi

# 3. 检查新建文件是否在蓝图中声明
echo ""
echo "[3/4] 检查蓝图文件一致性..."
BLUEPRINT="$ROOT/docs/重构与新增施工蓝图.md"
if [ -f "$BLUEPRINT" ]; then
    echo "  ✅ 蓝图文件存在"
else
    echo "  ❌ 蓝图文件缺失: $BLUEPRINT"
    ERRORS=$((ERRORS + 1))
fi

# 4. 检查项目关键文件完整性
echo ""
echo "[4/4] 检查关键文件完整性..."
KEY_FILES=(
    "$ROOT/CLAUDE.md"
    "$ROOT/.claude/rules/校园助手APP-开发规范与功能清单.md"
    "$ROOT/.claude/rules/项目现状与规范差距分析.md"
)
for f in "${KEY_FILES[@]}"; do
    if [ -f "$f" ]; then
        echo "  ✅ $(basename "$f")"
    else
        echo "  ❌ 缺失: $f"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "============================================"
if [ "$ERRORS" -gt 0 ]; then
    echo "  ❌ 发现 $ERRORS 个问题，请修复后提交"
    exit 1
else
    echo "  ✅ 全部检查通过，可以提交"
fi
echo "============================================"
