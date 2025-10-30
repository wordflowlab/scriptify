# Scriptify 更新日志

所有重要更改都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [0.6.1] - 2025-10-30

### 🐛 Bug 修复

- ✅ 修复版本号显示问题
  - 从 package.json 动态读取版本号,而非硬编码
  - 使用 `createRequire` 支持 ES modules
  - `scriptify --version` 现在显示正确版本号

---

## [0.6.0] - 2025-10-30

### 🎯 聚焦核心功能

**Scriptify v0.6.0** - 简化产品边界,专注剧本创作!

### 🗑️ 移除功能

#### 删除未实现的命令
- ❌ **短剧优化命令** (6个)
  - `/hook-check` - Hook检测
  - `/explosion-density` - 爆点密度检测
  - `/platform-fit` - 平台适配度
  - `/viral-score` - 传播潜力评分
  - `/shorten` - 智能压缩
  - `/reality-check` - 现实度检测

- ❌ **质量评估命令** (5个)
  - `/review` - 质量评估
  - `/optimize` - 自动优化
  - `/diff` - 对比修改
  - `/compare` - 版本对比
  - `/export-review` - 导出评估报告

- ❌ **实用工具命令** (5个)
  - `/help`, `/settings`, `/templates`, `/examples`, `/undo`

### 📝 文档更新

- ✅ 重构文档结构
  - `docs/juben/` → `docs/scriptify/` (当前产品)
  - `docs/prd/` → `docs/roadmap/` (未来规划)
- ✅ 新增 `docs/ecosystem.md` 生态愿景文档
- ✅ 明确产品定位: 专注剧本创作,不涉及分镜制作
- ✅ 更新所有文档中的命令列表和示例
- ✅ 在 PRD-04/PRD-05 添加未实现功能标注

### 🎯 保留的核心功能

**20个核心命令**:
- 📋 项目管理 (5个): new, open, list, save, export
- ✍️ 原创剧本 (8个): spec, idea, outline, characters, scene, script, fill, polish
- 📚 小说改编 (7个): import, analyze, extract, compress, visualize, externalize, script

### 🔧 技术改进

- 删除 26 个未使用的文件 (模板+脚本)
- 简化代码库,减少 344 行代码
- 提升产品定位清晰度

### 💡 设计理念

**聚焦核心**: Scriptify 专注于剧本创作阶段,将短剧优化、质量评估等功能留给未来的独立工具或第三方工具集成。

---

## [0.1.0] - 2025-10-29

### 🎉 首次发布

**Scriptify v0.1.0** - AI驱动的剧本创作工具首个版本发布!

### ✨ 新增功能

#### 核心创作功能
- ✅ **原创剧本创作** - 完整8步创作流程
  - `/new` - 创建项目
  - `/spec` - 定义剧本规格
  - `/idea` - 故事构思
  - `/outline` - 故事大纲
  - `/characters` - 人物设定
  - `/scene` - 分场大纲
  - `/script` - 剧本生成(3种模式)
  - `/review` - 质量评估

- ✅ **三种创作模式**
  - Coach模式 - AI引导,用户创作100%
  - Express模式 - AI生成80-100%
  - Hybrid模式 - AI框架40-60% + 用户填充

- ✅ **小说改编剧本** - 7步改编工作流
  - `/import` - 导入小说并评估
  - `/analyze` - 结构分析
  - `/extract` - 提炼核心情节
  - `/compress` - 篇幅压缩
  - `/externalize` - 内心戏外化


#### 项目管理
- ✅ `/list` - 列出所有项目
- ✅ `/open` - 打开项目
- ✅ `/export` - 导出剧本(基础版)
- ✅ `help` - 帮助文档

### 🏗️ 架构设计

- ✅ **三层Slash Command架构**
  - Markdown模板层 - 定义标准和原则
  - AI执行层 - 灵活理解和执行
  - Bash脚本层 - 文件操作和JSON输出

- ✅ **代码实现**
  - TypeScript源码 (5个文件, ~800行)
  - Bash脚本 (19个文件, ~1200行)
  - 命令模板 (10个文件, ~3000行)

### 📚 文档系统

- ✅ **用户文档**
  - README.md - 项目总览
  - QUICKSTART.md - 5分钟快速入门
  - RESOURCES.md - 学习资源导航
  - STATUS.md - 项目当前状态

- ✅ **技术文档**
  - docs/FINAL_REPORT.md - 项目完成报告
  - docs/ACCEPTANCE_CHECKLIST.md - 验收清单
  - PROJECT_SUMMARY.md - 完整项目总结
  - IMPLEMENTATION_STATUS.md - 实施进度
  - CLAUDE.md - 开发指导原则

- ✅ **PRD文档** (docs/scriptify/ - 原docs/juben/)
  - PRD-01 产品定位与核心价值
  - PRD-02 三模式剧本创作系统
  - PRD-03 小说改编剧本工作流
  - PRD-04 短剧短视频剧本规范
  - PRD-05 剧本质量评估系统
  - PRD-06 完整创作流程与命令
  - 架构说明-Slash-Command设计

- ✅ **参考资料** (docs/info/)
  - 剧本格式快速参考.md - 日常速查
  - 短剧剧本写作完全指南.md - 系统教程
  - 短剧转动态漫SOP完整流程.md - 完整SOP
  - templates/ - 实用模板库

### 📊 统计数据

- **命令数量**: 21个
- **Bash脚本**: 19个
- **命令模板**: 10个
- **文档文件**: 20+个
- **总代码量**: ~10000行

### 🎯 核心特色

1. **遵循正确的架构原则** - 不是硬编码对话,而是灵活的AI引导系统
2. **三种模式真正有区别** - 完全不同的创作体验和交互方式
3. **完整的改编工作流** - 系统化的小说改编方法论
4. **实用的短剧优化** - 15种Hook公式,爆点密度行业标准

### ⏳ 已知限制

- Phase 7 (质量评估增强) 未完成
- Phase 8 (实用工具) 未完成
- 端到端测试覆盖不足
- 导出功能为基础版(未集成pandoc)

### 📋 后续计划

#### v0.2.0 (计划中)
- [ ] 完成Phase 7 - 质量评估增强
- [ ] 完成Phase 8 - 实用工具
- [ ] 补充端到端测试
- [ ] 优化导出功能

#### 未来版本
- [ ] Web UI版本
- [ ] 协作功能
- [ ] 多AI后端支持
- [ ] 模板市场

---

## 版本说明

### 语义化版本规则
- **主版本号** (MAJOR): 不兼容的API修改
- **次版本号** (MINOR): 向下兼容的功能性新增
- **修订号** (PATCH): 向下兼容的问题修正

### 变更类型
- `新增` - 新功能
- `变更` - 已有功能的变更
- `废弃` - 即将移除的功能
- `移除` - 已移除的功能
- `修复` - 问题修复
- `安全` - 安全相关修复

---

## 链接

- [项目仓库](https://github.com/wordflowlab/scriptify)
- [问题追踪](https://github.com/wordflowlab/scriptify/issues)
- [完整文档](./README.md)

---

**最后更新**: 2025-10-29
