# PRD-06: 完整创作流程与命令系统

**版本**: v2.0 (架构修正版)
**日期**: 2025-10-29
**依赖**: PRD-01~05, 架构说明-Slash-Command设计.md
**状态**: 修正版

---

## 重要说明

本文档基于 **article-writer 的 Slash Command 架构**设计。

**架构原则**:
- Markdown定义"标准和原则"(不是对话脚本)
- AI灵活执行(不是机械照本宣科)
- Bash脚本处理文件操作

**本文档描述**:
- 每个命令的检查标准和工作流程原则
- Bash脚本的输入输出格式
- 命令之间的协作关系

**本文档不包含**:
- ❌ 硬编码的对话示例
- ❌ 预设的问题列表
- ❌ 具体的反馈文本

详见: `架构说明-Slash-Command设计.md`

---

## 一、命令系统总览

### 1.1 命令分类

Scriptify 提供 **30+ 斜杠命令**,覆盖完整创作流程:

```
📋 项目管理 (5个)
  /new, /open, /list, /save, /export

✍️ 原创剧本 (8个)
  /spec, /idea, /outline, /characters, /scene, /script, /fill, /polish

📚 小说改编 (7个)
  /import, /analyze, /extract, /compress, /visualize, /externalize, /script

🎬 短剧优化 (5个)
  /hook-check, /explosion-density, /platform-fit, /viral-score, /shorten

🔍 质量评估 (5个)
  /review, /optimize, /diff, /compare, /export-review

🛠 实用工具 (5个)
  /help, /settings, /templates, /examples, /undo
```

### 1.2 创作流程

```
原创剧本流程:
/spec → /idea → /outline → /characters → /scene → /script → /review

小说改编流程:
/import → /analyze → /extract → /compress → /visualize → /externalize → /script → /review

短剧优化流程:
/script → /hook-check → /explosion-density → /platform-fit → /optimize
```

---

## 二、项目管理命令

### 2.1 `/new` - 创建项目

**模板**: `templates/commands/new.md`

```yaml
---
description: 创建新剧本项目
argument-hint: [项目名称]
allowed-tools: Write(//projects/*)
scripts:
  sh: scripts/bash/new.sh
---

# /new - 创建项目

## 功能

创建新的剧本创作项目,初始化项目结构。

## 检查标准

**项目名称**:
- ✅ 不包含特殊字符
- ✅ 长度在2-50字符
- ❌ 避免与已有项目重名

## 工作流程

1. 调用脚本创建项目目录
2. 初始化项目文件(spec.json, mode.json等)
3. 提示用户下一步操作

## 脚本接口

**输入**: 项目名称
**输出**:
```json
{
  "status": "success",
  "project_path": "/path/to/project",
  "project_name": "心理游戏",
  "created_files": [
    "spec.json",
    "mode.json",
    "README.md"
  ]
}
```
```

---

### 2.2 `/open` - 打开项目

**模板**: `templates/commands/open.md`

```yaml
---
description: 打开已有项目
argument-hint: [可选:项目名称]
allowed-tools: Read(//projects/*)
scripts:
  sh: scripts/bash/open.sh
---

# /open - 打开项目

## 功能

打开已有项目,加载项目上下文。

## 检查标准

- ✅ 项目存在
- ✅ 项目结构完整

## 工作流程

1. 如果未指定项目名,列出所有项目供选择
2. 调用脚本加载项目信息
3. 显示项目进度和建议下一步

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "project": {
    "name": "心理游戏",
    "path": "/path/to/project",
    "spec": { ... },
    "progress": {
      "idea": true,
      "outline": true,
      "characters": true,
      "scripts": [1, 2, 3]  // 已完成的集数
    }
  },
  "next_steps": ["/script --episode 4"]
}
```
```

---

### 2.3 `/export` - 导出剧本

**模板**: `templates/commands/export.md`

```yaml
---
description: 导出剧本到指定格式
argument-hint: [--format <格式>] [--episodes <集数>]
allowed-tools: Read(//projects/*/scripts/*), Write(//exports/*)
scripts:
  sh: scripts/bash/export.sh
---

# /export - 导出剧本

## 功能

将剧本导出为标准格式(Markdown/PDF/Final Draft)。

## 支持格式

- `markdown`: Markdown格式
- `pdf`: PDF标准剧本格式
- `fdx`: Final Draft格式
- `docx`: Word文档
- `notion`: Notion数据库

## 检查标准

**导出前检查**:
- ✅ 剧本文件存在
- ✅ 格式转换可用
- ⚠️ 提醒用户未完成的部分

## 脚本接口

**输入**: 格式类型, 集数范围
**输出**:
```json
{
  "status": "success",
  "exported_files": [
    "/exports/心理游戏-第01集.pdf",
    "/exports/心理游戏-第02集.pdf"
  ],
  "format": "pdf",
  "total_episodes": 2
}
```
```

---

## 三、原创剧本命令

### 3.1 `/spec` - 定义剧本规格

**模板**: `templates/commands/spec.md`

```yaml
---
description: 定义剧本的基本参数
argument-hint: [可选:--type --duration --genre]
allowed-tools: Write(//projects/*/spec.json)
scripts:
  sh: scripts/bash/spec.sh
---

# /spec - 定义剧本规格

## 功能

定义剧本的类型、时长、题材、目标受众等基本参数。

## 必需参数

**剧本类型**:
- 短视频(1-3分钟)
- 短剧(5-10分钟×N集)
- 长剧(40-60分钟×N集)
- 电影(90-120分钟)

**题材类型**:
- 悬疑推理 / 都市言情 / 职场励志 / 喜剧搞笑 / 古装历史 / 科幻未来 / 其他

**目标受众**:
- 年龄段(18-25 / 25-35 / 35-50 / 全年龄)
- 性别倾向(女性为主 / 男性为主 / 无倾向)

## 检查标准

- ✅ 类型与题材搭配合理
- ✅ 时长设定符合行业标准
- ⚠️ 提醒不同类型的创作难度

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "spec": {
    "type": "短剧",
    "duration": "10分钟",
    "episodes": 10,
    "genre": ["悬疑", "言情"],
    "audience": {
      "age": "25-35岁",
      "gender": "女性为主"
    }
  },
  "saved_to": "/path/to/spec.json"
}
```
```

---

### 3.2 `/idea` - 故事构思

**详细定义见 PRD-02 (教练模式)**

核心标准:
- 主角设定(职业/年龄/性格)
- 目标与障碍
- 性格缺陷
- 成长弧线

---

### 3.3 `/outline` - 故事大纲

**模板**: `templates/commands/outline.md`

```yaml
---
description: 构建剧本结构大纲
argument-hint: [可选:--structure <结构类型>]
allowed-tools: Read(//projects/*/idea.md), Write(//projects/*/outline.md)
scripts:
  sh: scripts/bash/outline.sh
---

# /outline - 故事大纲

## 功能

引导用户构建符合剧作理论的故事大纲。

## 支持的结构类型

- **三幕式** (默认,最常用)
- **英雄之旅** (12个阶段)
- **五幕式** (莎士比亚结构)
- **救猫咪** (Save the Cat, 15个节拍)

## 检查标准

**三幕式结构**:

第一幕(设定) - 占总时长25%:
- ✅ Hook在前3分钟(长剧)或前30秒(短剧)
- ✅ 主角的常态世界展示
- ✅ 激励事件(Inciting Incident)明确
- ✅ 第一幕转折点推动进入第二幕

第二幕(对抗) - 占总时长50%:
- ✅ 中点(Midpoint)有重大反转
- ✅ 障碍逐步升级
- ✅ 低谷时刻(All is Lost)足够绝望
- ✅ 第二幕转折点引发主角最终决定

第三幕(解决) - 占总时长25%:
- ✅ 高潮对决(Climax)紧张激烈
- ✅ 结局解答主要悬念
- ✅ 主角成长得到体现

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "outline": {
    "structure": "三幕式",
    "acts": [
      {
        "act": 1,
        "episodes": [1, 2, 3],
        "key_events": ["Hook", "激励事件", "第一幕转折"]
      },
      {
        "act": 2,
        "episodes": [4, 5, 6, 7, 8],
        "key_events": ["中点", "低谷", "第二幕转折"]
      },
      {
        "act": 3,
        "episodes": [9, 10],
        "key_events": ["高潮", "结局"]
      }
    ]
  }
}
```
```

---

### 3.4 `/characters` - 人物设定

**模板**: `templates/commands/characters.md`

```yaml
---
description: 详细设计人物设定
argument-hint: [可选:角色名]
allowed-tools: Read(//projects/*/idea.md), Write(//projects/*/characters.md)
scripts:
  sh: scripts/bash/characters.sh
---

# /characters - 人物设定

## 功能

引导用户设计立体的人物角色。

## 检查标准

**主角**:
- ✅ 基本信息(姓名/年龄/职业/外貌)
- ✅ 性格特征(优点+缺点)
- ✅ 动机(外在目标+内在需求)
- ✅ 冲突(外部+内部)
- ✅ 成长弧线(起点→转折→终点)
- ✅ 关键关系网
- ✅ 标志性元素(口头禅/习惯/视觉符号)

**反派**:
- ✅ 人性化动机(不是纯粹为恶而恶)
- ✅ 性格弱点(反派也有软肋)
- ⚠️ 可选:反派的成长弧线

**配角**:
- ✅ 明确的功能(推动剧情/衬托主角)
- ✅ 独特的性格特征
- ⚠️ 避免工具人化

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "characters": [
    {
      "name": "林悦",
      "role": "protagonist",
      "info": { ... },
      "arc": { ... }
    },
    {
      "name": "李教授",
      "role": "antagonist",
      "info": { ... }
    }
  ]
}
```
```

---

### 3.5 `/scene` - 分场大纲

**模板**: `templates/commands/scene.md`

```yaml
---
description: 将大纲拆分为具体场景序列
argument-hint: --episode <集数>
allowed-tools: Read(//projects/*/outline.md), Write(//projects/*/scenes/*.md)
scripts:
  sh: scripts/bash/scene.sh
---

# /scene - 分场大纲

## 功能

将故事大纲拆分为可执行的场景序列。

## 检查标准

**场景设计**:
- ✅ 每个场景有明确目标(推动剧情/展现人物/制造冲突)
- ✅ 场景时长合理(短剧30-60秒/场景)
- ✅ 场景间有逻辑连接
- ✅ 张力曲线起伏明显

**场景数量**:
- 短视频(1-3分钟): 3-6个场景
- 短剧(10分钟): 10-15个场景
- 长剧(45分钟): 30-50个场景

**爆点密度**:
- 短视频: 1个/15秒
- 短剧: 1个/30-40秒
- 长剧: 1个/60秒

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "episode": 1,
  "scenes": [
    {
      "number": 1,
      "location": "废弃仓库",
      "time": "夜晚",
      "duration": 30,
      "purpose": "Hook-闺蜜被害",
      "tension": 10
    },
    ...
  ],
  "total_duration": 600,
  "explosion_points": 15
}
```
```

---

### 3.6 `/script` - 剧本生成

**详细定义见 PRD-02 (三种模式)**

根据模式不同:
- 教练模式: 逐场引导用户写作
- 快速模式: AI生成完整初稿
- 混合模式: AI生成框架,用户填充

---

## 四、小说改编命令

### 4.1 `/import` - 导入小说

**模板**: `templates/commands/import.md`

```yaml
---
description: 导入小说文件进行改编
argument-hint: <小说文件路径>
allowed-tools: Read, Write(//projects/*/source.txt)
scripts:
  sh: scripts/bash/import.sh
---

# /import - 导入小说

## 功能

导入小说文件,进行初步分析。

## 支持格式

- .txt (纯文本)
- .epub (电子书)
- .pdf (需要OCR)

## 初步分析

导入后自动进行:
- 字数统计
- 章节识别
- 主要角色识别(基于出现频率)
- 预估改编集数

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "source_file": "/path/to/novel.txt",
  "word_count": 200000,
  "chapters": 120,
  "characters": [
    {"name": "林辰", "mentions": 1200},
    {"name": "苏婉", "mentions": 800}
  ],
  "recommended_episodes": 24
}
```
```

---

### 4.2 `/analyze` - 结构分析

**模板**: `templates/commands/analyze.md`

```yaml
---
description: 分析小说结构,识别主线支线
argument-hint: 无
allowed-tools: Read(//projects/*/source.txt)
scripts:
  sh: scripts/bash/analyze.sh
  py: scripts/python/novel_analysis.py
---

# /analyze - 结构分析

## 功能

使用NLP技术分析小说结构。

## 分析内容

**故事线识别**:
- 主线情节(权重70%)
- 重要支线(权重20%)
- 次要支线(权重10%)

**三幕结构映射**:
- 第一幕:起始章节范围
- 第二幕:对抗章节范围
- 第三幕:解决章节范围

**关键转折点**:
- 激励事件位置
- 中点位置
- 低谷位置
- 高潮位置

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "plot_lines": {
    "main": {
      "description": "复仇主线",
      "weight": 0.7,
      "chapters": [1, 2, 3, ...]
    },
    "sub": [
      {
        "description": "爱情支线",
        "weight": 0.2,
        "chapters": [5, 10, 15, ...]
      }
    ]
  },
  "three_acts": {
    "act1": {"chapters": [1, 30]},
    "act2": {"chapters": [31, 90]},
    "act3": {"chapters": [91, 120]}
  },
  "key_points": [
    {"type": "inciting_incident", "chapter": 15},
    {"type": "midpoint", "chapter": 70}
  ]
}
```
```

---

### 4.3 其他改编命令

**详细定义见 PRD-03**

- `/extract`: 提炼核心情节,分配到各集
- `/compress`: 删减次要内容,压缩篇幅
- `/visualize`: 文字描述转换为可拍摄场景
- `/externalize`: 内心戏外化处理

---

## 五、短剧优化命令

### 5.1 `/hook-check` - Hook检测

**模板**: `templates/commands/hook-check.md`

```yaml
---
description: 检测开场Hook强度
argument-hint: [--episode <集数>]
allowed-tools: Read(//projects/*/scripts/*.md)
scripts:
  sh: scripts/bash/hook-check.sh
  py: scripts/python/hook_analyzer.py
---

# /hook-check - Hook检测

## 功能

检测开场Hook的吸引力和留存率。

## 检查标准

**Hook类型**:
15种Hook公式(详见PRD-04):
1. 冲突开场
2. 悬念开场
3. 反常开场
4. 金句开场
5. 高潮前置
...

**Hook强度评分**:
- 视觉冲击力(0-10)
- 情感共鸣(0-10)
- 悬念设置(0-10)
- 节奏把握(0-10)

**时间要求**:
- 短视频: Hook必须在前3秒
- 短剧: Hook必须在前30秒
- 长剧: Hook必须在前3分钟

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "hook_position": 3,
  "hook_type": "冲突开场",
  "hook_strength": 9,
  "breakdown": {
    "visual_impact": 10,
    "emotional_resonance": 7,
    "suspense": 9,
    "pacing": 10
  },
  "estimated_retention": {
    "3s": 0.82,
    "30s": 0.68
  }
}
```
```

---

### 5.2 `/explosion-density` - 爆点密度检测

**模板**: `templates/commands/explosion-density.md`

```yaml
---
description: 检测爆点(转折/冲突)密度
argument-hint: --episode <集数>
allowed-tools: Read(//projects/*/scripts/*.md)
scripts:
  sh: scripts/bash/explosion-density.sh
  py: scripts/python/explosion_detector.py
---

# /explosion-density - 爆点密度检测

## 功能

自动检测剧本中的爆点,评估密度是否合理。

## 标准密度

- 短视频(1-3分钟): 1个/15秒
- 短剧(5-10分钟): 1个/30-40秒
- 长剧(40-60分钟): 1个/60秒

## 爆点定义

**强爆点**:
- 重大反转
- 激烈冲突
- 生死时刻
- 真相揭晓

**中爆点**:
- 情节转折
- 情感爆发
- 意外发现

**弱爆点**:
- 悬念设置
- 矛盾激化

## 检查标准

- ✅ 爆点分布均匀
- ✅ 强中弱爆点搭配合理
- ❌ 避免爆点空窗期(超过2分钟无爆点)
- ❌ 避免爆点过密(观众疲劳)

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "total_duration": 600,
  "explosion_points": [
    {"time": 3, "type": "strong", "description": "车祸"},
    {"time": 90, "type": "medium", "description": "发现线索"},
    ...
  ],
  "density": 1.5,
  "standard_density": 1.67,
  "warnings": [
    {"type": "gap", "start": 60, "end": 390, "message": "330秒无爆点"}
  ]
}
```
```

---

### 5.3 其他优化命令

**详细定义见 PRD-04**

- `/platform-fit`: 多平台适配度检测
- `/viral-score`: 传播潜力评分
- `/shorten`: 智能压缩时长

---

## 六、质量评估命令

### 6.1 `/review` - 质量评估

**详细定义见 PRD-05**

四维度评分:
1. 结构完整性(30%)
2. 人物立体度(25%)
3. 对话质量(25%)
4. 节奏控制(20%)

---

### 6.2 `/optimize` - 自动优化

**模板**: `templates/commands/optimize.md`

```yaml
---
description: 根据评估结果自动优化剧本
argument-hint: [--auto | --manual]
allowed-tools: Read(//projects/*/scripts/*.md), Write, Edit
scripts:
  sh: scripts/bash/optimize.sh
---

# /optimize - 自动优化

## 功能

根据 `/review` 的评估结果,自动或半自动优化剧本。

## 优化内容

**自动优化** (`--auto`):
- 去除"鼻音词"(直接说情绪)
- 简化过长台词
- 删减冗余对话
- 拆分过长场景

**手动优化** (`--manual`):
- AI提供优化建议
- 用户确认后执行
- 支持撤销

## 优化标准

- ✅ 保持原意
- ✅ 提升质量
- ❌ 不改变核心情节
- ❌ 不改变人物性格

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "optimizations": [
    {
      "type": "remove_on_the_nose",
      "scene": 3,
      "line": 15,
      "before": "我很愤怒!",
      "after": "(林辰砸碎杯子)"
    },
    ...
  ],
  "score_before": 79,
  "score_after": 87
}
```
```

---

## 七、Bash脚本接口规范

### 7.1 通用函数库

**`scripts/bash/common.sh`**:

```bash
#!/usr/bin/env bash

# 获取项目根目录
get_project_root() {
  # 实现...
}

# 获取当前项目
get_current_project() {
  # 实现...
}

# 中文字数统计(去除markdown标记)
count_chinese_words() {
  local file="$1"
  # 实现...
}

# 输出JSON
output_json() {
  local json="$1"
  echo "$json" | jq '.'
}

# 获取当前模式
get_mode() {
  # 读取 mode.json
}

# 错误处理
error_exit() {
  local message="$1"
  echo "❌ 错误: $message" >&2
  output_json "{\"status\": \"error\", \"message\": \"$message\"}"
  exit 1
}
```

### 7.2 脚本规范

所有脚本必须:

1. **输出JSON格式**
2. **包含status字段** (`success` | `error`)
3. **错误信息输出到stderr**
4. **成功信息可输出到stdout(供用户查看)**

示例:

```bash
#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

# 检查参数
if [ -z "$1" ]; then
    error_exit "缺少必需参数"
fi

# 执行逻辑
PROJECT_NAME="$1"
PROJECT_PATH="$(get_project_root)/projects/$PROJECT_NAME"

# 检查是否已存在
if [ -d "$PROJECT_PATH" ]; then
    error_exit "项目已存在: $PROJECT_NAME"
fi

# 创建项目
mkdir -p "$PROJECT_PATH"
echo "✅ 项目已创建: $PROJECT_PATH"

# 输出JSON
output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"project_path\": \"$PROJECT_PATH\"
}"
```

---

## 八、数据格式规范

### 8.1 项目结构

```
projects/
└── 心理游戏/
    ├── spec.json           # 剧本规格
    ├── mode.json           # 当前模式
    ├── idea.md             # 故事创意
    ├── outline.md          # 故事大纲
    ├── characters.md       # 人物设定
    ├── scenes/             # 分场大纲
    │   ├── episode-01.md
    │   └── episode-02.md
    ├── scripts/            # 完整剧本
    │   ├── episode-01.md
    │   └── episode-02.md
    ├── reviews/            # 评估报告
    │   └── episode-01-review.json
    └── source/             # 小说改编时的原始文件
        └── novel.txt
```

### 8.2 spec.json 格式

```json
{
  "type": "短剧",
  "duration": "10分钟",
  "episodes": 10,
  "genre": ["悬疑", "言情"],
  "audience": {
    "age": "25-35岁",
    "gender": "女性为主"
  },
  "created_at": "2025-10-29T10:00:00Z"
}
```

### 8.3 mode.json 格式

```json
{
  "current_mode": "教练",
  "history": [
    {
      "mode": "教练",
      "timestamp": "2025-10-29T10:00:00Z"
    }
  ]
}
```

---

## 九、多平台命令生成

### 9.1 `/generate-prompt` - 生成跨平台Prompt

**模板**: `templates/commands/generate-prompt.md`

```yaml
---
description: 将Scriptify命令转换为其他AI工具的Prompt
argument-hint: --command <命令> --platform <平台>
allowed-tools: Read(//templates/commands/*.md)
scripts:
  sh: scripts/bash/generate-prompt.sh
---

# /generate-prompt - 跨平台Prompt生成

## 功能

将Scriptify命令转换为其他AI工具可用的Prompt。

## 支持平台

1. ChatGPT (OpenAI)
2. Claude (Anthropic)
3. 文心一言 (百度)
4. 通义千问 (阿里)
5. 讯飞星火
6. 智谱AI (GLM)
7. Kimi (月之暗面)
8. 豆包 (字节)
9. 天工AI
10. 其他...

## 转换原则

- 保留检查标准和工作流程原则
- 转换为该平台的Prompt格式
- 说明如何使用生成的Prompt

## 脚本接口

**输出**:
```json
{
  "status": "success",
  "command": "/idea",
  "platform": "ChatGPT",
  "prompt": "你是一位专业的剧本创作教练...",
  "usage_instructions": "复制以上Prompt到ChatGPT..."
}
```
```

---

## 十、总结

### 10.1 核心原则

Scriptify命令系统基于三层架构:

| 层次 | 技术 | 职责 | 文件位置 |
|---|---|---|---|
| **指令层** | Markdown | 定义标准和原则 | `templates/commands/*.md` |
| **执行层** | AI | 理解+判断+灵活执行 | - |
| **工具层** | Bash | 文件操作+输出JSON | `scripts/bash/*.sh` |

### 10.2 验收标准

一个正确实现的命令应该:

- [ ] ✅ Markdown模板包含YAML frontmatter
- [ ] ✅ 定义检查标准(不是对话脚本)
- [ ] ✅ 说明工作流程原则(不是硬编码流程)
- [ ] ✅ Bash脚本输出标准JSON
- [ ] ✅ AI根据标准灵活执行
- [ ] ✅ 无TypeScript重复实现

### 10.3 开发路线图

**Phase 1: 核心命令** (1-2个月)
- 项目管理命令(new/open/save/export)
- 原创剧本核心流程(spec/idea/outline/script)
- Bash脚本基础库

**Phase 2: 改编与优化** (3-4个月)
- 小说改编命令(import/analyze/extract等)
- 质量评估命令(review/optimize)
- Python NLP分析脚本

**Phase 3: 高级功能** (5-6个月)
- 短剧优化命令(hook-check/explosion-density等)
- 多平台命令生成
- 模板库和示例库

---

**文档版本历史**:
- v1.0 (2025-10-29): 初始版本(包含大量硬编码对话示例)
- v2.0 (2025-10-29): 架构修正版(移除对话,改为标准和原则)

---

**参考文档**:
- `架构说明-Slash-Command设计.md`
- `other/article-writer/docs/slash-command-architecture.md`
- `other/article-writer/templates/commands/`
- `other/article-writer/scripts/bash/`
