#!/bin/bash

# Final Daily News Update for follow-builders-digest
# Uses enhanced news fetcher with proper Tavily API integration
# This script is triggered by cron job system events

WORK_DIR="/Users/zx/.openclaw/workspace/follow-builders-digest"
DATE=$(date +%Y-%m-%d)
NEWS_FILE="$WORK_DIR/$DATE-news.md"

cd "$WORK_DIR"

echo "📰 Starting final daily news update for $DATE..."

# Check if enhanced news fetcher exists
if [ ! -f "enhanced-news-fetcher.js" ]; then
    echo "❌ enhanced-news-fetcher.js not found"
    exit 1
fi

# Run the enhanced news fetcher
echo "🔍 Running enhanced news fetcher..."
if node enhanced-news-fetcher.js; then
    echo "✅ News fetch completed successfully"
else
    echo "❌ News fetch failed"
    exit 1
fi

# Check if news file was created and has content
if [ ! -f "$NEWS_FILE" ]; then
    echo "❌ News file not created"
    exit 1
fi

# Check if file has content (more than just template)
word_count=$(wc -w < "$NEWS_FILE" 2>/dev/null || echo "0")
if [ "$word_count" -lt 50 ]; then
    echo "⚠️ News file appears to have minimal content, checking if we need to fallback..."
    # Check if there are actual articles
    article_count=$(grep -c '^- \*\*' "$NEWS_FILE" 2>/dev/null || echo "0")
    if [ "$article_count" -eq 0 ]; then
        echo "❌ No articles found in news file"
        exit 1
    fi
fi

echo "✅ News file created with $word_count words"

# Git operations
echo "📝 Committing changes to git..."

# Check if there are changes to commit
if git diff --quiet "$NEWS_FILE" 2>/dev/null; then
    echo "ℹ️ No changes to commit (file may already exist with same content)"
    exit 0
fi

# Stage and commit
if git add "$NEWS_FILE" && git commit -m "📰 Update daily news for $DATE"; then
    echo "✅ Changes committed successfully"
    
    # Push to remote
    if git push origin master 2>/dev/null; then
        echo "✅ Changes pushed to GitHub"
    else
        echo "⚠️ Push failed - manual intervention may be needed"
        echo "💡 Tip: Run 'git push origin master' manually"
        
        # Check git status for debugging
        echo "🔍 Git status:"
        git status
    fi
else
    echo "❌ Failed to commit changes"
    # Show git status for debugging
    echo "🔍 Git status:"
    git status
    exit 1
fi

echo "✅ Final daily news update completed for $DATE"

# Clean up old files (keep last 30 days)
echo "🧹 Cleaning up old news files..."
find . -name "20*-news.md" -type f -mtime +30 -exec echo "Removing: {}" \; -exec rm {} \; 2>/dev/null | head -10

echo "🎉 All tasks completed!"