#!/usr/bin/env node

import { Command } from '@commander-js/extra-typings';
import chalk from 'chalk';
import fs from 'fs-extra';
import ora from 'ora';
import {
  displayProjectBanner,
  displaySuccess,
  displayError,
  displayInfo
} from './utils/interactive.js';
import { executeBashScript } from './utils/bash-runner.js';
import { parseCommandTemplate } from './utils/yaml-parser.js';

const program = new Command();

// Display banner
displayProjectBanner();

program
  .name('scriptify')
  .description(chalk.cyan('Scriptify - AI 驱动的剧本创作工具'))
  .version('0.1.0');

// /new - 创建新项目
program
  .command('new')
  .description('创建新剧本项目')
  .argument('<name>', '项目名称')
  .action(async (name: string) => {
    const spinner = ora('创建项目中...').start();

    try {
      const result = await executeBashScript('new', [name]);

      if (result.status === 'success') {
        spinner.succeed(result.message);
        displayInfo(`项目路径: ${result.project_path}`);
        console.log('');
        displayInfo('下一步:');
        result.next_steps?.forEach((step: string) => {
          console.log(`  • ${step}`);
        });
      } else {
        spinner.fail(result.message);
        process.exit(1);
      }
    } catch (error) {
      spinner.fail('创建项目失败');
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /list - 列出所有项目
program
  .command('list')
  .description('列出所有剧本项目')
  .action(async () => {
    try {
      const result = await executeBashScript('list');

      if (result.status === 'success') {
        if (result.projects.length === 0) {
          displayInfo(result.message || '暂无项目');
        } else {
          console.log(chalk.bold('\n项目列表:\n'));
          result.projects.forEach((project: any) => {
            console.log(
              `  ${chalk.cyan(project.name.padEnd(20))} ` +
                `${chalk.dim(project.type.padEnd(10))} ` +
                `${chalk.gray(project.modified)}`
            );
          });
          console.log('');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /spec - 定义剧本规格
program
  .command('spec')
  .description('定义/更新剧本规格')
  .argument('[project]', '项目名称(可选)')
  .action(async (project?: string) => {
    try {
      const args = project ? [project] : [];
      const result = await executeBashScript('spec', args);

      if (result.status === 'success') {
        displaySuccess(`项目: ${result.project_name}`);

        // Read and display command template
        const templatePath = 'templates/commands/spec.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          // Display script output context for AI
          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /idea - 故事构思
program
  .command('idea')
  .description('故事构思(教练模式)')
  .argument('[project]', '项目名称(可选)')
  .action(async (project?: string) => {
    try {
      const args = project ? [project] : [];
      const result = await executeBashScript('idea', args);

      if (result.status === 'success') {
        displaySuccess(`项目: ${result.project_name}`);

        // Read and display command template
        const templatePath = 'templates/commands/idea.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          // Display script output context
          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /outline - 故事大纲
program
  .command('outline')
  .description('构建故事大纲')
  .argument('[project]', '项目名称(可选)')
  .action(async (project?: string) => {
    try {
      const args = project ? [project] : [];
      const result = await executeBashScript('outline', args);

      if (result.status === 'success') {
        displaySuccess(`项目: ${result.project_name}`);

        // Read and display command template
        const templatePath = 'templates/commands/outline.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          // Display script output context
          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /characters - 人物设定
program
  .command('characters')
  .description('创建人物设定')
  .argument('[project]', '项目名称(可选)')
  .action(async (project?: string) => {
    try {
      const args = project ? [project] : [];
      const result = await executeBashScript('characters', args);

      if (result.status === 'success') {
        displaySuccess(`项目: ${result.project_name}`);

        const templatePath = 'templates/commands/characters.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /scene - 分场大纲
program
  .command('scene')
  .description('创建分场大纲')
  .argument('[project]', '项目名称(可选)')
  .action(async (project?: string) => {
    try {
      const args = project ? [project] : [];
      const result = await executeBashScript('scene', args);

      if (result.status === 'success') {
        displaySuccess(`项目: ${result.project_name}`);

        const templatePath = 'templates/commands/scene.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /script - 剧本生成
program
  .command('script')
  .description('生成剧本(支持三种模式)')
  .option('--episode <n>', '集数')
  .option('--mode <mode>', '模式(coach/express/hybrid)', 'coach')
  .option('--project <name>', '项目名称')
  .action(async (options) => {
    try {
      const args = [];
      if (options.project) {
        args.push('--project', options.project);
      }
      if (options.episode) {
        args.push('--episode', options.episode);
      }
      if (options.mode) {
        args.push('--mode', options.mode);
      }

      const result = await executeBashScript('script', args);

      if (result.status === 'success') {
        displaySuccess(`项目: ${result.project_name}`);

        // 根据模式选择模板
        let templateName = 'script-coach';
        if (options.mode === 'express') {
          templateName = 'script-express';
        } else if (options.mode === 'hybrid') {
          templateName = 'script-hybrid';
        }

        const templatePath = `templates/commands/${templateName}.md`;
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /fill - 填充混合模式框架
program
  .command('fill')
  .description('填充混合模式剧本框架')
  .option('--episode <n>', '集数')
  .option('--project <name>', '项目名称')
  .action(async (options) => {
    try {
      const args = [];
      if (options.project) {
        args.push('--project', options.project);
      }
      if (options.episode) {
        args.push('--episode', options.episode);
      }

      const result = await executeBashScript('fill', args);

      if (result.status === 'success' || (result.status as string) === 'info') {
        if (result.action === 'list') {
          displaySuccess(`项目: ${result.project_name}`);
          console.log('');
          displayInfo('可填充的混合模式剧本:');
          result.hybrid_episodes?.forEach((ep: any) => {
            console.log(
              `  第${ep.episode}集 - ${ep.fill_count}个待填充项 (${ep.word_count}字)`
            );
          });
          console.log('');
          displayInfo('使用 /fill --episode N 开始填充');
        } else if (result.action === 'completed') {
          displaySuccess(`第${result.episode}集所有填充项已完成!`);
          displayInfo(result.suggestion);
        } else {
          displaySuccess(`项目: ${result.project_name}`);
        }

        const templatePath = 'templates/commands/fill.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /polish - 剧本润色
program
  .command('polish')
  .description('剧本润色优化')
  .option('--episode <n>', '集数')
  .option('--focus <type>', '润色重点(dialogue/action/rhythm/all)', 'all')
  .option('--project <name>', '项目名称')
  .action(async (options) => {
    try {
      const args = [];
      if (options.project) {
        args.push('--project', options.project);
      }
      if (options.episode) {
        args.push('--episode', options.episode);
      }
      if (options.focus) {
        args.push('--focus', options.focus);
      }

      const result = await executeBashScript('polish', args);

      if (result.status === 'success') {
        if (result.action === 'list') {
          displaySuccess(`项目: ${result.project_name}`);
          console.log('');
          displayInfo('可润色的剧本:');
          result.episodes?.forEach((ep: any) => {
            const mark = ep.needs_polish ? '⚠️' : '✓';
            console.log(`  ${mark} 第${ep.episode}集 (${ep.word_count}字)`);
          });
          console.log('');
          displayInfo('使用 /polish --episode N 开始润色');
        } else {
          displaySuccess(`项目: ${result.project_name} - 第${result.episode}集`);
        }

        const templatePath = 'templates/commands/polish.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// /visualize - 场景视觉化
program
  .command('visualize')
  .description('场景视觉化(小说改编)')
  .option('--project <name>', '项目名称')
  .action(async (options) => {
    try {
      const args = options.project ? ['--project', options.project] : [];
      const result = await executeBashScript('visualize', args);

      if (result.status === 'success') {
        displaySuccess(`项目: ${result.project_name}`);

        const templatePath = 'templates/commands/visualize.md';
        if (await fs.pathExists(templatePath)) {
          const { metadata, content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });

// Helper function for simple command registration
async function registerSimpleCommand(cmdName: string, description: string, options: any = {}) {
  const cmd = program.command(cmdName).description(description);

  if (options.episode) cmd.option('--episode <n>', '集数');
  if (options.project) cmd.option('--project <name>', '项目名称');
  if (options.platform) cmd.option('--platform <name>', '平台名称');
  if (options.target) cmd.option('--target <n>', '目标字数');
  if (options.ep1) cmd.option('--ep1 <n>', '第一集');
  if (options.ep2) cmd.option('--ep2 <n>', '第二集');

  cmd.action(async (opts: any) => {
    try {
      const args = [];
      if (opts.project) args.push('--project', opts.project);
      if (opts.episode) args.push('--episode', opts.episode);
      if (opts.platform) args.push('--platform', opts.platform);
      if (opts.target) args.push('--target', opts.target);
      if (opts.ep1) args.push('--ep1', opts.ep1);
      if (opts.ep2) args.push('--ep2', opts.ep2);

      const result = await executeBashScript(cmdName, args);

      if (result.status === 'success') {
        displaySuccess(result.message || `${cmdName} 执行成功`);

        const templatePath = `templates/commands/${cmdName}.md`;
        if (await fs.pathExists(templatePath)) {
          const { content } = await parseCommandTemplate(templatePath);
          console.log('\n' + chalk.dim('─'.repeat(50)));
          console.log(content);
          console.log(chalk.dim('─'.repeat(50)) + '\n');

          console.log(chalk.dim('## 脚本输出信息\n'));
          console.log('```json');
          console.log(JSON.stringify(result, null, 2));
          console.log('```');
        }
      } else {
        displayError(result.message || '发生未知错误');
        process.exit(1);
      }
    } catch (error) {
      displayError(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  });
}

// Batch 1: Quality Assessment Commands
registerSimpleCommand('optimize', 'AI优化建议', { episode: true, project: true });
registerSimpleCommand('diff', '版本对比', { episode: true, project: true });
registerSimpleCommand('compare', '剧本比较', { ep1: true, ep2: true, project: true });

// Batch 2: Short Drama Optimization Commands
registerSimpleCommand('platform-fit', '平台适配度检测', { episode: true, platform: true, project: true });
registerSimpleCommand('viral-score', '传播潜力评分', { episode: true, project: true });
registerSimpleCommand('shorten', '篇幅压缩', { episode: true, target: true, project: true });

// Batch 3: Utility Commands
registerSimpleCommand('save', '保存项目', { project: true });
registerSimpleCommand('export-review', '导出评估报告', { project: true });
registerSimpleCommand('settings', '设置管理', {});

// Help command
program
  .command('help')
  .description('显示帮助信息')
  .action(() => {
    console.log(chalk.bold('\nScriptify - AI 驱动的剧本创作工具\n'));
    console.log(chalk.cyan('📋 项目管理:'));
    console.log('  scriptify new <项目名>              创建新项目');
    console.log('  scriptify list                      列出所有项目');
    console.log('  scriptify save [项目]               保存项目');
    console.log('');
    console.log(chalk.cyan('✍️ 原创剧本:'));
    console.log('  scriptify spec [项目]               定义剧本规格');
    console.log('  scriptify idea [项目]               故事构思');
    console.log('  scriptify outline [项目]            故事大纲');
    console.log('  scriptify characters [项目]         人物设定');
    console.log('  scriptify scene [项目]              分场大纲');
    console.log('  scriptify script --episode N        生成剧本');
    console.log('  scriptify fill --episode N          填充混合模式');
    console.log('  scriptify polish --episode N        剧本润色');
    console.log('');
    console.log(chalk.cyan('📚 小说改编:'));
    console.log('  scriptify visualize                 场景视觉化');
    console.log('');
    console.log(chalk.cyan('🎬 短剧优化:'));
    console.log('  scriptify platform-fit --episode N  平台适配度');
    console.log('  scriptify viral-score --episode N   传播潜力');
    console.log('  scriptify shorten --episode N       篇幅压缩');
    console.log('');
    console.log(chalk.cyan('🔍 质量评估:'));
    console.log('  scriptify optimize --episode N      AI优化建议');
    console.log('  scriptify diff --episode N          版本对比');
    console.log('  scriptify compare --ep1 1 --ep2 2   剧本比较');
    console.log('');
    console.log(chalk.cyan('📖 查看文档:'));
    console.log('  README.md - 快速开始指南');
    console.log('  docs/juben/ - 完整PRD文档');
    console.log('');
  });

// Parse arguments
program.parse();
