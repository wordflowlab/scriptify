# PRD-05: 剧本质量评估系统

**版本**: v1.0
**日期**: 2025-10-29
**依赖**: PRD-01, PRD-02, PRD-03, PRD-04
**状态**: 草案

---

## 一、评估系统定位

### 1.1 核心价值

**"写完剧本立即知道质量,AI 给出专业优化建议"**

| 传统方式 | Scriptify 评估系统 |
|---------|------------------|
| 主观判断,无标准 | **四维度量化评分** |
| 需要专业编剧审阅 | **AI 自动评估** |
| 缺少改进建议 | **具体优化方案** |
| 评估周期长(数天) | **即时反馈(秒级)** |

### 1.2 适用场景

1. **原创剧本自查**: 写完后立即评估质量
2. **小说改编验证**: 检查改编是否成功
3. **短剧优化检测**: Hook/爆点/节奏是否达标
4. **版本迭代对比**: 对比修改前后的质量变化

---

## 二、四维度评估模型

### 2.1 评估维度总览

```
总分 = 结构完整性(30%) + 人物立体度(25%) + 对话质量(25%) + 节奏控制(20%)
```

| 维度 | 权重 | 核心指标 | 评分范围 |
|------|------|---------|---------|
| **结构完整性** | 30% | 三幕式/英雄之旅完整性 | 0-100 |
| **人物立体度** | 25% | 动机/冲突/成长弧线 | 0-100 |
| **对话质量** | 25% | 口语化/潜台词/推动剧情 | 0-100 |
| **节奏控制** | 20% | 张弛有度/爆点密度 | 0-100 |

**质量等级划分**:

```
90-100 分: ⭐⭐⭐⭐⭐ 优秀,可直接拍摄
75-89 分:  ⭐⭐⭐⭐   良好,小幅优化
60-74 分:  ⭐⭐⭐     及格,需要改进
40-59 分:  ⭐⭐       较差,重点修改
0-39 分:   ⭐         不合格,需重写
```

---

## 三、维度一: 结构完整性 (30%)

### 3.1 评估标准

#### 3.1.1 三幕式结构检测

```
【第一幕 - 设定】(占总时长 25%)
✓ 开场 Hook (前 3 秒/30 秒)
✓ 主角出场与性格展示
✓ 常态世界建立
✓ 激励事件 (Inciting Incident)
✓ 第一幕转折点

【第二幕 - 对抗】(占总时长 50%)
✓ 中点 (Midpoint) - 重大转折
✓ 障碍与冲突升级
✓ 低谷时刻 (All is Lost)
✓ 第二幕转折点

【第三幕 - 解决】(占总时长 25%)
✓ 高潮对决 (Climax)
✓ 结局 (Resolution)
✓ 新常态世界
```

#### 3.1.2 关键节点检测算法

```typescript
interface ScriptStructure {
  totalDuration: number; // 总时长(秒)
  acts: {
    act1: { start: number; end: number; events: Event[] };
    act2: { start: number; end: number; events: Event[] };
    act3: { start: number; end: number; events: Event[] };
  };
  keyPoints: {
    hook?: Event;              // Hook
    incitingIncident?: Event;  // 激励事件
    act1TurningPoint?: Event;  // 第一幕转折
    midpoint?: Event;          // 中点
    allIsLost?: Event;         // 低谷
    act2TurningPoint?: Event;  // 第二幕转折
    climax?: Event;            // 高潮
    resolution?: Event;        // 结局
  };
}

// 评分公式
function calculateStructureScore(structure: ScriptStructure): number {
  let score = 0;

  // 1. 三幕比例是否合理 (40分)
  const act1Ratio = structure.acts.act1.duration / structure.totalDuration;
  const act2Ratio = structure.acts.act2.duration / structure.totalDuration;
  const act3Ratio = structure.acts.act3.duration / structure.totalDuration;

  score += evaluateActRatio(act1Ratio, 0.25, 0.1) * 15; // 第一幕理想 25%,容忍±10%
  score += evaluateActRatio(act2Ratio, 0.50, 0.1) * 15; // 第二幕理想 50%,容忍±10%
  score += evaluateActRatio(act3Ratio, 0.25, 0.1) * 10; // 第三幕理想 25%,容忍±10%

  // 2. 关键节点是否存在 (60分)
  const keyPoints = structure.keyPoints;
  if (keyPoints.hook) score += 10;
  if (keyPoints.incitingIncident) score += 10;
  if (keyPoints.act1TurningPoint) score += 10;
  if (keyPoints.midpoint) score += 10;
  if (keyPoints.climax) score += 15;
  if (keyPoints.resolution) score += 5;

  return Math.min(score, 100);
}
```

### 3.2 评估示例

```bash
$ scriptify /review --dimension 结构

【AI 分析】: 正在评估结构完整性...

✅ 结构完整性评分: 82/100 (⭐⭐⭐⭐)

📊 详细分析:

【三幕式结构】
  ✓ 第一幕 (0:00-2:30, 25%) - 比例合理
  ✓ 第二幕 (2:30-7:30, 50%) - 比例合理
  ✓ 第三幕 (7:30-10:00, 25%) - 比例合理

【关键节点】
  ✓ Hook: 存在 (0:03 - 车祸场景,强吸引力)
  ✓ 激励事件: 存在 (1:20 - 父亲临终遗言)
  ✓ 第一幕转折: 存在 (2:30 - 发现画作线索)
  ✓ 中点: 存在 (5:00 - 苏婉身份暴露)
  ✗ 低谷时刻: 缺失 - 建议添加
  ✓ 第二幕转折: 存在 (7:30 - 林辰决定反击)
  ✓ 高潮: 存在 (8:45 - 终极对决)
  ✓ 结局: 存在 (9:40 - 复仇完成,情感选择)

❌ 问题:
  1. 缺少"低谷时刻"(All is Lost)
     - 位置: 应在第 6-7 分钟
     - 建议: 添加林辰被陷害/背叛的场景

💡 优化建议:
  在第 6:30 左右添加低谷场景:
  "林辰被诬陷,所有证据指向他,连苏婉也开始怀疑他"

  这会让第三幕的反击更有力量。
```

---

## 四、维度二: 人物立体度 (25%)

### 4.1 评估标准

#### 4.1.1 人物弧线要素

```
【核心要素】
1. 清晰的动机 (Motivation) - 角色想要什么?
2. 内在缺陷 (Flaw) - 角色的弱点是什么?
3. 外在冲突 (External Conflict) - 面对什么障碍?
4. 内在冲突 (Internal Conflict) - 内心的挣扎?
5. 成长与改变 (Arc) - 从 A 点到 B 点的转变
```

#### 4.1.2 评分算法

```typescript
interface Character {
  name: string;
  role: 'protagonist' | 'antagonist' | 'supporting';
  motivation?: string;        // 动机
  flaw?: string;              // 缺陷
  externalConflict?: string;  // 外在冲突
  internalConflict?: string;  // 内在冲突
  arc?: {
    startState: string;       // 起始状态
    endState: string;         // 结束状态
    turningPoints: Event[];   // 转变关键点
  };
  scenes: Scene[];            // 出场场景
  dialogues: Dialogue[];      // 对话
}

function calculateCharacterScore(characters: Character[]): number {
  let totalScore = 0;
  const protagonist = characters.find(c => c.role === 'protagonist');
  const antagonist = characters.find(c => c.role === 'antagonist');
  const supporting = characters.filter(c => c.role === 'supporting');

  // 1. 主角评分 (60分)
  if (protagonist) {
    let pScore = 0;
    if (protagonist.motivation) pScore += 15;
    if (protagonist.flaw) pScore += 10;
    if (protagonist.externalConflict) pScore += 10;
    if (protagonist.internalConflict) pScore += 10;
    if (protagonist.arc && protagonist.arc.turningPoints.length >= 3) pScore += 15;
    totalScore += pScore;
  }

  // 2. 反派评分 (20分)
  if (antagonist) {
    let aScore = 0;
    if (antagonist.motivation) aScore += 10; // 反派也要有动机
    if (antagonist.flaw) aScore += 5;        // 反派的弱点
    if (antagonist.arc) aScore += 5;         // 反派也可以有弧线
    totalScore += aScore;
  }

  // 3. 配角评分 (20分)
  if (supporting.length > 0) {
    const avgSupporting = supporting.reduce((sum, char) => {
      let sScore = 0;
      if (char.motivation) sScore += 5;
      if (char.dialogues.some(d => d.subtext)) sScore += 5; // 有潜台词
      return sum + sScore;
    }, 0) / supporting.length;
    totalScore += Math.min(avgSupporting * supporting.length, 20);
  }

  return Math.min(totalScore, 100);
}
```

### 4.2 评估示例

```bash
$ scriptify /review --dimension 人物

【AI 分析】: 正在评估人物立体度...

✅ 人物立体度评分: 78/100 (⭐⭐⭐⭐)

📊 主角分析: 林辰

【动机】✓ 清晰
  - 外在动机: 为父报仇,揭开真相
  - 内在动机: 寻找自我价值,证明自己

【性格缺陷】✓ 存在
  - 过于冲动,容易被情绪控制
  - 不信任他人,孤军奋战

【外在冲突】✓ 强烈
  - 与仇家的生死对抗
  - 与苏婉的立场冲突

【内在冲突】✓ 深刻
  - 复仇 vs 放下仇恨
  - 爱情 vs 使命

【成长弧线】✓ 完整
  - 起点: 冲动的复仇者,只有恨
  - 转折 1 (2:30): 发现复仇之路艰难
  - 转折 2 (5:00): 爱情与复仇的冲突
  - 转折 3 (8:00): 领悟到放下比报复更难
  - 终点: 成熟的选择,学会宽恕

---

📊 反派分析: 李峰

【动机】✓ 清晰
  - 保护自己的商业帝国
  - (但缺少更深层的人性动机)

【性格缺陷】✗ 缺失
  - 反派过于脸谱化,缺少弱点

【成长弧线】✗ 无

❌ 问题:
  反派李峰过于单薄,只是"坏人"标签

💡 优化建议:
  1. 给李峰添加人性化动机:
     "他也是为了保护女儿,才不择手段"

  2. 给李峰添加缺陷:
     "他对女儿的爱成为他的软肋"

  3. 添加反派的挣扎:
     "第 7 集,李峰犹豫是否要伤害林辰"

---

📊 配角分析:

✓ 苏婉: 动机清晰,有成长弧线 (8/10)
✓ 好友阿强: 功能性角色,但有幽默感 (6/10)
✗ 师父: 工具人,缺少个性 (3/10)

💡 建议删减师父角色,或给他更多戏份
```

---

## 五、维度三: 对话质量 (25%)

### 5.1 评估标准

#### 5.1.1 对话质量六要素

```
1. 口语化 (Naturalness) - 是否像真人说话?
2. 潜台词 (Subtext) - 是否有言外之意?
3. 推动剧情 (Plot-driving) - 是否推动故事前进?
4. 角色区分 (Character Voice) - 不同角色是否有不同说话风格?
5. 冲突张力 (Conflict) - 对话中是否有张力?
6. 简洁性 (Brevity) - 是否废话太多?
```

#### 5.1.2 对话检测算法

```typescript
interface Dialogue {
  character: string;
  text: string;
  scene: Scene;
  type: 'dialogue' | 'monologue' | 'narration';
  tags?: {
    hasSubtext?: boolean;      // 有潜台词
    plotDriving?: boolean;     // 推动剧情
    hasConflict?: boolean;     // 包含冲突
    tooLong?: boolean;         // 过长 (>50字)
    tooFormal?: boolean;       // 过于书面化
    cliche?: boolean;          // 陈词滥调
  };
}

function calculateDialogueScore(dialogues: Dialogue[]): number {
  let score = 0;
  const total = dialogues.length;

  // 1. 口语化检测 (20分)
  const naturalCount = dialogues.filter(d => !d.tags?.tooFormal).length;
  score += (naturalCount / total) * 20;

  // 2. 潜台词比例 (25分)
  const subtextCount = dialogues.filter(d => d.tags?.hasSubtext).length;
  const subtextRatio = subtextCount / total;
  // 理想: 30-50% 对话有潜台词
  score += evaluateRatio(subtextRatio, 0.4, 0.1) * 25;

  // 3. 推动剧情 (25分)
  const plotDrivingCount = dialogues.filter(d => d.tags?.plotDriving).length;
  score += (plotDrivingCount / total) * 25;

  // 4. 角色区分度 (15分)
  score += calculateCharacterVoiceDistinction(dialogues) * 15;

  // 5. 简洁性 (15分)
  const conciseCount = dialogues.filter(d => !d.tags?.tooLong).length;
  score += (conciseCount / total) * 15;

  return Math.min(score, 100);
}

// 角色声音区分度
function calculateCharacterVoiceDistinction(dialogues: Dialogue[]): number {
  // 使用 NLP 分析不同角色的语言特征差异
  const characterStyles = new Map<string, LanguageStyle>();

  dialogues.forEach(d => {
    if (!characterStyles.has(d.character)) {
      characterStyles.set(d.character, analyzeLanguageStyle(d));
    }
  });

  // 计算角色间语言风格差异
  // (简化示意,实际需要 NLP 模型)
  return 0.8; // 返回 0-1 的区分度分数
}
```

### 5.2 对话问题检测

```typescript
// 常见对话问题模式
const dialogueIssues = {
  // 1. 过于书面化
  tooFormal: [
    /因此|所以|然而|但是/g,
    /非常|十分|极其/g,
  ],

  // 2. 信息倾倒 (Info Dump)
  infoDump: (text: string) => {
    return text.length > 100 && !text.includes('?') && !text.includes('!');
  },

  // 3. 陈词滥调
  cliches: [
    '我不会让你失望的',
    '事情没那么简单',
    '你不懂',
    '算了,没什么',
  ],

  // 4. 鼻音词 (On-the-Nose) - 说得太直白
  onTheNose: [
    /我很(生气|高兴|难过|愤怒)/g,
    /你让我很(失望|开心)/g,
  ],
};
```

### 5.3 评估示例

```bash
$ scriptify /review --dimension 对话

【AI 分析】: 正在评估对话质量...

✅ 对话质量评分: 71/100 (⭐⭐⭐)

📊 详细分析:

【口语化】78/100
  ✓ 大部分对话自然
  ❌ 场景 5 中林辰的台词过于书面化:
     "因此我认为这件事情并非表面那么简单"
     💡 建议改为: "我觉得...没那么简单"

【潜台词】65/100
  ✓ 潜台词比例: 35% (理想 30-50%)
  ✓ 优秀示例 (场景 10):
     苏婉: "你还记得我们第一次见面吗?"
     林辰: "记得。雨很大。"
     苏婉: "是啊...雨很大..."
     → 表面说雨,实则说感情

  ❌ 鼻音词过多 (场景 3):
     林辰: "我很愤怒!"
     💡 建议改为动作: (林辰砸碎杯子)

【推动剧情】82/100
  ✓ 大部分对话推动剧情发展
  ❌ 场景 8 有 3 句闲聊,可删减

【角色区分度】68/100
  ✓ 林辰: 简短,直接 ✓
  ✓ 苏婉: 委婉,多问句 ✓
  ❌ 阿强: 说话风格与林辰过于相似
     💡 建议: 给阿强添加口头禅/方言

【简洁性】75/100
  ❌ 5 处对话过长 (>50字)

  示例 (场景 12):
  林辰: "我一直在想,如果当初我能早一点发现真相,
        也许父亲就不会死,也许一切都会不一样,但
        现在说这些还有什么用呢,我只能..."

  💡 建议拆分为 2-3 句,中间加入对方反应

---

🎯 核心问题:
  1. 鼻音词过多 - 情绪直说,缺少表演空间
  2. 角色声音不够区分
  3. 部分台词过长

💡 优化建议:
  1. 用动作/表情代替情绪台词
  2. 给每个角色设计语言特征
  3. 长台词拆分,增加互动
```

---

## 六、维度四: 节奏控制 (20%)

### 6.1 评估标准

#### 6.1.1 节奏评估要素

```
1. 张弛有度 - 高潮与舒缓的平衡
2. 爆点密度 - 关键转折的频率
3. 场景时长 - 单场景不宜过长
4. 信息密度 - 避免信息过载或过于空洞
```

#### 6.1.2 节奏检测算法

```typescript
interface Rhythm {
  totalDuration: number;
  scenes: Scene[];
  explosionPoints: Event[];  // 爆点
  tensionCurve: number[];    // 张力曲线 (0-10)
}

function calculateRhythmScore(rhythm: Rhythm): number {
  let score = 0;

  // 1. 爆点密度检测 (40分)
  const scriptType = detectScriptType(rhythm.totalDuration);
  let idealDensity: number;

  if (scriptType === '短视频') {
    idealDensity = rhythm.totalDuration / 15; // 15秒1个爆点
  } else if (scriptType === '短剧') {
    idealDensity = rhythm.totalDuration / 30; // 30秒1个爆点
  } else {
    idealDensity = rhythm.totalDuration / 60; // 60秒1个爆点
  }

  const actualDensity = rhythm.explosionPoints.length;
  const densityScore = 1 - Math.abs(actualDensity - idealDensity) / idealDensity;
  score += Math.max(densityScore, 0) * 40;

  // 2. 张弛有度 (30分)
  const tensionVariance = calculateVariance(rhythm.tensionCurve);
  // 理想: 张力有起伏,方差在 4-9 之间
  if (tensionVariance >= 4 && tensionVariance <= 9) {
    score += 30;
  } else {
    score += Math.max(0, 30 - Math.abs(tensionVariance - 6.5) * 5);
  }

  // 3. 场景时长分布 (30分)
  const avgSceneDuration = rhythm.totalDuration / rhythm.scenes.length;
  const longScenes = rhythm.scenes.filter(s => s.duration > avgSceneDuration * 2).length;

  // 短视频/短剧: 场景不宜过长
  if (scriptType === '短视频' || scriptType === '短剧') {
    score += Math.max(0, 30 - longScenes * 10);
  } else {
    score += 30; // 长剧本场景时长要求放宽
  }

  return Math.min(score, 100);
}
```

### 6.2 张力曲线可视化

```bash
$ scriptify /review --dimension 节奏 --visualize

【AI 分析】: 正在评估节奏控制...

✅ 节奏控制评分: 85/100 (⭐⭐⭐⭐)

📈 张力曲线图:

10 |                    ╱╲
 9 |                   ╱  ╲        ╱╲
 8 |           ╱╲     ╱    ╲      ╱  ╲
 7 |          ╱  ╲   ╱      ╲    ╱    ╲
 6 |    ╱╲   ╱    ╲ ╱        ╲  ╱      ╲
 5 |   ╱  ╲ ╱      ╳          ╲╱        ╲
 4 |  ╱    ╳      ╱ ╲                    ╲
 3 | ╱    ╱ ╲    ╱   ╲                    ╲
 2 |╱    ╱   ╲  ╱     ╲                    ╲
 1 |    ╱     ╲╱                            ╲
 0 +-----|-----|-----|-----|-----|-----|-----╲---
   0'   2'   4'   6'   8'  10'  12'  14'  16'  18'

   第一幕    第二幕 (上)  中点  第二幕(下)  第三幕

✓ 张力有明显起伏
✓ 中点 (5:00) 有高峰
✓ 低谷 (6:30) 后迅速反弹
✓ 高潮 (8:45) 达到峰值

---

📊 爆点分析:

爆点密度: 15 个爆点 / 10 分钟 = 1.5 个/分钟 ✓

爆点分布:
  第 1 集 (0-10'): 15 个爆点
    ✓ 0:03  - Hook: 车祸
    ✓ 1:20  - 激励事件: 临终遗言
    ✓ 2:30  - 发现画作
    ✓ 3:45  - 追踪线索
    ✓ 5:00  - 苏婉身份暴露 (大反转)
    ✓ 5:30  - 两人对峙
    ✓ 6:30  - 林辰被陷害 (低谷)
    ✓ 7:00  - 发现新证据
    ✓ 7:30  - 决定反击
    ✓ 8:00  - 潜入敌人基地
    ✓ 8:30  - 被发现
    ✓ 8:45  - 终极对决 (高潮)
    ✓ 9:00  - 真相揭晓
    ✓ 9:30  - 情感选择
    ✓ 9:50  - 结局

✓ 爆点密度符合短剧标准 (1个/30-40秒)

---

📊 场景时长分析:

总场景数: 18 个
平均时长: 33 秒/场景 ✓

场景时长分布:
  <20秒: 4 个场景 (22%)
  20-40秒: 10 个场景 (56%) ✓ 理想
  40-60秒: 3 个场景 (17%)
  >60秒: 1 个场景 (5%)

❌ 问题:
  场景 10 (林辰调查) 时长 85 秒,过长

💡 建议:
  拆分为 2 个场景,中间插入其他线索

---

🎯 核心优势:
  1. 张力曲线起伏明显,节奏紧凑
  2. 爆点密度适中,不会让观众疲劳
  3. 大部分场景时长控制良好

💡 优化建议:
  1. 拆分场景 10,避免单场景过长
  2. 在第 4-5 分钟增加一个小高潮
```

---

## 七、综合评估报告

### 7.1 综合评分

```bash
$ scriptify /review

【Scriptify AI】: 正在全面评估剧本质量...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  综合评分: 79/100 (⭐⭐⭐⭐)
  质量等级: 良好,需要小幅优化后可拍摄
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 分维度评分:

1. 结构完整性  82/100 (权重 30%) ████████░░
2. 人物立体度  78/100 (权重 25%) ███████░░░
3. 对话质量    71/100 (权重 25%) ███████░░░
4. 节奏控制    85/100 (权重 20%) ████████░░

---

🎯 核心优势:

✅ 结构完整,三幕式清晰
✅ 主角成长弧线完整,有深度
✅ 节奏紧凑,张力控制到位
✅ 爆点密度符合短剧标准

---

❌ 主要问题:

1. 对话质量偏低 (71分)
   - 鼻音词过多,情绪直说
   - 部分台词过于书面化
   - 角色声音区分度不够

2. 反派角色单薄
   - 缺少人性化动机
   - 过于脸谱化

3. 结构细节
   - 缺少"低谷时刻"(All is Lost)

---

💡 优化建议 (优先级排序):

🔴 高优先级 (必须修改):

1. 添加低谷场景 (6:30)
   位置: 第二幕末尾
   内容: 林辰被诬陷,所有证据指向他,连苏婉也开始怀疑

2. 优化对话 - 去除鼻音词
   场景 3: "我很愤怒!" → (林辰砸碎杯子)
   场景 5: "我很难过" → (林辰背过身,肩膀颤抖)

🟡 中优先级 (建议修改):

3. 丰富反派动机
   给李峰添加人性化背景:
   "他也是为了保护女儿,才不择手段"

4. 区分角色声音
   阿强: 添加口头禅/幽默感
   苏婉: 更多问句,委婉表达

🟢 低优先级 (可选优化):

5. 拆分场景 10 (时长过长)
6. 删减场景 8 的闲聊对白

---

📈 预期提升:

完成高优先级修改后,预计综合得分: 85-88/100 (⭐⭐⭐⭐)
完成所有修改后,预计综合得分: 90+/100 (⭐⭐⭐⭐⭐)

---

🛠 快捷操作:

$ scriptify /optimize --auto     # AI 自动优化
$ scriptify /optimize --manual   # 手动修改 + AI 建议
$ scriptify /export --with-notes # 导出剧本 + 修改建议
```

---

## 八、特殊类型评估

### 8.1 短视频剧本评估

```typescript
// 短视频额外评估维度
interface ShortVideoMetrics {
  hookStrength: number;      // Hook 强度 (0-10)
  hookTime: number;          // Hook 出现时间 (秒)
  retentionRate: number;     // 预估留存率
  viralPotential: number;    // 传播潜力
  platformFit: {
    douyin: number;          // 抖音适配度
    kuaishou: number;        // 快手适配度
    bilibili: number;        // B站适配度
  };
}

function evaluateShortVideo(script: Script): ShortVideoMetrics {
  return {
    hookStrength: evaluateHook(script.scenes[0]),
    hookTime: findHookTime(script),
    retentionRate: predictRetention(script),
    viralPotential: calculateViralScore(script),
    platformFit: {
      douyin: evaluatePlatformFit(script, 'douyin'),
      kuaishou: evaluatePlatformFit(script, 'kuaishou'),
      bilibili: evaluatePlatformFit(script, 'bilibili'),
    },
  };
}
```

**短视频专项报告**:

```bash
$ scriptify /review --type 短视频

【短视频专项评估】

📱 平台适配度:

抖音: ████████░░ 85/100
  ✓ Hook 强度高
  ✓ 节奏快
  ❌ 时长偏长 (建议压缩到 90 秒)

快手: ███████░░░ 72/100
  ✓ 剧情完整
  ❌ 缺少接地气元素

B站: ██████░░░░ 65/100
  ✓ 故事性强
  ❌ 缺少弹幕互动点

---

🎣 Hook 分析:

Hook 强度: 9/10 (优秀)
Hook 时间: 3 秒 ✓
Hook 类型: 冲突开场 (车祸场景)

预估 3 秒留存率: 78%
预估完播率: 45%

💡 建议:
  在 0:30 和 1:00 增加留存点 (悬念/反转)

---

📈 传播潜力: 7.5/10

传播要素分析:
  ✓ 情感共鸣: 8/10 (复仇主题)
  ✓ 反转惊喜: 9/10 (身份暴露)
  ✓ 金句潜力: 6/10 (缺少)
  ❌ 争议话题: 3/10 (较弱)

💡 建议添加金句:
  "有些仇,不是为了报,而是为了放下"
```

### 8.2 小说改编评估

```bash
$ scriptify /review --type 改编 --source novel.txt

【小说改编专项评估】

📚 改编质量: 82/100 (⭐⭐⭐⭐)

📊 核心情节保留度: 92/100 ✓
  主线情节: 100% 保留 ✓
  重要支线: 80% 保留 ✓
  删减支线: 2 条 (合理)

📊 人物一致性: 88/100 ✓
  主角林辰: 95% 一致 ✓
  反派李峰: 85% 一致 ✓
  苏婉: 80% 一致
    ❌ 小说中苏婉更主动,剧本中较被动

📊 视觉化转换: 85/100
  ✓ 大部分内心戏已外化
  ❌ 第 7 集仍有 2 处纯内心独白

📊 节奏优化: 90/100 ✓
  小说节奏: 舒缓
  剧本节奏: 紧凑 ✓
  转折点密度: 提升 300% ✓

---

🔍 与原著对比:

【保留的精华】
  ✓ 画作线索 (核心悬念)
  ✓ 苏婉身份反转
  ✓ 父子情感线

【合理删减】
  ✓ 商战支线 (与主线关联弱)
  ✓ 师徒线索 (功能性角色)

【改动】
  ⚠ 结局从"复仇成功"改为"选择宽恕"
    → 更符合主流价值观,建议保留

---

💡 改编建议:

1. 恢复苏婉的主动性
   小说: 苏婉主动接近林辰
   剧本: 苏婉被动等待
   → 建议恢复原设定

2. 处理剩余内心戏
   第 7 集场景 5: 用闪回代替独白
```

---

## 九、自动优化功能

### 9.1 一键优化

```bash
$ scriptify /optimize --auto

【AI】: 开始自动优化...

✅ 已修复 12 处问题:

1. 对话优化 (8 处)
   ✓ 场景 3: 删除鼻音词,改为动作
   ✓ 场景 5: 简化书面化台词
   ✓ 场景 8: 删减 3 句闲聊
   ✓ ...

2. 结构优化 (2 处)
   ✓ 添加低谷场景 (6:30)
   ✓ 拆分场景 10 为 2 个场景

3. 人物优化 (2 处)
   ✓ 给李峰添加人性化动机
   ✓ 区分阿强说话风格

---

📈 优化前后对比:

               优化前    优化后    提升
综合得分        79      →  87    +10%
结构完整性      82      →  90    +10%
人物立体度      78      →  82    +5%
对话质量        71      →  85    +20%
节奏控制        85      →  88    +4%

---

✅ 优化完成! 使用 /diff 查看修改详情
```

### 9.2 对比模式

```bash
$ scriptify /diff --scene 3

【场景 3 对比】

━━━━━━━━━━━ 修改前 ━━━━━━━━━━━

林辰
(愤怒)
我很愤怒! 他们怎么能这样对我父亲!

苏婉
(安慰)
我理解你的心情,但你要冷静。

━━━━━━━━━━━ 修改后 ━━━━━━━━━━━

林辰紧握拳头,青筋暴起。
他猛地站起,踢翻椅子。

苏婉
(轻声)
林辰...

林辰背对着她,肩膀颤抖。

━━━━━━━━━━━━━━━━━━━━━━━━

💡 改动说明:
  - 删除鼻音词"我很愤怒"
  - 用动作展现情绪
  - 苏婉台词更简洁,更有潜台词

对话质量: 6/10 → 9/10
```

---

## 十、导出与分享

### 10.1 导出评估报告

```bash
$ scriptify /export-review --format pdf

✅ 评估报告已导出:
  📄 reports/剧本质量评估报告-2025-10-29.pdf

包含内容:
  - 综合评分与分析
  - 四维度详细报告
  - 优化建议清单
  - 修改前后对比
  - 附录: 完整剧本标注版
```

### 10.2 版本对比

```bash
$ scriptify /compare v1.0 v2.0

【版本对比】

版本 v1.0 (2025-10-25):
  综合得分: 79/100

版本 v2.0 (2025-10-29):
  综合得分: 87/100

━━━━━━━━━━━━━━━━━━━━━━━━

提升明细:
  结构完整性: 82 → 90 (+10%)
  人物立体度: 78 → 82 (+5%)
  对话质量:   71 → 85 (+20%) ⬆ 最大提升
  节奏控制:   85 → 88 (+4%)

主要改动:
  ✓ 添加低谷场景
  ✓ 优化 8 处对话
  ✓ 丰富反派动机
  ✓ 拆分过长场景

💡 v2.0 已达到可拍摄标准
```

---

## 十一、技术实现

### 11.1 核心技术栈

```typescript
// 1. NLP 分析
import * as natural from 'natural';
import { Anthropic } from '@anthropic-ai/sdk';

// 2. 剧本解析
interface ScriptParser {
  parseScript(content: string): Script;
  extractScenes(script: Script): Scene[];
  extractDialogues(script: Script): Dialogue[];
  extractCharacters(script: Script): Character[];
}

// 3. 质量评估引擎
class QualityAssessmentEngine {
  async assess(script: Script): Promise<AssessmentReport> {
    const [structure, character, dialogue, rhythm] = await Promise.all([
      this.assessStructure(script),
      this.assessCharacter(script),
      this.assessDialogue(script),
      this.assessRhythm(script),
    ]);

    return this.generateReport({ structure, character, dialogue, rhythm });
  }

  private async assessStructure(script: Script): Promise<StructureScore> {
    // 使用 Claude API 分析结构
    const analysis = await this.claude.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 4096,
      messages: [{
        role: 'user',
        content: `分析以下剧本的结构完整性:\n${script.content}`,
      }],
    });

    return this.parseStructureAnalysis(analysis);
  }
}
```

### 11.2 评估数据持久化

```typescript
// SQLite 存储评估历史
interface AssessmentHistory {
  id: string;
  scriptId: string;
  version: string;
  timestamp: Date;
  scores: {
    overall: number;
    structure: number;
    character: number;
    dialogue: number;
    rhythm: number;
  };
  issues: Issue[];
  suggestions: Suggestion[];
}

// 对比不同版本
async function compareVersions(v1: string, v2: string): Promise<ComparisonReport> {
  const history1 = await db.getAssessment(v1);
  const history2 = await db.getAssessment(v2);

  return {
    improvements: calculateImprovements(history1, history2),
    regressions: calculateRegressions(history1, history2),
    changes: detectChanges(history1, history2),
  };
}
```

---

## 十二、总结

质量评估系统的核心价值:**让创作者即时了解剧本质量,明确优化方向**

四维度评估模型全面覆盖剧本创作的关键要素,结合 AI 自动优化,大幅降低剧本迭代成本。

---

**下一步**:
- [x] **PRD-01**: 产品定位与核心价值
- [x] **PRD-02**: 三模式剧本创作系统
- [x] **PRD-03**: 小说改编剧本工作流
- [x] **PRD-04**: 短剧短视频剧本规范
- [x] **PRD-05**: 剧本质量评估系统 (本文档)
- [ ] **PRD-06**: 完整创作流程与命令

---

**文档版本历史**:
- v1.0 (2025-10-29): 初始版本,定义质量评估系统
