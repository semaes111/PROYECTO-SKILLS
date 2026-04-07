---
name: firecrawl-web-scraper
description: |
  Scrape, crawl, search, and clone web pages into clean LLM-ready Markdown using Firecrawl CLI. 
  Use when the user wants to: scrape a webpage, clone a website, convert URL to markdown, 
  fetch web content, crawl documentation, download a site, extract data from URLs, 
  research a topic online, search the web and get full content, browse interactive pages,
  or any task involving "fetch this page", "get the content from", "scrape", "clone",
  "download site", "web to markdown". Handles JS-rendered pages, bypasses common blocks,
  and returns clean markdown optimized for LLM context windows.
  Do NOT trigger for local file operations, git commands, deployments, or code editing tasks.
metadata:
  version: 1.0.0
  author: NextHorizont AI (based on firecrawl/cli)
  source: https://github.com/firecrawl/cli
---

# Firecrawl Web Scraper

Web scraping, search, crawling, and browser automation via Firecrawl CLI.
Converts any webpage into clean, LLM-ready Markdown.

## Prerequisites

### 1. Firecrawl CLI must be installed

```bash
# Check if installed
command -v firecrawl

# If not installed:
npm install -g firecrawl-cli@latest
```

### 2. Authentication required

```bash
# Check auth status
firecrawl --status

# If not authenticated, one of these methods:

# Method A: API key directly (recommended for servers/CI)
firecrawl login --api-key fc-YOUR_API_KEY

# Method B: Environment variable
export FIRECRAWL_API_KEY=fc-YOUR_API_KEY

# Method C: Browser login (interactive, recommended for local dev)
firecrawl login --browser
```

**Get a free API key at:** https://firecrawl.dev (500 credits/month free tier)

---

## Decision Matrix: Which Command to Use

| Scenario | Command | When |
|----------|---------|------|
| Have a URL, want its content | `firecrawl scrape` | Single page extraction |
| Need to search the web first | `firecrawl search` | No specific URL yet |
| Want an entire site/docs | `firecrawl download` | Bulk site clone |
| Need all URLs from a domain | `firecrawl map` | Site discovery |
| Large site section | `firecrawl crawl` | Bulk with fine control |
| Page needs interaction (clicks, forms) | `firecrawl scrape` + `firecrawl interact` | Dynamic/interactive pages |
| Ask AI to find specific data | `firecrawl agent` | Natural language extraction |

---

## Command Reference

### SCRAPE — Extract content from a URL

```bash
# Basic scrape → clean markdown
firecrawl scrape https://example.com -o .firecrawl/page.md

# Main content only (removes nav, footer, ads)
firecrawl scrape https://example.com --only-main-content -o .firecrawl/clean.md

# Wait for JS rendering (SPAs, dynamic pages)
firecrawl scrape https://example.com --wait-for 3000 -o .firecrawl/spa.md

# Multiple formats at once (outputs JSON)
firecrawl scrape https://example.com --format markdown,links,images -o .firecrawl/full.json

# Get raw HTML
firecrawl scrape https://example.com --html -o .firecrawl/page.html

# Include/exclude specific HTML tags
firecrawl scrape https://example.com --include-tags article,main -o .firecrawl/article.md
firecrawl scrape https://example.com --exclude-tags nav,footer,.ad -o .firecrawl/clean.md

# Take a screenshot
firecrawl scrape https://example.com --screenshot -o .firecrawl/page.json

# Multiple URLs (scraped concurrently)
firecrawl scrape https://site1.com https://site2.com https://site3.com

# Pipe to stdout
firecrawl scrape https://example.com --only-main-content
```

**Key options:**
- `-o, --output <file>` — Save to file
- `-f, --format <formats>` — markdown, html, rawHtml, links, screenshot, json, images, summary, changeTracking, attributes, branding
- `-H, --html` — Shortcut for `--format html`
- `-S, --summary` — Shortcut for `--format summary`
- `--only-main-content` — Extract only main content
- `--wait-for <ms>` — Wait for JS rendering
- `--include-tags <tags>` — Only include these HTML tags
- `--exclude-tags <tags>` — Exclude these HTML tags
- `--screenshot` — Take screenshot
- `--pretty` — Pretty print JSON output

### SEARCH — Search the web + optionally scrape results

```bash
# Basic search
firecrawl search "carbon credits Spain CORSIA"

# Limit results
firecrawl search "GLP-1 obesity treatment" --limit 10

# Search + scrape all results (full content)
firecrawl search "firecrawl tutorials" --scrape --limit 5 -o .firecrawl/results/

# Search news sources
firecrawl search "tech startups" --sources news

# Search images
firecrawl search "landscape photography" --sources images

# Multiple sources
firecrawl search "machine learning" --sources web,news,images

# Filter by category
firecrawl search "web scraping python" --categories github
firecrawl search "transformer architecture" --categories research

# Time-based search
firecrawl search "AI announcements" --tbs qdr:d   # Past day
firecrawl search "tech news" --tbs qdr:w           # Past week

# Location-based search
firecrawl search "restaurants" --location "Madrid,Spain"
firecrawl search "local news" --country ES
```

### DOWNLOAD — Clone an entire website

```bash
# Interactive wizard (recommended)
firecrawl download https://docs.example.com

# Download with screenshots
firecrawl download https://docs.example.com --screenshot --limit 20 -y

# Full page screenshots
firecrawl download https://docs.example.com --full-page-screenshot --limit 20 -y

# Multiple formats per page
firecrawl download https://docs.example.com --format markdown,links --screenshot --limit 20 -y

# Main content only
firecrawl download https://docs.example.com --only-main-content --limit 50 -y

# Filter to specific paths
firecrawl download https://docs.example.com --include-paths "/api/**,/guide/**" --limit 100 -y

# Download as HTML
firecrawl download https://docs.example.com --html --limit 20 -y
```

### MAP — Discover all URLs on a domain

```bash
# Basic map
firecrawl map https://example.com

# Map with search (find specific pages)
firecrawl map https://example.com --search "pricing"

# Limit results
firecrawl map https://example.com --limit 100

# Save to file
firecrawl map https://example.com -o .firecrawl/sitemap.json
```

### CRAWL — Bulk extract with fine control

```bash
# Basic crawl
firecrawl crawl https://docs.example.com --wait --progress -o .firecrawl/docs.json

# Crawl with limits
firecrawl crawl https://docs.example.com --limit 50 --max-depth 2 --wait --progress

# Include/exclude paths
firecrawl crawl https://example.com --include-paths "/docs/**" --exclude-paths "/blog/**"
```

### INTERACT — Interact with scraped pages

```bash
# Scrape a page first, then interact
firecrawl scrape https://amazon.com -o .firecrawl/amazon.md

# Execute AI prompts against the page
firecrawl interact exec --prompt "Search for 'mechanical keyboard'"
firecrawl interact exec --prompt "Click the first result"
firecrawl interact exec --prompt "Extract the price"
```

### AGENT — AI-powered natural language extraction

```bash
# Ask AI to find specific data (no URL needed)
firecrawl agent "Find the pricing plans for Notion"
firecrawl agent "What are the latest AI regulations in the EU?"
```

---

## Workflow Patterns

### Pattern 1: Scrape single page → read content
```bash
mkdir -p .firecrawl
firecrawl scrape https://example.com --only-main-content -o .firecrawl/page.md
wc -l .firecrawl/page.md && head -50 .firecrawl/page.md
```

### Pattern 2: Research a topic → get full articles
```bash
mkdir -p .firecrawl
firecrawl search "topic query" --scrape --limit 5 -o .firecrawl/research.json
```

### Pattern 3: Clone entire documentation site
```bash
firecrawl download https://docs.example.com --only-main-content --limit 100 -y
```

### Pattern 4: Find then scrape specific page
```bash
mkdir -p .firecrawl
firecrawl map https://example.com --search "pricing" -o .firecrawl/urls.json
# Extract the URL from results, then scrape it
firecrawl scrape https://example.com/pricing --only-main-content -o .firecrawl/pricing.md
```

### Pattern 5: Parallel scraping (multiple pages concurrently)
```bash
mkdir -p .firecrawl
firecrawl scrape "https://site.com/page1" -o .firecrawl/1.md &
firecrawl scrape "https://site.com/page2" -o .firecrawl/2.md &
firecrawl scrape "https://site.com/page3" -o .firecrawl/3.md &
wait
```

### Pattern 6: Process search results with jq
```bash
mkdir -p .firecrawl
firecrawl search "query" --limit 10 -o .firecrawl/search.json --pretty
jq -r '.data.web[].url' .firecrawl/search.json
jq -r '.data.web[] | "\(.title): \(.url)"' .firecrawl/search.json
```

---

## Output Handling

- **Single format** → Raw content (markdown text, HTML, etc.)
- **Multiple formats** → JSON with all requested data
- Default output directory: `.firecrawl/` (auto-created)
- Add `.firecrawl/` to `.gitignore` to avoid committing scraped data

```bash
# Always validate output after scraping
wc -l .firecrawl/file.md && head -50 .firecrawl/file.md
grep -n "keyword" .firecrawl/file.md
```

---

## Credit Usage

Each scrape/crawl consumes credits. Monitor usage:

```bash
firecrawl credit-usage
firecrawl credit-usage --json --pretty -o .firecrawl/credits.json
```

Free tier: 500 credits/month. 1 scrape = 1 credit.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `command not found: firecrawl` | `npm install -g firecrawl-cli@latest` |
| `Not authenticated` | `firecrawl login --api-key fc-YOUR_KEY` |
| Empty/short output | Add `--wait-for 3000` for JS-heavy pages |
| Missing content | Try `--only-main-content` or `--include-tags article,main` |
| Rate limited | Check `firecrawl --status` for concurrency limits |
| Need full site | Use `download` instead of `scrape` |
