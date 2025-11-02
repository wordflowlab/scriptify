# Scriptify - AI 驱动的剧本创作工具

> **版本**: v0.7.0
> **状态**: ✅ 核心功能已实现 + 🆕 漫剧创作支持
> **定位**: 专注剧本创作阶段的AI辅助工具

**核心价值**: 帮助创作者从零写好剧本,小说改编剧本,短剧/短视频剧本优化,**漫剧快速创作**

## ⚠️ 产品边界

**Scriptify 专注于剧本创作**,不涉及分镜、制作、拍摄等后期环节。

✅ **做什么**:
- 原创剧本创作 (教练/快速/混合模式)
- 小说改编剧本
- 剧本质量评估与优化
- 短剧/短视频剧本规范化

❌ **不做什么**:
- 分镜脚本设计
- 视觉资产生成
- 动态制作和剪辑
- 配音和视频渲染

💡 **如需完整制作流程**: 查看 [生态系统文档](./docs/ecosystem.md)

---

## 🎯 核心功能

### 1. 原创剧本创作
- **教练模式**: AI 引导你思考,100%原创
- **快速模式**: AI 生成初稿,快速迭代
- **混合模式**: AI 提供框架,你填充细节

### 2. 小说改编剧本
- 智能分析小说结构
- 自动提炼核心情节
- 内心戏外化转换
- 篇幅智能压缩

### 3. 漫剧创作 (🆕 v0.7.0)
- **选题检查**: 五大核心标准评估,0-100分量化评分
- **快速改编**: 5步改编法,1-2分钟黄金结构
- **质量保障**: 自动化检查6大维度,具体改进建议
- **专项润色**: 去AI味、补细节、强化钩子
- **4种风格**: 沙雕/热血/甜宠/悬疑

### 4. 短剧/短视频优化
- 标准剧本格式输出
- 专业术语规范化

---

## 📦 安装

```bash
npm install -g ai-scriptify
```

或本地开发:

```bash
git clone https://github.com/wordflowlab/scriptify.git
cd scriptify
npm install
npm run build
```

---

## 🚀 快速开始

### 1. 初始化剧本项目

```bash
# 交互式选择 AI 助手、剧本类型、脚本类型
scriptify init "我的第一部剧本"

cd "我的第一部剧本"
```

**支持13个AI编程助手**:
- Claude Code, Cursor, Gemini CLI
- Windsurf, Roo Code, GitHub Copilot
- Qwen Code, OpenCode, Codex CLI
- Kilo Code, Auggie CLI, CodeBuddy, Amazon Q Developer

### 2. 定义剧本规格

```bash
/spec
```

AI 引导你填写:
- 类型: 短剧/短视频/长剧/电影
- 时长: 10分钟×10集 或 90分钟
- 题材: 悬疑/言情/职场/古装等
- 受众: 年龄段和性别
- 目标平台: 抖音/快手/B站等

### 3. 开始创作

#### 原创剧本流程

**使用 Slash Commands 完成创作流程**:
```bash
/idea          # 1. 构思故事创意（主角、目标、冲突）
/outline       # 2. 构建故事大纲（三幕结构）
/characters    # 3. 设计人物角色
/scene         # 4. 规划场次大纲
/script        # 5. 编写完整剧本（教练/快速/混合模式）
/polish        # 6. 润色优化剧本
/visualize     # 7. 生成分镜脚本
```

**快速模式** (追求效率):
```bash
scriptify /idea --mode express
scriptify /script --mode express --episode 1
```

**混合模式** (平衡效率与原创):
```bash
scriptify /script --mode hybrid --episode 1
```

#### 🆕 漫剧创作流程 (快速上手)

```bash
# 1. 导入小说
scriptify /import
# AI会自动评估是否适合漫剧,并引导选择改编类型

# 2. 选题检查(五大核心标准)
scriptify /select-novel
# 输出: 0-100分评分 + 具体改进建议

# 3. 快速改编(假设评分≥70分)
scriptify /adapt-comic --style 沙雕 --episodes 100 --auto
# 或互动模式:
scriptify /adapt-comic --style 热血 --episodes 80

# 4. 质量检查
scriptify /quality-check-comic
# 或批量检查:
scriptify /quality-check-comic --all

# 5. 专项润色(可选)
scriptify /polish --focus comic --episode 1
```

**示例工作流**:
```
小说(15万字)
  → /import → 建议50-80集漫剧
  → /select-novel → 评分85分,适合沙雕风格
  → /adapt-comic --style 沙雕 --episodes 60 --auto
  → /quality-check-comic --all → 50集通过,10集需优化
  → /polish --focus comic [针对需优化的集]
  → 完成! 可交给 Storyboardify 制作分镜
```

### 4. 导出剧本

```bash
scriptify /export --format pdf   # 导出PDF标准剧本
```

---

## 📚 完整命令列表

### 项目管理 (5个)
- `/new` - 创建新项目
- `/open` - 打开项目
- `/list` - 列出所有项目
- `/save` - 保存项目
- `/export` - 导出剧本

### 原创剧本 (8个)
- `/spec` - 定义剧本规格
- `/idea` - 故事构思
- `/outline` - 故事大纲
- `/characters` - 人物设定
- `/scene` - 分场大纲
- `/script` - 剧本生成
- `/fill` - 填充混合模式框架
- `/polish` - 润色剧本

### 小说改编 (7个)
- `/import` - 导入小说(支持漫剧分析)
- `/analyze` - 结构分析
- `/extract` - 提炼情节
- `/compress` - 篇幅压缩
- `/visualize` - 视觉化转换
- `/externalize` - 内心戏外化
- `/script` - 生成剧本

### 漫剧创作 (🆕 3个)
- `/select-novel` - 漫剧选题检查(五大核心标准)
- `/adapt-comic` - 漫剧改编(5步改编法)
- `/quality-check-comic` - 漫剧质量检查(自动化评分)


---

## 🏗 架构设计

Scriptify 基于三层架构:

```
Markdown指令层 (templates/commands/*.md)
  → 定义检查标准和工作流程原则
  → 不包含硬编码对话

AI执行层
  → 灵活理解和执行
  → 根据上下文生成个性化反馈

Bash脚本层 (scripts/bash/*.sh)
  → 文件操作和项目管理
  → 输出JSON供AI使用
```

详见: `docs/scriptify/架构说明-Slash-Command设计.md`

---

## 📖 文档导航

### 🚀 快速开始
- **[QUICKSTART.md](./QUICKSTART.md)** - 5分钟快速入门 ⭐ 新手必读
- **[STATUS.md](./STATUS.md)** - 项目当前状态
- **[剧本格式快速参考](./docs/info/剧本格式快速参考.md)** - 日常创作速查 ⭐

### 📚 学习资源
- **[RESOURCES.md](./RESOURCES.md)** - 完整学习资源导航 ⭐ 推荐收藏
- **[短剧剧本写作完全指南](./docs/info/短剧剧本写作完全指南.md)** - 系统化教程
- **[短剧转动态漫SOP](./docs/info/短剧转动态漫SOP完整流程.md)** - 完整生产流程参考

### 🌐 生态系统
- **[生态系统文档](./docs/ecosystem.md)** - 从剧本到成片的完整生态 ⭐
- **[Scriptify产品文档](./docs/scriptify/)** - 当前产品PRD (v0.5.0)
- **[未来产品规划](./docs/roadmap/)** - Storyboardify等规划

### 🔧 技术文档
- **[架构说明](./docs/scriptify/架构说明-Slash-Command设计.md)** ⭐ 理解设计必读
- **[项目完成报告](./docs/FINAL_REPORT.md)** - v0.1.0完整总结
- **[验收清单](./docs/ACCEPTANCE_CHECKLIST.md)** - 功能验收
- [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) - 完整项目总结
- [IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md) - 实施进度
- [CLAUDE.md](./CLAUDE.md) - 开发指导原则
- [docs/README.md](./docs/README.md) - 文档导航中心

---

## 🛣 开发路线图

**Phase 1: MVP** (已完成 ✅)
- 核心命令实现
- 三模式系统
- 基础质量评估

**Phase 2: 改编功能** (进行中 🚧)
- 小说导入分析
- 改编工作流
- NLP增强

**Phase 3: 短剧优化** (规划中 📋)
- Hook公式库
- 爆点计算器
- 多平台适配

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request!

---

## 📄 License

MIT License

---

**版本**: v0.7.0
**发布日期**: 2025-11-02
**状态**: ✅ 核心功能完成 + 🆕 漫剧创作支持
**新增**: 漫剧选题检查、改编、质量检查、专项润色
