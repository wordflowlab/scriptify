/**
 * Bash script execution utilities
 */

import { spawn } from 'child_process';
import path from 'path';
import fs from 'fs-extra';
import { BashResult } from '../types/index.js';

/**
 * Find the scriptify project root directory by looking for .scriptify/config.json
 */
function findProjectRoot(): string {
  let current = process.cwd();

  while (current !== '/') {
    const configPath = path.join(current, '.scriptify', 'config.json');
    if (fs.existsSync(configPath)) {
      return current;
    }
    current = path.dirname(current);
  }

  // Fallback to current directory
  return process.cwd();
}

/**
 * Execute a bash script and return parsed JSON result
 */
export async function executeBashScript(
  scriptName: string,
  args: string[] = []
): Promise<BashResult> {
  return new Promise((resolve, reject) => {
    const projectRoot = findProjectRoot();
    const scriptPath = path.join(
      projectRoot,
      'scripts',
      'bash',
      `${scriptName}.sh`
    );

    const child = spawn('bash', [scriptPath, ...args], {
      cwd: process.cwd(),
      env: process.env
    });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    child.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`Script exited with code ${code}: ${stderr}`));
        return;
      }

      try {
        // Parse JSON output from script
        const result = JSON.parse(stdout.trim());
        resolve(result);
      } catch (error) {
        reject(new Error(`Failed to parse script output: ${stdout}`));
      }
    });

    child.on('error', (error) => {
      reject(error);
    });
  });
}

/**
 * Execute a bash script with real-time output
 */
export async function executeBashScriptWithOutput(
  scriptName: string,
  args: string[] = []
): Promise<void> {
  return new Promise((resolve, reject) => {
    const projectRoot = findProjectRoot();
    const scriptPath = path.join(
      projectRoot,
      'scripts',
      'bash',
      `${scriptName}.sh`
    );

    const child = spawn('bash', [scriptPath, ...args], {
      cwd: process.cwd(),
      env: process.env,
      stdio: 'inherit' // Show output in real-time
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`Script exited with code ${code}`));
        return;
      }
      resolve();
    });

    child.on('error', (error) => {
      reject(error);
    });
  });
}
