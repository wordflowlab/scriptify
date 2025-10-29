---
description: 平台适配度检测
argument-hint: --episode N --platform [douyin|kuaishou|xigua|iqiyi]
allowed-tools: Read(//projects/**)
scripts:
  sh: scripts/bash/platform-fit.sh
---

# /platform-fit - 平台适配度

## 检测标准

### 抖音短剧
- 时长: 1-3分钟/集
- Hook: 3秒内必须有强Hook
- 爆点密度: 每30秒1个
- 节奏: 极快,无废镜头
- 特点: 竖屏,强视觉冲击

### 快手短剧
- 时长: 2-5分钟/集
- Hook: 5秒内引入冲突
- 爆点密度: 每45秒1个
- 节奏: 快,接地气
- 特点: 生活化,共鸣强

### 长视频平台
- 时长: 10-15分钟/集
- Hook: 1分钟内设置悬念
- 爆点密度: 每2-3分钟1个
- 节奏: 稳定,有铺垫
- 特点: 重剧情和人物

AI将根据目标平台,检查剧本是否符合该平台的规范和用户偏好。
