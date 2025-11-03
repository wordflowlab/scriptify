# Claude Code Configuration

输出中文

# Scriptify Development Guidelines

## Philosophy

### Core Beliefs

- **Incremental progress** - 小步迭代,每次提交都能运行
- **Learning from PRD** - 严格遵循PRD文档中的架构设计
- **Slash Command架构** - 遵循三层架构:Markdown指令层 + AI执行层 + Bash脚本层
- **Clear intent** - 代码要清晰易懂

### Simplicity Means

- 单一职责
- 避免过度抽象
- 优先使用现有工具(Bash)而非重新实现(TypeScript)
- 如果需要解释,说明太复杂了

## Slash Command 架构原则

**重要**: 严格遵循 `docs/scriptify/架构说明-Slash-Command设计.md`

### 三层架构

```
Markdown指令层 (templates/commands/*.md)
  → 定义"做什么" (检查标准和原则)
  → 不是对话脚本!

AI执行层
  → 决定"怎么做" (灵活理解和执行)
  → 不是机械执行预设流程!

Bash脚本层 (scripts/bash/*.sh)
  → 执行"具体操作" (文件操作 + 输出JSON)
  → 不包含业务逻辑!
```

### 命令模板规范

**正确示例**:
```yaml
---
description: 引导用户构思剧本核心创意
scripts:
  sh: scripts/bash/idea.sh
---

# /idea - 故事构思引导

## 检查标准
用户的故事核心应该包含:
1. 清晰的主角(职业/年龄/性格)
2. 明确的目标
...

## 工作流程原则
1. 通过提问引导用户思考
2. 如果回答模糊,追问细节
...
```

**错误示例** (不要这样做!):
```markdown
❌ 【AI】: 让我们构思故事

❌ Q1: 你的主角是谁?
❌ > 用户输入...
```

### Bash脚本规范

所有脚本必须:
1. 输出JSON格式
2. 包含status字段 (`success` | `error`)
3. 使用`common.sh`中的通用函数
4. 错误输出到stderr

**示例**:
```bash
#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

# ... 执行逻辑 ...

# 输出JSON
output_json "{
  \"status\": \"success\",
  \"data\": { ... }
}"
```

## TypeScript代码规范

### 不要重复实现

**错误**:
```typescript
// ❌ 不要用TypeScript重新实现字数统计
function countWords(text: string): number { ... }
```

**正确**:
```typescript
// ✅ 调用Bash脚本
import { execSync } from 'child_process';
const result = execSync('bash scripts/bash/common.sh count_chinese_words file.md');
```

### CLI设计

- 使用`@commander-js/extra-typings`
- 命令注册要简洁
- 主要逻辑在Bash脚本中

## 项目结构

```
scriptify/
├── src/              # TypeScript源码(仅CLI入口和工具)
├── scripts/bash/     # Bash脚本(核心逻辑)
├── templates/        # 命令模板
│   └── commands/     # .md命令文件
├── projects/         # 用户项目(不提交到git)
├── docs/scriptify/   # 当前产品PRD文档
└── dist/             # 编译输出
```

## 开发流程

1. **参考PRD** - 查看对应的PRD文档
2. **创建模板** - 在`templates/commands/`创建.md
3. **实现脚本** - 在`scripts/bash/`创建.sh
4. **注册命令** - 在`src/cli.ts`注册
5. **测试** - 运行命令验证

## 交互设计规范 (v0.8.0新增)

### ABCDE选择模式

**核心原则**: AI应该**提供选项**而非等待用户从零输入

#### 基础规则

1. **A/B/C/D**: AI提供的具体方案(基于智能分析)
2. **E**: 永远是"自定义"选项
3. 每个选项必须包含:
   - 标签(简短描述)
   - 说明(详细解释)
   - 参考案例/示例
   - 适用场景
4. AI必须给出推荐(⭐标记)

#### 正确示例

```markdown
## 步骤1: 风格选择

🤖 AI分析: 检测到小说包含{features}

📋 推荐漫剧风格:

A. 🤪 沙雕搞笑 ⭐ 推荐
   特点: 夸张反差、密集笑点
   适合: 你的小说有{reason}
   参考: 《开局变成恐龙蛋》(2.1亿播放)

B. ⚡ 热血爽文
   特点: 燃点密集、打脸升级
   适合: {reason}
   参考: 《退婚后她惊艳全球》(3.5亿播放)

C. 💕 甜宠言情
   [...]

D. 🔍 悬疑推理
   [...]

E. 💭 自定义风格
   请描述你想要的风格...

👉 请选择 A/B/C/D/E:
```

**⚠️ 必须等待用户选择!**

#### 错误示例(禁止)

```markdown
❌ 你想要什么风格? [等待用户输入]
❌ 请输入漫剧风格: ___
❌ 只提供ABC三个选项(E必须存在)
❌ 选项没有说明和案例
```

### 渐进式澄清

**原则**: 先问大方向,再根据选择细化

#### 三层渐进结构

```
第1层: 大分类(原型/类型/风格)
  ↓ 用户选择A
第2层: 具体细化(职业/参数/设定)
  ↓ 用户选择B
第3层: 个性化(追问2-3个关键问题)
  ↓ 完成
```

#### 示例流程

```markdown
# 第1层: 选原型
A. 职场精英型
B. 普通人逆袭型
C. 学生成长型
D. 特殊身份型
E. 自定义

用户选A → 进入第2层

# 第2层: 细化职业(针对职场精英)
A. 律师
B. 医生
C. 广告策划师
D. 建筑师
E. 其他职业

用户选B → 进入第3层

# 第3层: 个性化
Q1: 性格特质? (A外冷内热 / B成长型 / C矛盾型 / D反差型 / E自定义)
Q2: 致命缺陷? (A性格 / B创伤 / C能力 / D道德 / E自定义)
Q3: 独特细节? (自由输入)

完成!
```

### AI智能分析

**原则**: AI先分析,再基于分析提供选项

#### 分析→推荐流程

```markdown
## 步骤0: AI智能分析

1. 读取相关信息(spec/小说/现有内容)
2. 提取关键特征
3. 应用推荐逻辑
4. 生成ABCDE选项(带推荐标记)

## 步骤1: 展示分析+选项

🤖 AI分析结果:
✓ 检测到题材: {detected}
✓ 核心元素: {elements}
✓ 推荐理由: {reason}

[展示ABCDE选项,标记推荐]
```

#### 禁止行为

- ❌ **不要**直接问开放式问题("你想要什么?")
- ❌ **不要**跳过分析直接展示选项
- ❌ **不要**给选项但不说明为什么推荐
- ❌ **不要**假设用户会自己选择(必须给推荐)

### 选项模板库

所有选项应该参考: `templates/option-templates/*.yaml`

- `comic-styles.yaml` - 漫剧风格
- `character-archetypes.yaml` - 人物原型
- `plot-structures.yaml` - 情节结构
- `genre-templates.yaml` - 题材模板

### 命令模板新结构

```markdown
---
description: XX命令 - AI智能分析+ABCDE选择
---

# /command - 命令名称(智能引导版)

## AI 角色
你是XX+智能助手,负责:
1. 智能分析
2. 提供选项
3. 渐进式澄清

## 核心交互原则
🎯 ABCDE选择模式
🔄 渐进式澄清
🤖 AI先分析再提问

## 工作流程

### 步骤0: 智能分析
[读取+分析+提取特征]

### 步骤1: XX选择(ABCDE)
[展示选项+推荐]
⚠️ 必须等待用户选择!

### 步骤2: 细化(ABCDE)
[根据第1步的选择,提供细化选项]

### 步骤3: 个性化(2-3个问题)
[追问关键细节]

## 核心原则总结
### ✅ 必须做到
### ❌ 禁止行为
```

## 禁止事项

- ❌ 在命令模板中硬编码对话流程
- ❌ 用TypeScript重复实现文件操作
- ❌ 忽略PRD文档自己设计
- ❌ 绕过Bash脚本直接操作文件
- ❌ **直接问开放式问题不提供选项** (v0.8.0)
- ❌ **跳过AI分析直接让用户选择** (v0.8.0)
- ❌ **选项没有E(自定义)** (v0.8.0)

## 参考文档

- `docs/scriptify/架构说明-Slash-Command设计.md` - **必读!**
- `docs/scriptify/PRD-06-完整创作流程与命令.md` - 命令规范
- `other/article-writer/` - 架构参考

## Quality Gates

### Definition of Done

- [ ] 命令模板符合架构规范(无硬编码对话)
- [ ] Bash脚本输出标准JSON
- [ ] TypeScript代码无重复实现
- [ ] 能通过`npm run build`编译
- [ ] 能成功运行命令

## Important Reminders

**ALWAYS**:
- 先读PRD文档再写代码
- 遵循三层架构
- Bash脚本输出JSON
- 保持代码简洁

**NEVER**:
- 硬编码对话流程
- TypeScript重复实现Bash能做的事
- 忽略架构文档
