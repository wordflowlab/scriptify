# PRD-07: Scriptify 多平台命令生成

**版本**: v1.0
**日期**: 2025-10-29
**依赖**: 全部前置 PRD
**状态**: 草案

---

## 一、设计理念

### 1.1 为什么需要多平台支持?

**核心问题**: 不同 AI 工具的命令格式不同

| AI 工具 | 命令格式 | 配置目录 | 文件格式 |
|---------|---------|---------|---------|
| **Claude Code** | `/content.specify` | `.claude/commands/` | Markdown |
| **Cursor** | `/content.specify` | `.cursor/commands/` | Markdown |
| **Gemini CLI** | `/content:specify` | `.gemini/commands/` | Markdown |
| **Codex CLI** | `/content-specify` | `.codex/prompts/` | TOML |
| **Windsurf** | `/contentspecify` | `.windsurf/` | Markdown |

**解决方案**: 借鉴 **article-writer** 的多平台命令生成系统,**单一模板 → 13 个平台**。

---

## 二、支持的 AI 平台

### 2.1 平台列表 (13 个)

| # | AI 平台 | 命令格式 | 目录 | 格式 | 优先级 |
|---|---------|---------|------|------|-------|
| 1 | **Claude Code** | `/scriptify.命令` | `.claude/commands/` | Markdown | P0 |
| 2 | **Cursor** | `/scriptify.命令` | `.cursor/commands/` | Markdown | P0 |
| 3 | **Gemini CLI** | `/scriptify:命令` | `.gemini/commands/` | Markdown | P1 |
| 4 | **Windsurf** | `/scriptify命令` | `.windsurf/commands/` | Markdown | P1 |
| 5 | **Roo Code** | `/scriptify命令` | `.roo/commands/` | Markdown | P1 |
| 6 | **GitHub Copilot** | `/scriptify命令` | `.github/commands/` | Markdown | P2 |
| 7 | **Qwen Code** | `/scriptify命令` | `.qwen/commands/` | Markdown | P2 |
| 8 | **OpenCode** | `/scriptify命令` | `.opencode/commands/` | Markdown | P2 |
| 9 | **Codex CLI** | `/scriptify-命令` | `.codex/prompts/` | TOML | P2 |
| 10 | **Kilo Code** | `/scriptify命令` | `.kilocode/workflows/` | YAML | P2 |
| 11 | **Auggie CLI** | `/scriptify命令` | `.augment/commands/` | Markdown | P2 |
| 12 | **CodeBuddy** | `/scriptify命令` | `.codebuddy/commands/` | Markdown | P2 |
| 13 | **Amazon Q** | `/scriptify命令` | `.amazonq/commands/` | Markdown | P2 |

**优先级说明**:
- **P0**: 首发支持,深度测试
- **P1**: 第二批支持
- **P2**: 后续支持

---

## 三、命令模板系统

### 3.1 模板目录结构

```
templates/
├── commands/                       # 命令模板(Markdown)
│   ├── specify.md                  # 项目初始化
│   ├── story.md                    # 故事构思
│   ├── characters.md               # 角色设定
│   ├── scenes.md                   # 场景设定
│   ├── materials.md                # 素材搜索
│   ├── script.md                   # 编写剧本
│   ├── storyboard.md               # 生成分镜
│   ├── camera.md                   # 运镜优化
│   ├── review.md                   # 审校检查
│   └── export.md                   # 导出发布
│
├── brief-templates/                # Brief 模板
│   ├── comic.md                    # 漫画工作区 Brief
│   ├── short-video.md              # 短视频工作区 Brief
│   └── motion.md                   # 动态漫工作区 Brief
│
├── workspace-config.json           # 工作区配置规范
│
└── platform-config.json            # 平台配置
```

### 3.2 命令模板格式

#### 模板示例: `templates/commands/specify.md`

```markdown
---
description: 初始化 Scriptify 项目,配置工作区和创作模式
scripts:
  sh: scripts/bash/specify.sh
  ps1: scripts/powershell/specify.ps1
allowed-tools: Read, Write, Glob, Bash
argument-hint: [项目名称]
platforms:
  claude: /scriptify.specify
  cursor: /scriptify.specify
  gemini: /scriptify:specify
  codex: /scriptify-specify
---

# 命令: /scriptify.specify

## 功能说明

初始化 Scriptify 项目,引导用户完成以下配置:

1. 项目基本信息(名称、作者、类型)
2. 工作区选择(漫画/短视频/动态漫)
3. 创作模式选择(教练/快速/混合)
4. 篇幅规划

## 前置条件

- 当前目录下没有 Scriptify 项目
- 或用户明确要创建新项目

## 执行流程

### Step 1: 检查环境

检查当前目录是否已有 Scriptify 项目:
- 如果存在 `.scriptify/config.json`,询问是否覆盖
- 如果不存在,继续初始化

### Step 2: 收集项目信息

使用交互式问卷,收集以下信息:

**Q1: 项目名称?**
- 示例: 暗巷谜案, 职场小剧场, 都市修仙传
- 验证: 非空,合法文件名

**Q2: 选择工作区:**
```
1. 📱 漫画工作区 (快看/腾讯动漫)
2. 📹 短视频工作区 (抖音/快手/B站)
3. 🎬 动态漫工作区 (AE/剪映)
```

**Q3: 目标平台?**
- 根据工作区提供对应选项
- 漫画: 快看/腾讯/微博
- 短视频: 抖音/快手/B站
- 动态漫: AE/剪映/PR

**Q4: 创作模式:**
```
1. 🎓 教练模式 (完全原创,AI引导,3-4h)
2. ⚡ 快速模式 (AI生成,快速审校,30-60min)
3. 🔄 混合模式 (AI框架,用户补充,1.5-2h)
4. 稍后决定
```

**Q5: 预计篇幅?**
```
1. 短篇 (10-15 分镜)
2. 中篇 (20-30 分镜)
3. 长篇 (40+ 分镜)
```

### Step 3: 创建项目结构

根据收集的信息,创建以下目录和文件:

```
projects/{项目名称}/
├── .scriptify/
│   └── config.json                 # 项目配置
├── brief.md                        # 项目简介
├── materials/                      # 素材库(空)
│   ├── characters/
│   ├── scenes/
│   └── plot-templates/
└── README.md                       # 项目说明
```

### Step 4: 生成 Brief

根据模板生成 `brief.md`:

```markdown
# 项目简介: {项目名称}

**项目信息**:
- 项目名称: {项目名称}
- 创建日期: {日期}
- 作者: [待填写]

**工作区配置**:
- 工作区: {选择的工作区}
- 目标平台: {目标平台}
- 创作模式: {创作模式}

**篇幅规划**:
- 预计分镜数: {分镜数范围}
- 预计页数: {页数范围}(仅漫画工作区)
- 预计时长: {时长}(仅短视频/动态漫)

**待完成**:
- [ ] 故事大纲 (/story)
- [ ] 角色设定 (/characters)
- [ ] 场景设定 (/scenes)
- [ ] 剧本 (/script)
- [ ] 分镜脚本 (/storyboard)
```

### Step 5: 输出确认信息

```
✅ 项目创建成功!

📁 项目目录: projects/{项目名称}/
   ├── .scriptify/config.json
   ├── brief.md (已生成)
   └── materials/ (素材库)

💡 下一步: 使用 /scriptify.story 开始故事构思
```

## 参数说明

### 可选参数

- `--workspace <类型>`: 直接指定工作区
  - 选项: comic, short-video, motion
  - 示例: `/scriptify.specify --workspace comic`

- `--mode <模式>`: 直接指定创作模式
  - 选项: coach, express, hybrid
  - 示例: `/scriptify.specify --mode hybrid`

- `--project <名称>`: 直接指定项目名称
  - 示例: `/scriptify.specify --project "暗巷谜案"`

## 示例

### 示例 1: 完整交互流程

```
用户: /scriptify.specify

AI: === Scriptify 项目初始化 ===

Q1: 项目名称?
用户: 暗巷谜案

Q2: 选择工作区:
   1. 📱 漫画工作区
   2. 📹 短视频工作区
   3. 🎬 动态漫工作区
用户: 1

Q3: 目标平台?
   1. 快看漫画
   2. 腾讯动漫
   3. 微博动漫
用户: 1

Q4: 创作模式:
   1. 🎓 教练模式
   2. ⚡ 快速模式
   3. 🔄 混合模式
用户: 3

Q5: 预计篇幅?
   1. 短篇 (10-15 分镜)
   2. 中篇 (20-30 分镜)
   3. 长篇 (40+ 分镜)
用户: 2

AI: ✅ 项目创建成功!
📁 项目目录: projects/暗巷谜案/
💡 下一步: /scriptify.story
```

### 示例 2: 快速创建(带参数)

```
用户: /scriptify.specify --workspace comic --mode hybrid --project "职场小剧场"

AI: ✅ 项目"职场小剧场"创建成功!
    - 工作区: 📱 漫画工作区
    - 模式: 🔄 混合模式
💡 下一步: /scriptify.story
```

## 错误处理

1. **项目已存在**:
   ```
   ⚠️  项目"暗巷谜案"已存在
   是否覆盖?(Y/n)
   ```

2. **无效的工作区**:
   ```
   ❌ 无效的工作区类型: xxx
   有效选项: comic, short-video, motion
   ```

3. **权限问题**:
   ```
   ❌ 无法创建目录: 权限不足
   请检查文件系统权限
   ```

## 技术细节

### 配置文件格式 (.scriptify/config.json)

```json
{
  "version": "1.0",
  "projectName": "暗巷谜案",
  "workspace": "comic",
  "platform": "kuaikan",
  "mode": "hybrid",
  "scope": "medium",
  "createdAt": "2025-10-29T10:00:00Z",
  "lastModified": "2025-10-29T10:00:00Z"
}
```

## 相关命令

- `/scriptify.story` - 故事构思(下一步)
- `/scriptify.export` - 导出项目

## 备注

- 该命令可重复执行,重新初始化项目
- 建议在项目根目录执行
- Git 用户建议先 `git init`
```

---

## 四、命令生成流程

### 4.1 生成脚本架构

```
scripts/
├── build/
│   ├── generate-commands.sh        # 主生成脚本(Bash)
│   ├── generate-commands.ps1       # 主生成脚本(PowerShell)
│   ├── parsers/                    # 模板解析器
│   │   ├── markdown-parser.ts      # 解析 Markdown 模板
│   │   └── frontmatter-parser.ts   # 解析 YAML Frontmatter
│   └── generators/                 # 平台生成器
│       ├── claude-generator.ts     # Claude Code
│       ├── cursor-generator.ts     # Cursor
│       ├── gemini-generator.ts     # Gemini CLI
│       ├── codex-generator.ts      # Codex CLI (TOML)
│       └── kilo-generator.ts       # Kilo Code (YAML)
│
├── bash/                           # 辅助脚本(10个)
│   ├── specify.sh
│   ├── story.sh
│   ├── storyboard.sh
│   └── ...
│
└── powershell/                     # 辅助脚本(10个)
    ├── specify.ps1
    ├── story.ps1
    ├── storyboard.ps1
    └── ...
```

### 4.2 生成流程

```
[模板文件] templates/commands/specify.md
     ↓
【解析】FrontmatterParser
     ├─ 提取元数据 (description, scripts, allowed-tools)
     ├─ 提取平台配置 (platforms)
     └─ 提取 Markdown 正文
     ↓
【转换】PlatformGenerator
     ├─ Claude Code → .claude/commands/specify.md (Markdown)
     ├─ Cursor → .cursor/commands/specify.md (Markdown)
     ├─ Gemini CLI → .gemini/commands/specify.md (Markdown)
     ├─ Codex CLI → .codex/prompts/specify.toml (TOML)
     └─ Kilo Code → .kilocode/workflows/specify.yaml (YAML)
     ↓
【输出】13 个平台的命令文件
```

### 4.3 核心代码示例

```typescript
// scripts/build/generators/claude-generator.ts

interface Template {
  frontmatter: {
    description: string;
    scripts: { sh: string; ps1: string };
    allowedTools: string;
    platforms: Record<string, string>;
  };
  content: string;
}

class ClaudeGenerator {
  generate(template: Template): string {
    const commandName = template.frontmatter.platforms.claude;

    return `---
description: ${template.frontmatter.description}
allowed-tools: ${template.frontmatter.allowedTools}
---

${template.content}

## 辅助脚本

**Bash**: \`${template.frontmatter.scripts.sh}\`
**PowerShell**: \`${template.frontmatter.scripts.ps1}\`
`;
  }

  save(content: string, commandName: string): void {
    const path = `.claude/commands/${commandName}.md`;
    fs.writeFileSync(path, content, 'utf-8');
  }
}
```

```typescript
// scripts/build/generators/codex-generator.ts

class CodexGenerator {
  generate(template: Template): string {
    return `
[prompt]
name = "${template.frontmatter.platforms.codex}"
description = "${template.frontmatter.description}"

[prompt.config]
allowed_tools = "${template.frontmatter.allowedTools}"

[prompt.content]
text = """
${template.content}
"""

[prompt.scripts]
bash = "${template.frontmatter.scripts.sh}"
powershell = "${template.frontmatter.scripts.ps1}"
`;
  }

  save(content: string, commandName: string): void {
    const path = `.codex/prompts/${commandName}.toml`;
    fs.writeFileSync(path, content, 'utf-8');
  }
}
```

---

## 五、NPM 脚本集成

### 5.1 package.json 配置

```json
{
  "name": "scriptify",
  "version": "0.1.0",
  "scripts": {
    "build": "tsc && npm run postbuild",
    "postbuild": "chmod +x dist/cli.js",

    "build:commands": "npm run build:commands:bash && npm run build:commands:ps1",
    "build:commands:bash": "bash scripts/build/generate-commands.sh",
    "build:commands:ps1": "pwsh scripts/build/generate-commands.ps1",

    "prepare": "npm run build:commands && npm run build",

    "clean": "rm -rf dist/ .claude/ .cursor/ .gemini/ .codex/ .windsurf/ .roo/ .github/ .qwen/ .opencode/ .kilocode/ .augment/ .codebuddy/ .amazonq/",

    "dev": "tsx src/cli.ts",
    "watch": "tsc --watch"
  }
}
```

### 5.2 生成命令执行

```bash
# 开发阶段:手动生成命令
$ npm run build:commands

【输出】:
✅ 解析模板: specify.md
✅ 解析模板: story.md
✅ 解析模板: storyboard.md
... (10 个命令)

✅ 生成 Claude Code 命令: 10 个
✅ 生成 Cursor 命令: 10 个
✅ 生成 Gemini CLI 命令: 10 个
... (13 个平台)

🎉 总计生成: 130 个命令文件

# 发布前:自动生成
$ npm run prepare
(自动执行 build:commands + build)

# 发布
$ npm publish
```

---

## 六、平台差异化处理

### 6.1 Markdown 格式平台 (10 个)

**目标平台**: Claude Code, Cursor, Gemini CLI, Windsurf, Roo Code, GitHub Copilot, Qwen Code, OpenCode, Auggie CLI, CodeBuddy, Amazon Q

**格式特点**:
- Frontmatter: YAML
- 正文: Markdown
- 命令调用: 斜杠命令

**生成逻辑**:
1. 提取 Frontmatter 的 `description`, `allowed-tools`
2. 调整命令名称(如 `/scriptify.specify` → `/scriptify:specify`)
3. 保持 Markdown 正文不变

### 6.2 TOML 格式平台 (1 个)

**目标平台**: Codex CLI

**格式示例**:
```toml
[prompt]
name = "scriptify-specify"
description = "初始化 Scriptify 项目"

[prompt.config]
allowed_tools = "Read, Write, Glob, Bash"

[prompt.content]
text = """
# 命令: /scriptify-specify
...
"""
```

### 6.3 YAML 格式平台 (1 个)

**目标平台**: Kilo Code

**格式示例**:
```yaml
workflow:
  name: scriptify-specify
  description: 初始化 Scriptify 项目

  config:
    allowed_tools:
      - Read
      - Write
      - Glob
      - Bash

  steps:
    - name: 检查环境
      action: execute
      content: |
        # 命令: /scriptify-specify
        ...
```

---

## 七、命令列表

### 7.1 核心命令 (10 个)

| # | 命令 | 功能 | 阶段 |
|---|------|------|------|
| 1 | `/specify` | 项目初始化 | 准备 |
| 2 | `/story` | 故事构思 | 准备 |
| 3 | `/characters` | 角色设定 | 素材 |
| 4 | `/scenes` | 场景设定 | 素材 |
| 5 | `/materials` | 素材搜索 | 素材 |
| 6 | `/script` | 编写剧本 | 创作 |
| 7 | `/storyboard` | 生成分镜 | 创作 |
| 8 | `/camera` | 运镜优化 | 优化 |
| 9 | `/review` | 审校检查 | 优化 |
| 10 | `/export` | 导出发布 | 发布 |

### 7.2 辅助命令 (5 个,未来功能)

| # | 命令 | 功能 |
|---|------|------|
| 1 | `/fill` | 混合模式填写(PRD-02) |
| 2 | `/preview` | 预览分镜 |
| 3 | `/validate` | 验证完整性(PRD-06) |
| 4 | `/lint` | 规范性检查(PRD-06) |
| 5 | `/switch-workspace` | 切换工作区(PRD-03) |

---

## 八、测试与验证

### 8.1 单元测试

```typescript
// tests/generators/claude-generator.test.ts

describe('ClaudeGenerator', () => {
  it('should generate valid Markdown command', () => {
    const template = loadTemplate('specify.md');
    const generator = new ClaudeGenerator();
    const output = generator.generate(template);

    expect(output).toContain('---');
    expect(output).toContain('description:');
    expect(output).toContain('# 命令: /scriptify.specify');
  });

  it('should handle Chinese content correctly', () => {
    const template = loadTemplate('specify.md');
    const generator = new ClaudeGenerator();
    const output = generator.generate(template);

    expect(output).toContain('初始化');
    expect(output).toContain('工作区');
  });
});
```

### 8.2 集成测试

```bash
# 测试生成流程
$ npm run build:commands

# 验证输出
$ ls .claude/commands/
specify.md  story.md  storyboard.md  ...

# 测试命令可用性(在 Claude Code 中)
$ /scriptify.specify
(应正常执行)
```

---

## 九、文档与维护

### 9.1 平台兼容性文档

```markdown
# docs/platforms/README.md

## 支持的 AI 平台

| 平台 | 状态 | 测试日期 | 备注 |
|------|------|---------|------|
| Claude Code | ✅ 完全支持 | 2025-10-29 | - |
| Cursor | ✅ 完全支持 | 2025-10-29 | - |
| Gemini CLI | 🚧 测试中 | - | - |
| Codex CLI | ⏳ 计划中 | - | TOML 格式 |

## 已知问题

- Codex CLI: TOML 解析器可能不支持多行字符串
- Kilo Code: YAML 缩进必须为 2 空格

## 贡献指南

如需添加新平台支持,请:
1. 创建 `generators/{platform}-generator.ts`
2. 添加测试
3. 更新 `generate-commands.sh`
```

### 9.2 更新流程

**添加新命令**:
1. 创建 `templates/commands/new-command.md`
2. 运行 `npm run build:commands`
3. 测试所有平台

**添加新平台**:
1. 创建 `generators/new-platform-generator.ts`
2. 更新 `platform-config.json`
3. 更新生成脚本
4. 运行集成测试

---

## 十、总结

### 10.1 核心优势

1. **一次编写,多处运行**: 1 个模板 → 13 个平台
2. **自动化生成**: 无需手动维护多个文件
3. **格式统一**: 所有平台命令遵循相同规范
4. **易于扩展**: 新增平台只需添加生成器

### 10.2 技术栈

- **模板**: Markdown + YAML Frontmatter
- **生成**: TypeScript + Node.js
- **输出**: Markdown / TOML / YAML
- **测试**: Jest
- **CI/CD**: GitHub Actions

### 10.3 全部 PRD 完成!

- [x] **PRD-01**: 产品定位与核心价值
- [x] **PRD-02**: 三模式创作系统
- [x] **PRD-03**: 三工作区系统
- [x] **PRD-04**: 完整创作流程
- [x] **PRD-05**: 素材库系统
- [x] **PRD-06**: 分镜脚本规范
- [x] **PRD-07**: 多平台命令生成 (本文档)

---

**文档版本历史**:
- v1.0 (2025-10-29): 初始版本,定义多平台命令生成系统

**下一步**: 开始技术选型和架构设计,准备进入开发阶段
