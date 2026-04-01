#!/bin/bash

# Daily News Fetcher Wrapper for follow-builders-digest
# Ensures environment variables are properly set and runs the JavaScript fetcher

WORK_DIR="/Users/zx/.openclaw/workspace/follow-builders-digest"
DATE=$(date +%Y-%m-%d)

cd "$WORK_DIR"

echo "📰 Daily News Update - $DATE"

# Check if TAVILY_API_KEY is set
if [ -z "$TAVILY_API_KEY" ]; then
    echo "❌ TAVILY_API_KEY environment variable not set"
    echo "Please set the environment variable before running"
    exit 1
fi

# Use node to run the JavaScript fetcher
if command -v node >/dev/null 2>&1; then
    echo "🔄 Running JavaScript fetcher..."
    node daily-news-fetcher.js
else
    echo "❌ Node.js not found. Please install Node.js."
    exit 1
fi

echo "✅ Daily news update completed"