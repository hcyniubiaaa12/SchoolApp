# 参考文件

本目录存放 implement-by-blueprint skill 依赖或引用的参考文档索引。

## 核心文档（必读）

| 文档 | 路径 | 用途 |
|---|---|---|
| 开发规范与功能清单 | `.claude/rules/校园助手APP-开发规范与功能清单.md` | 产品需求、UI 规范、页面跳转关系 |
| 项目现状与规范差距分析 | `.claude/rules/项目现状与规范差距分析.md` | 当前代码与规范的差距、可复用能力、优先级 |
| 施工蓝图 | `docs/重构与新增施工蓝图.md` | 具体执行计划、文件清单、验收标准 |
| ArkTS 编译约束 | `CLAUDE.md` | 禁止语法、ForEach 规范、build() 合法语法 |

## 数据模型

模型定义在 `entry/src/main/ets/common/model/`，与 RDB 表结构一一对应：

| 模型文件 | 对应 DAO |
|---|---|
| `Course.ets` | `CourseDao.ets` |
| `Score.ets` | `ScoreDao.ets` |
| `Book.ets` | `BookDao.ets` |
| `LostFound.ets` | `LostFoundDao.ets` |
| `Food.ets` | `FoodDao.ets` |
| `Weather.ets` | `WeatherDao.ets` |
| `Todo.ets` | Preferences（轻量） |
| `Favorite.ets` | 收藏业务 |
| `Announcement.ets` | JSON 只读 |
| `News.ets` | JSON 只读 |
| `Music.ets` | JSON 只读 |
