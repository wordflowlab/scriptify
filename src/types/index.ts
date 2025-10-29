/**
 * Type definitions for Scriptify
 */

/**
 * AI 平台配置
 */
export interface AIConfig {
  name: string;
  dir: string;
  commandsDir: string;
  displayName: string;
}

/**
 * 剧本规格配置
 */
export interface ScriptSpec {
  project_name: string;
  type: '短剧' | '短视频' | '长剧' | '电影' | string;
  duration: string; // "10分钟×10集" or "90分钟"
  episodes?: number;
  genre: string; // 悬疑/言情/职场等
  audience: {
    age: string; // "18-25岁"
    gender: '男性' | '女性' | '不限' | string;
  };
  target_platform: string[]; // ["抖音", "快手"]
  tone?: string; // 轻松/严肃/搞笑等
  created_at: string;
  updated_at: string;
}

/**
 * 创作模式
 */
export type CreationMode = 'coach' | 'express' | 'hybrid';

/**
 * 命令模板前置元数据 (YAML frontmatter)
 */
export interface CommandMetadata {
  description: string;
  'argument-hint'?: string;
  'allowed-tools'?: string[];
  scripts?: {
    sh?: string;
    ps?: string;
  };
  mode?: CreationMode;
}

/**
 * Bash 脚本执行结果
 */
export interface BashResult {
  status: 'success' | 'error';
  message?: string;
  [key: string]: any; // 允许其他自定义字段
}

/**
 * 项目信息
 */
export interface ProjectInfo {
  name: string;
  path: string;
  type?: string;
  stage?: string;
  modified?: string;
}

/**
 * 剧本创意
 */
export interface ScriptIdea {
  protagonist: {
    name: string;
    occupation: string;
    age: string;
    traits: string;
  };
  goal: string;
  obstacle: string;
  character_arc: string;
  hook: string;
  conflict: string;
  unique_selling_point: string;
}

/**
 * 故事大纲
 */
export interface StoryOutline {
  act_one: {
    setup: string;
    inciting_incident: string;
    turning_point: string;
  };
  act_two: {
    plan: string;
    b_story: string;
    midpoint: string;
    all_is_lost: string;
    turning_point: string;
  };
  act_three: {
    realization: string;
    climax: string;
    resolution: string;
    epilogue?: string;
  };
}

/**
 * 人物设定
 */
export interface Character {
  name: string;
  role: '主角' | '配角' | '反派' | string;
  age: number;
  occupation: string;
  personality: string;
  backstory: string;
  goal: string;
  flaw: string;
  arc: string;
}

/**
 * 场次大纲
 */
export interface Scene {
  scene_number: number;
  location: string;
  time: string; // 日/夜/晨/昏
  characters: string[];
  goal: string; // 这场戏的目的
  conflict: string;
  outcome: string;
  notes?: string;
}

/**
 * Hook 类型
 */
export type HookType =
  | '冲突开场'
  | '悬念开场'
  | '反常开场'
  | '金句开场'
  | '高潮前置'
  | '问题开场'
  | '场景开场'
  | '对比开场'
  | '秘密开场'
  | '意外开场'
  | '时间压力'
  | '身份反转'
  | '悬疑线索'
  | '情感冲击'
  | '视觉冲击';

/**
 * 爆点
 */
export interface ExplosionPoint {
  timestamp: string; // "00:15" or "第3分钟"
  type: '反转' | '冲突' | '悬念' | '笑点' | '泪点' | string;
  description: string;
  intensity: 1 | 2 | 3 | 4 | 5; // 强度等级
}

/**
 * 质量评分
 */
export interface QualityScore {
  structure: number; // 0-100
  character: number;
  dialogue: number;
  rhythm: number;
  total: number;
  feedback: {
    strengths: string[];
    weaknesses: string[];
    suggestions: string[];
  };
}
