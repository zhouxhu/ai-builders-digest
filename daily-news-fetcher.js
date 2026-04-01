#!/usr/bin/env node

/**
 * Daily News Fetcher for follow-builders-digest
 * Uses Tavily API to fetch international, domestic, and tech news
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const WORK_DIR = "/Users/zx/.openclaw/workspace/follow-builders-digest";
const SCRIPT_DIR = "/Users/zx/.openclaw/workspace/skills/tavily-search";
const DATE = new Date().toISOString().split('T')[0];
const NEWS_FILE = path.join(WORK_DIR, `${DATE}-news.md`);

console.log(`📰 Starting daily news fetch for ${DATE}...`);

// Change to work directory
process.chdir(WORK_DIR);

// Check if TAVILY_API_KEY is set
const apiKey = process.env.TAVILY_API_KEY?.trim();
if (!apiKey) {
    console.error("❌ TAVILY_API_KEY environment variable not set");
    process.exit(1);
}

// Function to fetch news using Tavily skill
async function fetchNews(query, title, emoji) {
    console.log(`🔍 Fetching ${title}...`);
    
    try {
        // Use the tavily search script
        const command = `node "${SCRIPT_DIR}/scripts/search.mjs" "${query}" -n 8 --topic news --days 1`;
        const result = execSync(command, { encoding: 'utf8', timeout: 30000 });
        
        return {
            success: true,
            content: result,
            count: (result.match(/\*\*/g) || []).length / 2 // Rough count of titles
        };
    } catch (error) {
        console.error(`❌ Error fetching ${title}:`, error.message);
        return { success: false, content: error.message, count: 0 };
    }
}

// Function to format news content
function formatNewsContent(content, title, emoji) {
    const lines = content.split('\n');
    const formatted = [];
    let inTitle = false;
    
    formatted.push(`## ${emoji} ${title}`);
    formatted.push('');
    
    for (const line of lines) {
        if (line.startsWith('## Answer') || line.startsWith('## Sources')) {
            continue; // Skip AI answer and sources headers
        }
        
        if (line.startsWith('- **') && line.includes('**')) {
            inTitle = true;
            // Extract title
            const title = line.replace(/^- \*\*/, '').replace(/\*\*.*/, '');
            // Simple translation (use the existing translate.py logic)
            const translatedTitle = translateTitle(title);
            formatted.push(`- **${translatedTitle}**`);
        } else if (line.startsWith('  https://') && inTitle) {
            formatted.push(`  ${line.trim()}`);
            formatted.push('');
        } else if (line.trim() === '') {
            inTitle = false;
        }
    }
    
    return formatted.filter(line => line.trim() !== '');
}

// Simple translation function (placeholder)
function translateTitle(title) {
    // In a real implementation, this would call the translate.py script
    // For now, return a basic translation
    if (title.includes('China') || title.includes('Chinese')) {
        return title.replace(/China/g, '中国').replace(/Chinese/g, '中国');
    }
    if (title.includes('AI') || title.includes('artificial intelligence')) {
        return title.replace(/AI/g, '人工智能').replace(/artificial intelligence/g, '人工智能');
    }
    return title;
}

// Create news file header
function createNewsFile() {
    const header = `---
layout: default
title: "新闻速递 — ${DATE}"
date: ${DATE}
---

# 📰 新闻速递 — ${DATE}

---

`;
    
    fs.writeFileSync(NEWS_FILE, header);
    console.log(`✅ Created news file: ${NEWS_FILE}`);
}

// Main function
async function main() {
    // Check if today's news already exists
    if (fs.existsSync(NEWS_FILE)) {
        console.log(`ℹ️ News file already exists: ${NEWS_FILE}`);
        console.log("To force update, delete the file and run again.");
        process.exit(0);
    }
    
    // Create news file
    createNewsFile();
    
    // Add initial content
    let content = '';
    let totalArticles = 0;
    
    // Fetch international news
    const internationalResult = await fetchNews(
        "world news international breaking news today", 
        "国际新闻", 
        "🌍"
    );
    
    if (internationalResult.success) {
        content += '## 🌍 国际新闻\n\n';
        const formatted = formatNewsContent(internationalResult.content, "", "");
        content += formatted.join('\n') + '\n\n---\n\n';
        totalArticles += internationalResult.count;
    } else {
        content += '## 🌍 国际新闻\n\n*暂无国际新闻数据*\n\n---\n\n';
    }
    
    // Fetch China news
    const chinaResult = await fetchNews(
        "China news domestic news today 中国新闻", 
        "国内新闻", 
        "🇨🇳"
    );
    
    if (chinaResult.success) {
        content += '## 🇨🇳 国内新闻\n\n';
        const formatted = formatNewsContent(chinaResult.content, "", "");
        content += formatted.join('\n') + '\n\n---\n\n';
        totalArticles += chinaResult.count;
    } else {
        content += '## 🇨🇳 国内新闻\n\n*暂无国内新闻数据*\n\n---\n\n';
    }
    
    // Fetch tech news
    const techResult = await fetchNews(
        "AI technology news tech artificial intelligence 科技新闻 人工智能", 
        "财经科技", 
        "💼"
    );
    
    if (techResult.success) {
        content += '## 💼 财经科技\n\n';
        const formatted = formatNewsContent(techResult.content, "", "");
        content += formatted.join('\n') + '\n\n---\n\n';
        totalArticles += techResult.count;
    } else {
        content += '## 💼 财经科技\n\n*暂无科技新闻数据*\n\n---\n\n';
    }
    
    // Add footer with statistics
    const footer = `## 📊 今日数据

**精选文章：${totalArticles} 篇**

- 🌍 国际: ${internationalResult.count} 篇
- 🇨🇳 国内: ${chinaResult.count} 篇
- 💼 科技: ${techResult.count} 篇

---

*Generated by OpenClaw News Aggregator - ${new Date().toLocaleString('zh-CN')}*

---

## ⚠️ 数据来源

所有新闻数据均来自 Tavily API 实时搜索结果。
`;
    
    // Complete the news file
    fs.appendFileSync(NEWS_FILE, content + footer);
    
    // Git operations
    console.log('📝 Committing changes to git...');
    try {
        // Add file
        execSync(`git add "${NEWS_FILE}"`);
        
        // Commit
        const commitMessage = `📰 Update daily news for ${DATE} (${totalArticles} articles)`;
        execSync(`git commit -m "${commitMessage}"`);
        
        // Push
        execSync('git push origin master');
        
        console.log('✅ Changes committed and pushed successfully');
    } catch (gitError) {
        console.error('⚠️ Git operations failed:', gitError.message);
        console.log('Please check git status and push manually');
    }
    
    console.log(`✅ Daily news fetch completed for ${DATE}`);
}

// Run main function
main().catch(error => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
});