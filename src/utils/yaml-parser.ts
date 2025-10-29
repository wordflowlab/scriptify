/**
 * YAML frontmatter parser for command templates
 */

import yaml from 'js-yaml';
import fs from 'fs-extra';
import { CommandMetadata } from '../types/index.js';

/**
 * Parse command template file and extract frontmatter + content
 */
export interface ParsedTemplate {
  metadata: CommandMetadata;
  content: string;
}

/**
 * Parse a markdown file with YAML frontmatter
 */
export async function parseCommandTemplate(
  filePath: string
): Promise<ParsedTemplate> {
  const fileContent = await fs.readFile(filePath, 'utf-8');

  // Check if file has frontmatter
  if (!fileContent.startsWith('---')) {
    throw new Error(`Template file missing YAML frontmatter: ${filePath}`);
  }

  // Extract frontmatter and content
  const parts = fileContent.split('---').filter(Boolean);

  if (parts.length < 2) {
    throw new Error(`Invalid template format: ${filePath}`);
  }

  const frontmatterStr = parts[0].trim();
  const content = parts.slice(1).join('---').trim();

  // Parse YAML
  const metadata = yaml.load(frontmatterStr) as CommandMetadata;

  return {
    metadata,
    content
  };
}

/**
 * Check if a template file exists
 */
export async function templateExists(templateName: string): Promise<boolean> {
  const templatePath = `templates/commands/${templateName}.md`;
  return fs.pathExists(templatePath);
}

/**
 * Get template file path
 */
export function getTemplatePath(templateName: string): string {
  return `templates/commands/${templateName}.md`;
}
