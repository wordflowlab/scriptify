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

**重要**: 严格遵循 `docs/juben/架构说明-Slash-Command设计.md`

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
├── docs/juben/       # PRD文档
└── dist/             # 编译输出
```

## 开发流程

1. **参考PRD** - 查看对应的PRD文档
2. **创建模板** - 在`templates/commands/`创建.md
3. **实现脚本** - 在`scripts/bash/`创建.sh
4. **注册命令** - 在`src/cli.ts`注册
5. **测试** - 运行命令验证

## 禁止事项

- ❌ 在命令模板中硬编码对话流程
- ❌ 用TypeScript重复实现文件操作
- ❌ 忽略PRD文档自己设计
- ❌ 绕过Bash脚本直接操作文件

## 参考文档

- `docs/juben/架构说明-Slash-Command设计.md` - **必读!**
- `docs/juben/PRD-06-完整创作流程与命令.md` - 命令规范
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
