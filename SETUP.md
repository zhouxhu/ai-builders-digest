# Follow-Builders-Digest Setup Guide

## Prerequisites

### 1. Tavily API Key

To fetch real news data, you need a Tavily API key:

1. Get your API key from https://tavily.com
2. Set the environment variable:
   ```bash
   export TAVILY_API_KEY="your_api_key_here"
   ```

### 2. Git Configuration

The repository must be properly configured for git operations:

```bash
# Set git config (if not already set)
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

## Usage

### Manual Run
```bash
cd "/Users/zx/.openclaw/workspace/follow-builders-digest"
./daily-news-fetcher-simple.sh
```

### Automated Run (Cron)
The script is designed to be run via cron. Add to your crontab:
```bash
0 8 * * * cd "/Users/zx/.openclaw/workspace/follow-builders-digest" && ./daily-news-fetcher-simple.sh
```

## Environment Variables

- `TAVILY_API_KEY`: Required for fetching news data from Tavily API
- `TZ`: Timezone (default: system timezone)

## File Structure

```
follow-builders-digest/
├── YYYY-MM-DD-news.md        # Daily news files
├── daily-news-fetcher-simple.sh  # Main script
├── tavily-search/           # Tavily API scripts
└── README.md               # This file
```

## Troubleshooting

### TAVILY_API_KEY not set
If the API key is not set, the script will create placeholder news files with a warning message.

### Git push fails
Check:
- GitHub authentication (SSH key or personal access token)
- Repository URL in `.git/config`
- Network connectivity

### Node.js issues
Ensure Node.js is installed and the tavily-search scripts are available at:
`/Users/zx/.openclaw/workspace/skills/tavily-search/scripts/`