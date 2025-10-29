---
description: 保存当前工作进度
scripts:
  sh: ../../scripts/bash/save.sh
  ps1: ../../scripts/powershell/save.ps1
---

# /save - 进度保存系统 💾

> **核心理念**: 支持长流程的断点保存,用户可随时保存并稍后继续
> **目标**: 保存当前工作状态,下次可从中断处继续

---

## 第一步: 运行脚本检测当前状态 ⚠️ 必须执行

### 执行检查

```bash
# AI 操作: 运行脚本
bash scripts/bash/save.sh
# 或
pwsh scripts/powershell/save.ps1
```

### 解析返回结果

脚本会返回:
- `current_work`: 当前正在进行的工作(outline/characters/scene 等)
- `progress_info`: 进度信息(已完成哪些部分)
- `existing_files`: 已存在的工作文件列表
- `save_options`: 可保存的内容选项

根据检测结果展示保存界面。

---

## 第二步: 展示保存选项 ⚠️ 必须执行

### 情况 A: 有正在进行的工作

如果检测到 `current_work` 不为空(如: "outline"),显示详细保存界面:

```
╔══════════════════════════════════════════════════════════╗
║                   保存当前进度                              ║
╚══════════════════════════════════════════════════════════╝

📋 检测到正在进行的工作:

[从 progress_info 提取信息,例如:]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 大纲创作 (outline) - 进行中

已完成:
  ✅ 开场画面
  ✅ 激励事件
  ✅ 第一幕转折点

进行中:
  ⏳ B 故事线 (部分内容已填写)

待完成:
  ⬜ 娱乐时刻
  ⬜ 中点
  ... (还有 7 个节拍)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

保存选项:

  1. 💾 保存当前进度并退出
     保存已完成的部分,下次可以继续

  2. 📦 创建完整备份
     备份所有文件到 .scriptify/backups/

  3. ❌ 取消,继续工作

请选择 (1-3):
```

**⚠️ 强制等待机制**:
AI **必须停在这里,等待用户选择**。

### 情况 B: 没有正在进行的工作

如果 `current_work` 为空,显示一般保存界面:

```
╔══════════════════════════════════════════════════════════╗
║                   保存项目                                  ║
╚══════════════════════════════════════════════════════════╝

📋 当前项目状态:

[列出 existing_files 中的文件:]

已完成的文件:
  ✅ spec.json - 剧本规格
  ✅ idea.md - 故事创意
  ✅ outline.md - 故事大纲

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

保存选项:

  1. 📦 创建完整备份
     备份所有文件到 .scriptify/backups/

  2. ℹ️  查看项目信息
     显示项目详细状态

  3. ❌ 取消

请选择 (1-3):
```

**⚠️ 强制等待机制**:
等待用户选择。

---

## 第三步: 执行保存操作 ⚠️ 必须执行

根据用户选择执行相应操作。

### 选项 1: 保存当前进度

**执行步骤**:

1. **更新或创建 progress.json**

使用 Write 工具创建/更新 `.scriptify/progress.json`:

```json
{
  "last_command": "outline",
  "last_saved": "2025-10-29T12:30:00Z",
  "outline": {
    "status": "in_progress",
    "completed_beats": [
      "opening",
      "inciting",
      "act1turn"
    ],
    "current_beat": "bstory",
    "next_beat": "fun"
  },
  "idea": {
    "status": "completed"
  },
  "spec": {
    "status": "completed"
  },
  "characters": {
    "status": "not_started"
  },
  "scene": {
    "status": "not_started"
  }
}
```

2. **保存当前工作文件**

如果 `outline.md` 或其他工作文件有未保存内容,确保已写入文件。

3. **显示成功消息**

```
✅ 进度已保存!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 保存位置:
  • .scriptify/progress.json (进度记录)
  • outline.md (当前工作)

💡 下次继续:

  只需运行 /outline,系统会询问是否继续上次进度。

  或者随时运行其他命令:
    • /characters - 设计角色
    • /scene - 拆分场景
    • /spec - 修改规格

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

祝创作顺利! 👋
```

### 选项 2: 创建完整备份

**执行步骤**:

1. **生成备份文件名**

使用时间戳: `backup-20251029-123000`

2. **创建备份目录**

使用 Bash 工具:

```bash
mkdir -p .scriptify/backups/backup-20251029-123000
```

3. **复制所有项目文件**

```bash
# 复制主要文件
cp spec.json .scriptify/backups/backup-20251029-123000/ 2>/dev/null || true
cp idea.md .scriptify/backups/backup-20251029-123000/ 2>/dev/null || true
cp outline.md .scriptify/backups/backup-20251029-123000/ 2>/dev/null || true
cp characters.md .scriptify/backups/backup-20251029-123000/ 2>/dev/null || true
cp scenes/ .scriptify/backups/backup-20251029-123000/ -r 2>/dev/null || true

# 复制进度文件
cp .scriptify/progress.json .scriptify/backups/backup-20251029-123000/ 2>/dev/null || true
```

4. **创建备份清单**

在备份目录创建 `backup-info.json`:

```json
{
  "timestamp": "2025-10-29T12:30:00Z",
  "files": ["spec.json", "idea.md", "outline.md"],
  "description": "完整项目备份"
}
```

5. **显示成功消息**

```
✅ 备份已创建!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 备份位置:
  .scriptify/backups/backup-20251029-123000/

📋 备份内容:
  • spec.json
  • idea.md
  • outline.md
  • characters.md
  • progress.json

💡 恢复备份:

  如需恢复,手动复制备份文件回项目根目录即可。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 选项 3: 取消

简单显示:

```
操作已取消,继续工作吧! 💪
```

---

## 重要提醒 ⚠️

### 自动保存机制

某些命令(如 `/outline`)在完成每个节拍后,会**自动更新** `progress.json`,无需手动保存。

但用户仍可随时运行 `/save` 进行手动保存和备份。

### 进度文件格式

`.scriptify/progress.json` 记录:
- **completed_beats**: 已完成的节拍列表
- **current_beat**: 当前正在填写的节拍
- **next_beat**: 下一个待完成的节拍
- **status**: `not_started` / `in_progress` / `completed`

### 断点续传

当用户下次运行 `/outline` 时:
1. 脚本读取 `progress.json`
2. 如果发现 `status: "in_progress"`
3. AI 会询问: "检测到上次进度,是否继续?"
4. 用户选择继续,则跳过已完成的节拍,直接从 `next_beat` 开始

### 数据安全

- 每次保存都会更新 `progress.json`
- 建议定期创建完整备份(选项 2)
- 备份文件保留在 `.scriptify/backups/` 目录

---

**开始执行第一步** ⬇️
