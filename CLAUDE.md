# CLAUDE.md

本文件是本项目的 Claude Code 全局开发规范。后续修改代码时必须优先遵循本文档，并结合 `.claude/rules/` 下的项目规则文档理解产品需求与差距。

## 项目定位

本项目是基于 HarmonyOS NEXT 的高校校园助手 APP，使用 ArkTS + ArkUI + Stage 模型开发。目标是实现首页、校园信息、学习助手、生活服务、我的五大模块，数据以本地存储为主，不接入后台服务器。

## 必读规则文档

以下文档定义了产品功能、样式权衡与当前差距，开发新功能或改动 UI 前应先对照：

- `.claude/rules/校园助手APP-开发规范与功能清单.md`：产品功能、样式、页面跳转、数据存储规范
- `.claude/rules/项目现状与规范差距分析.md`：当前代码与需求规范的差距、可复用能力、优先级建议

## 技术栈与 API 风格

- 使用 HarmonyOS NEXT、ArkTS、ArkUI、Stage 模型。
- 保持现有导入风格，优先使用 `@kit.*` API：
  - Ability：`@kit.AbilityKit`
  - 数据：`@kit.ArkData`
  - 后台任务：`@kit.BackgroundTasksKit`
  - 媒体：`@kit.MediaKit`
  - 通知/提醒：`@kit.NotificationKit`
- 项目中已有少量 `@ohos.*` 导入（如 `promptAction`、`router`、`relationalStore`），修改时可以继续沿用现有文件写法，不做无关迁移。
- 页面内状态使用 `@State`，页面结构使用 ArkUI 声明式组件。
- Ability 与页面之间的数据传递沿用现有方式：
  - Ability 间：`Want.parameters`
  - Ability 到页面：`AppStorage`
  - StartAbility 内页面切换：`eventHub + windowStage.loadContent`
  - 普通页面路由：`router.pushUrl` / `router.back`

## 代码风格

- 保持现有代码风格：ArkTS 类/结构体、方法命名、生命周期函数写法与周围代码一致。
- 页面文件使用 `@Entry` + `@Component` + `struct Xxx`。
- 私有方法使用 `private methodName(): type`。
- 状态变量统一放在组件顶部，使用 `@State` 标注。
- 注释使用中文，注释密度与现有文件保持一致；关键业务逻辑、跳转逻辑、存储逻辑需要写简短中文注释。
- 不做无关重构，不随意删除教学实验页（`DataStorageLab`、`BackgroundTaskLab`），除非明确要求。
- 避免把单个页面继续堆得过大。新模块应优先拆到独立页面或 `common/components`、`common/utils` 中。

## UI 与样式规范

- 当需求文档与现有代码冲突时，以 `.claude/rules/校园助手APP-开发规范与功能清单.md` 为准。
- 样式优先级：设计规范 > 现有硬编码样式 > 临时实现。
- 设计规范核心值：
  - 主色：`#1677FF`
  - 暖橙：`#FF7D00`
  - 清新绿：`#00B42A`
  - 背景：`#F5F7FA`
  - 文字主色：`#1D2129`
  - 文字辅色：`#86909C`
  - 边框色：`#E5E6EB`
  - 大标题 32sp / 中标题 28sp / 正文 26sp / 辅助文字 24sp
  - 圆角 8px，页面左右边距 20px，元素间距 16px，模块间距 24px
- 当前代码已全面使用 `$r('app.color.xxx')` 和 `$r('app.float.xxx')` 资源引用。新增代码应继续使用资源引用，不引入新的硬编码色值/字号。
- 卡片统一使用「签名设计」：`border({ width: { top: 3 }, color: $r('app.color.*') })` 顶部 3px 分类色条 + 6px 圆点标题。分类：蓝=学术/公告，橙=生活/失物，绿=完成/高分，灰=信息/设置。
- 符号图标优先使用 `SymbolGlyph($r('sys.symbol.*'))` 系统符号，无法映射时回退 emoji。

## 数据存储约定

- 本项目不接入后台服务器，业务数据以本地数据为主。
- 用户信息、首次启动、登录态、待办状态等轻量数据优先使用 Preferences。
- 主题模式、字体大小沿用现有 `KVStoreUtil`。
- 课程表、成绩、收藏、失物招领、美食、音乐、天气、资讯等模拟数据按需求使用本地 JSON 文件。
- 现有 RDB 学生表属于数据存储实验功能，不作为产品业务数据的默认方案。

## 页面与模块约定

目标主模块为五个底部 Tab：

1. 首页
2. 校园信息
3. 学习助手
4. 生活服务
5. 我的

子页面统一遵循：左上角返回箭头返回上一级，支持 HarmonyOS 原生侧滑返回。主页面使用 Tab 切换，子页面使用路由跳转。

## 注册验证码约定

注册功能采用本地演示方案：

- 用户输入手机号后点击「获取验证码」
- APP 在页面内生成并显示 6 位验证码
- 用户输入验证码后与本地生成值比对
- 不调用真实短信接口，不接入短信网关

## 图片资源约定

- 页面 UI 图片统一放在 `entry/src/main/resources/base/media`。
- AppScope 只保留应用级图标资源：`AppScope/resources/base/media/layered_image.json`、`background.png`、`foreground.png`，用于 `AppScope/app.json5` 的应用图标引用。
- `ic_code.png` 已由 SymbolGlyph(eye/eye_slash) 替换（Login/Regist 密码显隐按钮），不再使用此图片作为眼睛图标。
- `ic_book.png` 可复用于图书馆/学习资料入口。
- `ic_star.png` 可复用于美食评分。

## ArkTS 编译约束

ArkTS 是 TypeScript 的严格子集，新增代码必须遵守以下约束，否则编译报错：

### 禁止语法（会导致 ERROR）

| 违反行为 | 错误码 | ❌ 错误写法 | ✅ 正确写法 |
|---|---|---|---|
| **对象字面量作类型** | `arkts-no-obj-literals-as-types` | `Array<{name: string}>` | 先定义命名 `interface Item { name: string }`，再 `Item[]` |
| **builder 内声明变量** | `Only UI component syntax` | `const x = arr[i]` 写在 `build()` 里 | 抽为 `private getX(i:number)` 辅助方法 |
| **Object/any/unknown 类型** | `arkts-no-any-unknown` | `param: Object`、`val: any` | `param: Record<string, string>` 等具体类型 |
| **数组推断失败** | `arkts-no-noninferrable-arr-literals` | `[0,1,2]` 作 ForEach 源 | `[0,1,2] as number[]` |
| **未对应显式类型的对象字面量** | `arkts-no-untyped-obj-literals` | 数组内 `{a:1,b:2}` 无类型上下文 | 数组变量声明命名接口类型 |

### ForEach 必须补全 keyGenerator

`ForEach` 每次调用都必须传**三个参数**，第三个是 keyGenerator 回调：

```typescript
// ❌ 错 — 只传 2 个参数，缺少 key generator
ForEach(this.list, (item: ItemType, index: number) => { ... })

// ✅ 对 — 第三个参数返回唯一 key（字符串）
ForEach(this.list, (item: ItemType, index: number) => { ... },
        (item: ItemType, index: number) => item.name + index.toString())
```

### build() / @Builder 内的合法语法

在 `build()` 和 `@Builder` 方法体内，只允许写：
- ArkUI 组件声明（`Column`、`Row`、`Text`、`Image` 等）
- 控制流：`if / else`（条件渲染）、`ForEach` / `LazyForEach`
- 事件绑定：`.onClick(() => { 这里可以放逻辑 })`
- `@BuilderParam` / 其他 `@Builder` 引用

**不**允许出现：`const` / `let` 声明、函数调用（事件回调内除外）、`console.log`。

### 导入规范

- 删掉未被使用的 `import`，否则报 warning
- 优先使用 `@kit.*` API（`@kit.AbilityKit` / `@kit.ArkData` 等）
- `@ohos.*` 旧风格仅在现有文件中沿用，新文件尽量写 `@kit.*`

## 修改前后检查

每次改动后至少检查：

- 是否破坏 StartAbility → Login/Regist → MainAbility → Index 的主流程
- `main_pages.json` 是否注册了新增页面
- `module.json5` 中 Ability、权限、ExtensionAbility 配置是否仍匹配代码
- 新增资源是否放在正确的 resources 目录
- 样式是否尽量遵循设计规范
