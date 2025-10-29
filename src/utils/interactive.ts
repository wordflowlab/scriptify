#!/usr/bin/env node
/**
 * Interactive selection utilities for Scriptify
 */

import inquirer from 'inquirer';
import chalk from 'chalk';
import { AIConfig } from '../types/index.js';

/**
 * Display project banner
 */
export function displayProjectBanner(): void {
  console.log('');
  console.log(chalk.cyan.bold('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'));
  console.log(chalk.cyan.bold('  Scriptify - AI 驱动的剧本创作工具'));
  console.log(chalk.cyan.bold('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'));
  console.log('');
}

/**
 * Select script type interactively
 */
export async function selectScriptType(): Promise<string> {
  const choices = [
    {
      name: `${chalk.cyan('短剧'.padEnd(12))} ${chalk.dim('(10分钟×N集)')}`,
      value: '短剧',
      short: '短剧'
    },
    {
      name: `${chalk.cyan('短视频'.padEnd(12))} ${chalk.dim('(1-3分钟)')}`,
      value: '短视频',
      short: '短视频'
    },
    {
      name: `${chalk.cyan('长剧'.padEnd(12))} ${chalk.dim('(45分钟×N集)')}`,
      value: '长剧',
      short: '长剧'
    },
    {
      name: `${chalk.cyan('电影'.padEnd(12))} ${chalk.dim('(90-120分钟)')}`,
      value: '电影',
      short: '电影'
    }
  ];

  const answer = await inquirer.prompt([
    {
      type: 'list',
      name: 'type',
      message: chalk.bold('选择剧本类型:'),
      choices,
      default: '短剧'
    }
  ]);

  return answer.type;
}

/**
 * Select creation mode interactively
 */
export async function selectCreationMode(): Promise<string> {
  const choices = [
    {
      name: `${chalk.cyan('教练模式'.padEnd(12))} ${chalk.dim('(AI引导你思考，100%原创)')}`,
      value: 'coach',
      short: '教练模式'
    },
    {
      name: `${chalk.cyan('快速模式'.padEnd(12))} ${chalk.dim('(AI生成初稿，快速迭代)')}`,
      value: 'express',
      short: '快速模式'
    },
    {
      name: `${chalk.cyan('混合模式'.padEnd(12))} ${chalk.dim('(AI提供框架，你填充细节)')}`,
      value: 'hybrid',
      short: '混合模式'
    }
  ];

  const answer = await inquirer.prompt([
    {
      type: 'list',
      name: 'mode',
      message: chalk.bold('选择创作模式:'),
      choices,
      default: 'coach'
    }
  ]);

  return answer.mode;
}

/**
 * Select genre interactively
 */
export async function selectGenre(): Promise<string> {
  const choices = [
    { name: '悬疑', value: '悬疑' },
    { name: '言情', value: '言情' },
    { name: '职场', value: '职场' },
    { name: '古装', value: '古装' },
    { name: '现代都市', value: '现代都市' },
    { name: '科幻', value: '科幻' },
    { name: '喜剧', value: '喜剧' },
    { name: '家庭伦理', value: '家庭伦理' }
  ];

  const answer = await inquirer.prompt([
    {
      type: 'list',
      name: 'genre',
      message: chalk.bold('选择题材类型:'),
      choices,
      pageSize: 10
    }
  ]);

  return answer.genre;
}

/**
 * Display initialization step
 */
export function displayStep(step: number, total: number, message: string): void {
  console.log(chalk.dim(`[${step}/${total}]`) + ' ' + message);
}

/**
 * Display success message
 */
export function displaySuccess(message: string): void {
  console.log(chalk.green('✓ ') + message);
}

/**
 * Display error message
 */
export function displayError(message: string): void {
  console.log(chalk.red('✗ ') + message);
}

/**
 * Display warning message
 */
export function displayWarning(message: string): void {
  console.log(chalk.yellow('⚠ ') + message);
}

/**
 * Display info message
 */
export function displayInfo(message: string): void {
  console.log(chalk.cyan('ℹ ') + message);
}

/**
 * Check if running in interactive terminal
 */
export function isInteractive(): boolean {
  return process.stdin.isTTY === true && process.stdout.isTTY === true;
}

/**
 * Select AI assistant interactively
 */
export async function selectAIAssistant(aiConfigs: AIConfig[]): Promise<string> {
  const choices = aiConfigs.map(config => ({
    name: `${chalk.cyan(config.name.padEnd(12))} ${chalk.dim(`(${config.displayName})`)}`,
    value: config.name,
    short: config.name
  }));

  const answer = await inquirer.prompt([{
    type: 'list',
    name: 'ai',
    message: chalk.bold('选择你的 AI 助手:'),
    choices,
    default: 'claude',
    pageSize: 15
  }]);

  return answer.ai;
}

/**
 * Select bash script type
 */
export async function selectBashScriptType(): Promise<string> {
  const scriptChoices = [
    {
      name: `${chalk.cyan('sh'.padEnd(12))} ${chalk.dim('(POSIX Shell - macOS/Linux)')}`,
      value: 'sh',
      short: 'sh'
    },
    {
      name: `${chalk.cyan('ps'.padEnd(12))} ${chalk.dim('(PowerShell - Windows)')}`,
      value: 'ps',
      short: 'ps'
    }
  ];

  const answer = await inquirer.prompt([{
    type: 'list',
    name: 'scriptType',
    message: chalk.bold('选择脚本类型:'),
    choices: scriptChoices,
    default: 'sh'
  }]);

  return answer.scriptType;
}

/**
 * Confirm action
 */
export async function confirmAction(message: string, defaultValue = false): Promise<boolean> {
  const answer = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'confirmed',
      message,
      default: defaultValue
    }
  ]);

  return answer.confirmed;
}
