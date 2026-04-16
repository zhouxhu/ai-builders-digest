#!/bin/bash

# Daily News Fetcher using direct curl to Tavily API
# Fetches international, domestic China, and tech news with error handling

set -e

# Configuration
CURRENT_DATE=$(date +%Y-%m-%d)
NEWS_FILE="${CURRENT_DATE}-news.md"
TEMP_DIR=$(mktemp -d)

# Try to get API key from environment or prompt for it
TAVILY_API_KEY="${TAVILY_API_KEY:-$(cat ~/.config/tavily-api-key 2>/dev/null || echo "")}"

# Check if Tavily API key is available
if [ -z "$TAVILY_API_KEY" ]; then
    echo "Error: TAVILY_API_KEY environment variable or ~/.config/tavily-api-key not set"
    echo "Please set your Tavily API key:"
    echo "1. Export TAVILY_API_KEY='your-api-key-here'"
    echo "2. Or echo 'your-api-key-here' > ~/.config/tavily-api-key"
    echo "3. Get your API key from https://tavily.com"
    exit 1
fi

# Fetch news using direct curl
fetch_news() {
    local query="$1"
    local category="$2"
    local output_file="${TEMP_DIR}/${category}.json"
    
    echo "Fetching ${category} news..."
    
    # Build curl command
    local curl_cmd="curl -s 'https://api.tavily.com/search' \
        -H 'Content-Type: application/json' \
        -d '{
            \"api_key\": \"${TAVILY_API_KEY}\",
            \"query\": \"${query}\",
            \"max_results\": 10,
            \"search_depth\": \"advanced\",
            \"include_answer\": false,
            \"include_raw_content\": false
        }'"
    
    # Execute the curl command
    if eval $curl_cmd > "${output_file}" 2>/dev/null; then
        if [ -s "${output_file}" ]; then
            # Check if the response contains valid JSON
            if python3 -c "import json; json.load(open('${output_file}'))" 2>/dev/null; then
                echo "Successfully fetched ${category} news"
                return 0
            else
                echo "Warning: Invalid JSON response for ${category} news"
                rm -f "${output_file}"
                return 1
            fi
        else
            echo "Warning: Empty response for ${category} news"
            return 1
        fi
    else
        echo "Warning: Failed to fetch ${category} news"
        return 1
    fi
}

# Process news results and generate markdown
generate_news_markdown() {
    local temp_file="${TEMP_DIR}/news-content.md"
    
    # Create the markdown file with front matter
    cat > "${temp_file}" << EOF
---
layout: default
title: "新闻速递 — ${CURRENT_DATE}"
date: ${CURRENT_DATE}
---

# 📰 新闻速递 — ${CURRENT_DATE}

---

EOF
    
    # International News
    echo "## 🌍 国际新闻" >> "${temp_file}"
    echo "" >> "${temp_file}"
    
    if [ -f "${TEMP_DIR}/international.json" ]; then
        # Extract news items using jq or manual parsing
        if command -v jq >/dev/null 2>&1; then
            jq -r '.results[] | "- **\(.title | gsub("\\\\"; "") | gsub("\""; "")) - \(.source) (relevance: \(.score * 100 | floor))%**\n  <\(.url)>"' "${TEMP_DIR}/international.json" 2>/dev/null | while IFS= read -r line; do
                if [ -n "$line" ]; then
                    echo "  $line" >> "${temp_file}"
                fi
            done
        elif command -v python3 >/dev/null 2>&1; then
            # Use Python for JSON parsing if jq is not available
            python3 -c "
import json
import sys
with open('${TEMP_DIR}/international.json', 'r') as f:
    data = json.load(f)
for result in data.get('results', []):
    title = result.get('title', '').replace('\"', '').replace('\\\\', '')
    source = result.get('source', 'Unknown')
    score = result.get('score', 0)
    url = result.get('url', '')
    if title and url:
        print(f'  - **{title}** - {source} (relevance: {int(score * 100)}%)')
        print(f'    {url}')
" >> "${temp_file}"
        else
            # Fallback: simple text parsing
            python3 -c "
import json
import re
with open('${TEMP_DIR}/international.json', 'r') as f:
    content = f.read()
# Extract titles and URLs
titles = re.findall(r'\"title\":\s*\"([^\"]+)\"', content)
urls = re.findall(r'\"url\":\s*\"([^\"]+)\"', content)
sources = re.findall(r'\"source\":\s*\"([^\"]+)\"', content)
scores = re.findall(r'\"score\":\s*([0-9\.]+)', content)
for i, title in enumerate(titles[:5]):
    source = sources[i] if i < len(sources) else 'Unknown'
    score = int(float(scores[i]) * 100) if i < len(scores) else 0
    url = urls[i] if i < len(urls) else ''
    if title and url:
        print(f'  - **{title}** - {source} (relevance: {score}%)')
        print(f'    {url}')
" >> "${temp_file}"
        fi
    else
        echo "  No international news available" >> "${temp_file}"
    fi
    
    echo "" >> "${temp_file}"
    echo "" >> "${temp_file}"
    
    # China Domestic News
    echo "## 🇨🇳 国内新闻" >> "${temp_file}"
    echo "" >> "${temp_file}"
    
    if [ -f "${TEMP_DIR}/china.json" ]; then
        if command -v jq >/dev/null 2>&1; then
            jq -r '.results[] | "- **\(.title | gsub("\\\\"; "") | gsub("\""; "")) - \(.source) (relevance: \(.score * 100 | floor))%**\n  <\(.url)>"' "${TEMP_DIR}/china.json" 2>/dev/null | while IFS= read -r line; do
                if [ -n "$line" ]; then
                    echo "  $line" >> "${temp_file}"
                fi
            done
        elif command -v python3 >/dev/null 2>&1; then
            python3 -c "
import json
import sys
with open('${TEMP_DIR}/china.json', 'r') as f:
    data = json.load(f)
for result in data.get('results', []):
    title = result.get('title', '').replace('\"', '').replace('\\\\', '')
    source = result.get('source', 'Unknown')
    score = result.get('score', 0)
    url = result.get('url', '')
    if title and url:
        print(f'  - **{title}** - {source} (relevance: {int(score * 100)}%)')
        print(f'    {url}')
" >> "${temp_file}"
        else
            python3 -c "
import json
import re
with open('${TEMP_DIR}/china.json', 'r') as f:
    content = f.read()
titles = re.findall(r'\"title\":\s*\"([^\"]+)\"', content)
urls = re.findall(r'\"url\":\s*\"([^\"]+)\"', content)
sources = re.findall(r'\"source\":\s*\"([^\"]+)\"', content)
scores = re.findall(r'\"score\":\s*([0-9\.]+)', content)
for i, title in enumerate(titles[:5]):
    source = sources[i] if i < len(sources) else 'Unknown'
    score = int(float(scores[i]) * 100) if i < len(scores) else 0
    url = urls[i] if i < len(urls) else ''
    if title and url:
        print(f'  - **{title}** - {source} (relevance: {score}%)')
        print(f'    {url}')
" >> "${temp_file}"
        fi
    else
        echo "  No domestic news available" >> "${temp_file}"
    fi
    
    echo "" >> "${temp_file}"
    echo "" >> "${temp_file}"
    
    # Tech/Finance News
    echo "## 💼 财经科技" >> "${temp_file}"
    echo "" >> "${temp_file}"
    
    if [ -f "${TEMP_DIR}/tech.json" ]; then
        if command -v jq >/dev/null 2>&1; then
            jq -r '.results[] | "- **\(.title | gsub("\\\\"; "") | gsub("\""; "")) - \(.source) (relevance: \(.score * 100 | floor))%**\n  <\(.url)>"' "${TEMP_DIR}/tech.json" 2>/dev/null | while IFS= read -r line; do
                if [ -n "$line" ]; then
                    echo "  $line" >> "${temp_file}"
                fi
            done
        elif command -v python3 >/dev/null 2>&1; then
            python3 -c "
import json
import sys
with open('${TEMP_DIR}/tech.json', 'r') as f:
    data = json.load(f)
for result in data.get('results', []):
    title = result.get('title', '').replace('\"', '').replace('\\\\', '')
    source = result.get('source', 'Unknown')
    score = result.get('score', 0)
    url = result.get('url', '')
    if title and url:
        print(f'  - **{title}** - {source} (relevance: {int(score * 100)}%)')
        print(f'    {url}')
" >> "${temp_file}"
        else
            python3 -c "
import json
import re
with open('${TEMP_DIR}/tech.json', 'r') as f:
    content = f.read()
titles = re.findall(r'\"title\":\s*\"([^\"]+)\"', content)
urls = re.findall(r'\"url\":\s*\"([^\"]+)\"', content)
sources = re.findall(r'\"source\":\s*\"([^\"]+)\"', content)
scores = re.findall(r'\"score\":\s*([0-9\.]+)', content)
for i, title in enumerate(titles[:5]):
    source = sources[i] if i < len(sources) else 'Unknown'
    score = int(float(scores[i]) * 100) if i < len(scores) else 0
    url = urls[i] if i < len(urls) else ''
    if title and url:
        print(f'  - **{title}** - {source} (relevance: {score}%)')
        print(f'    {url}')
" >> "${temp_file}"
        fi
    else
        echo "  No tech news available" >> "${temp_file}"
    fi
    
    echo "" >> "${temp_file}"
    echo "" >> "${temp_file}"
    
    # Summary section
    local international_count=0
    local china_count=0
    local tech_count=0
    
    if [ -f "${TEMP_DIR}/international.json" ]; then
        if command -v jq >/dev/null 2>&1; then
            international_count=$(jq '.results | length' "${TEMP_DIR}/international.json" 2>/dev/null || echo "0")
        elif command -v python3 >/dev/null 2>&1; then
            international_count=$(python3 -c "import json; data=json.load(open('${TEMP_DIR}/international.json')); print(len(data.get('results', [])))" 2>/dev/null || echo "0")
        else
            international_count=$(grep -c '"title"' "${TEMP_DIR}/international.json}" 2>/dev/null || echo "0")
        fi
    fi
    
    if [ -f "${TEMP_DIR}/china.json" ]; then
        if command -v jq >/dev/null 2>&1; then
            china_count=$(jq '.results | length' "${TEMP_DIR}/china.json" 2>/dev/null || echo "0")
        elif command -v python3 >/dev/null 2>&1; then
            china_count=$(python3 -c "import json; data=json.load(open('${TEMP_DIR}/china.json')); print(len(data.get('results', [])))" 2>/dev/null || echo "0")
        else
            china_count=$(grep -c '"title"' "${TEMP_DIR}/china.json}" 2>/dev/null || echo "0")
        fi
    fi
    
    if [ -f "${TEMP_DIR}/tech.json" ]; then
        if command -v jq >/dev/null 2>&1; then
            tech_count=$(jq '.results | length' "${TEMP_DIR}/tech.json" 2>/dev/null || echo "0")
        elif command -v python3 >/dev/null 2>&1; then
            tech_count=$(python3 -c "import json; data=json.load(open('${TEMP_DIR}/tech.json')); print(len(data.get('results', [])))" 2>/dev/null || echo "0")
        else
            tech_count=$(grep -c '"title"' "${TEMP_DIR}/tech.json}" 2>/dev/null || echo "0")
        fi
    fi
    
    local total_count=$((international_count + china_count + tech_count))
    
    cat >> "${temp_file}" << EOF
## 📊 今日数据

**精选文章：${total_count} 篇**

- 🌍 国际: ${international_count} 篇
- 🇨🇳 国内: ${china_count} 篇
- 💼 科技: ${tech_count} 篇

---

*Generated by OpenClaw News Aggregator - $(date '+%Y/%m/%d %H:%M:%S')*

---

## ⚠️ 数据来源

所有新闻数据均来自 Tavily API 实时搜索结果。

EOF
}

# Main execution
echo "Starting daily news fetch for ${CURRENT_DATE}"

# Set error handling to continue on errors
set +e

# Fetch all categories (allow failures)
fetch_news "world news international" "international"
fetch_news "China news domestic Chinese" "china"
fetch_news "AI technology tech innovation startup" "tech"

# Set error handling back to strict
set -e

# Generate markdown
generate_news_markdown

# Move the generated file to the final location
if [ -f "${temp_file}" ]; then
    mv "${temp_file}" "${NEWS_FILE}"
    echo "News file generated: ${NEWS_FILE}"
else
    echo "Error: Failed to generate news file"
    exit 1
fi

# Cleanup
rm -rf "${TEMP_DIR}"

echo "Daily news fetch completed successfully!"