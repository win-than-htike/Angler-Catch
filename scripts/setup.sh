#!/bin/bash
#
# 🚀 Claude Code Auto-Implementer Setup
#
# This script sets up everything you need for automated GitHub issue implementation.
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║       🚀 Claude Code Auto-Implementer Setup               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get target directory
TARGET_DIR="${1:-.}"
if [ "$TARGET_DIR" = "." ]; then
    echo -e "${YELLOW}Installing to current directory${NC}"
else
    echo -e "${YELLOW}Installing to: ${TARGET_DIR}${NC}"
fi

echo ""

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "   ${RED}✗${NC} $1 - $2"
        return 1
    fi
}

MISSING=0
check_tool "git" "Install from https://git-scm.com" || MISSING=1
check_tool "gh" "Install with: brew install gh" || MISSING=1
check_tool "jq" "Install with: brew install jq" || MISSING=1
check_tool "claude" "Install with: npm install -g @anthropic-ai/claude-code" || MISSING=1
check_tool "node" "Install from https://nodejs.org" || MISSING=1

if [ $MISSING -eq 1 ]; then
    echo ""
    echo -e "${RED}Please install missing tools and run again.${NC}"
    exit 1
fi

echo ""

# Check GitHub CLI auth
echo -e "${BLUE}🔐 Checking GitHub authentication...${NC}"
if gh auth status >/dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} GitHub CLI authenticated"
else
    echo -e "   ${YELLOW}!${NC} GitHub CLI not authenticated"
    echo -e "   Running: ${CYAN}gh auth login${NC}"
    gh auth login
fi

echo ""

# Check Claude Code auth
echo -e "${BLUE}🔐 Checking Claude Code authentication...${NC}"
echo -e "   ${YELLOW}Note:${NC} Make sure you're logged in with your Max subscription"
echo -e "   If not logged in, run: ${CYAN}claude /login${NC}"

echo ""

# Create directories
echo -e "${BLUE}📁 Creating directories...${NC}"
mkdir -p "${TARGET_DIR}/.github/ISSUE_TEMPLATE"
mkdir -p "${TARGET_DIR}/.github/workflows"
mkdir -p "${TARGET_DIR}/scripts"
echo -e "   ${GREEN}✓${NC} Directories created"

# Copy files
echo ""
echo -e "${BLUE}📄 Copying files...${NC}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Copy issue templates
if [ -f "${SCRIPT_DIR}/../.github/ISSUE_TEMPLATE/feature.yml" ]; then
    cp "${SCRIPT_DIR}/../.github/ISSUE_TEMPLATE/"*.yml "${TARGET_DIR}/.github/ISSUE_TEMPLATE/"
    echo -e "   ${GREEN}✓${NC} Issue templates copied"
fi

# Copy workflow
if [ -f "${SCRIPT_DIR}/../.github/workflows/claude-implement.yml" ]; then
    cp "${SCRIPT_DIR}/../.github/workflows/claude-implement.yml" "${TARGET_DIR}/.github/workflows/"
    echo -e "   ${GREEN}✓${NC} GitHub Actions workflow copied"
fi

# Copy scripts
if [ -f "${SCRIPT_DIR}/watch-issues.sh" ]; then
    cp "${SCRIPT_DIR}/watch-issues.sh" "${TARGET_DIR}/scripts/"
    chmod +x "${TARGET_DIR}/scripts/watch-issues.sh"
    echo -e "   ${GREEN}✓${NC} Watch script copied"
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Make sure Claude Code is logged in:"
echo -e "   ${CYAN}claude /login${NC}"
echo ""
echo "2. Start the watcher:"
echo -e "   ${CYAN}cd ${TARGET_DIR}${NC}"
echo -e "   ${CYAN}./scripts/watch-issues.sh${NC}"
echo ""
echo "3. Create an issue on GitHub with one of the templates"
echo ""
echo "4. Watch Claude Code implement it automatically! 🎉"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
