#!/bin/bash
#
# 🤖 Claude Code Auto-Implementer
# 
# This script watches for GitHub issues labeled 'claude-implement'
# and automatically implements them using Claude Code with your Max subscription.
#
# Usage: ./watch-issues.sh [repo] [poll-interval]
# Example: ./watch-issues.sh my-username/my-repo 60
#

# Don't exit on errors - we handle them with retry logic
set +e

# Configuration
REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")}"
POLL_INTERVAL="${2:-60}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         🤖 Claude Code Auto-Implementer                   ║"
echo "║                                                           ║"
echo "║  Watches GitHub issues and implements them automatically  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Validate requirements
check_requirements() {
    local missing=()
    
    command -v gh >/dev/null 2>&1 || missing+=("gh (GitHub CLI)")
    command -v claude >/dev/null 2>&1 || missing+=("claude (Claude Code)")
    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v jq >/dev/null 2>&1 || missing+=("jq")
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required tools:${NC}"
        for tool in "${missing[@]}"; do
            echo -e "   - $tool"
        done
        echo ""
        echo "Please install them and try again."
        exit 1
    fi
    
    # Check gh auth
    if ! gh auth status >/dev/null 2>&1; then
        echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
        echo "Run: gh auth login"
        exit 1
    fi
    
    # Check if in git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        echo "Please run this from your project directory."
        exit 1
    fi
}

# Get issue type from labels
get_issue_type() {
    local labels="$1"
    if echo "$labels" | grep -q "type:bug"; then
        echo "bug"
    elif echo "$labels" | grep -q "type:chore"; then
        echo "chore"
    else
        echo "feature"
    fi
}

# Get commit prefix
get_prefix() {
    case "$1" in
        bug) echo "fix" ;;
        chore) echo "chore" ;;
        *) echo "feat" ;;
    esac
}

# Get emoji
get_emoji() {
    case "$1" in
        bug) echo "🐛" ;;
        chore) echo "🔧" ;;
        *) echo "✨" ;;
    esac
}

# Generate implementation prompt
generate_prompt() {
    local type="$1"
    local number="$2"
    local title="$3"
    local body="$4"
    
    case "$type" in
        feature)
            cat <<EOF
# ✨ Feature Implementation

## Issue #${number}: ${title}

${body}

## Instructions
1. **Read CLAUDE.md first** to understand the project architecture, patterns, and conventions
2. Explore the codebase to understand existing structure
3. Implement this feature following existing patterns (Provider for state, GoRouter for navigation, etc.)
4. Add appropriate tests if test suite exists
5. Update documentation if needed

Please implement this feature now.
EOF
            ;;
        bug)
            cat <<EOF
# 🐛 Bug Fix

## Issue #${number}: ${title}

${body}

## Instructions
1. **Read CLAUDE.md first** to understand the project architecture and conventions
2. Locate the root cause of this bug
3. Fix it with minimal, focused changes following existing patterns
4. Add a regression test to prevent recurrence
5. Verify fix doesn't break other functionality

Please fix this bug now.
EOF
            ;;
        chore)
            cat <<EOF
# 🔧 Maintenance Task

## Issue #${number}: ${title}

${body}

## Instructions
1. **Read CLAUDE.md first** to understand the project architecture and conventions
2. Understand what needs to be changed
3. Make changes without altering functionality (unless specified)
4. Ensure all existing tests still pass
5. Update documentation if needed

Please complete this task now.
EOF
            ;;
    esac
}

# Process a single issue
process_issue() {
    local number="$1"
    local title="$2"
    local body="$3"
    local labels="$4"
    
    local type=$(get_issue_type "$labels")
    local prefix=$(get_prefix "$type")
    local emoji=$(get_emoji "$type")
    local branch="${prefix}/issue-${number}"
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${emoji} ${CYAN}Issue #${number}${NC}: ${title}"
    echo -e "   Type: ${YELLOW}${type}${NC}"
    
    # Check if branch already exists
    if git ls-remote --heads origin "$branch" 2>/dev/null | grep -q .; then
        echo -e "   ${YELLOW}⏭️  Branch already exists, skipping${NC}"
        return
    fi
    
    # Ensure we're on main/master
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    echo -e "   ${BLUE}📥 Updating ${default_branch}...${NC}"
    git checkout "$default_branch" 2>/dev/null || git checkout main 2>/dev/null || git checkout master 2>/dev/null
    git pull origin "$default_branch" 2>/dev/null || true
    
    # Create branch
    echo -e "   ${BLUE}🌿 Creating branch: ${branch}${NC}"
    git checkout -b "$branch"
    
    # Generate prompt and run Claude Code
    local prompt=$(generate_prompt "$type" "$number" "$title" "$body")
    
    echo -e "   ${BLUE}🤖 Running Claude Code...${NC}"
    echo -e "   ${CYAN}━━━━━━━━━━━ Claude Output ━━━━━━━━━━━${NC}"
    claude -p "$prompt" --dangerously-skip-permissions --verbose
    echo -e "   ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Run code review if there are changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "   ${BLUE}🔍 Running code review...${NC}"
        claude -p "Review the changes you just made. Check for:
- Bugs and errors
- Security issues
- Code quality problems
- Missing error handling

If you find issues, fix them now. If everything looks good, confirm." --dangerously-skip-permissions --verbose
    fi
    
    # Check for changes
    git add -A
    if git diff --staged --quiet; then
        echo -e "   ${RED}❌ No changes made${NC}"
        
        gh issue comment "$number" --repo "$REPO" --body "## ⚠️ No Changes Made

I couldn't determine what changes to make for this issue.

**Please provide:**
- More specific details
- Example code or pseudocode
- File locations if known

---
*🤖 Claude Code Bot*"
        
        gh issue edit "$number" --repo "$REPO" --remove-label "claude-implement"
        git checkout "$default_branch"
        git branch -D "$branch" 2>/dev/null || true
        return
    fi
    
    # Commit with retry logic
    echo -e "   ${BLUE}💾 Committing changes...${NC}"
    local max_retries=3
    local retry=0
    local commit_success=false

    while [ $retry -lt $max_retries ] && [ "$commit_success" = false ]; do
        if git commit -m "${prefix}: ${title} (#${number})" 2>&1; then
            commit_success=true
            echo -e "   ${GREEN}✅ Commit successful${NC}"
        else
            retry=$((retry + 1))
            echo -e "   ${YELLOW}⚠️ Commit failed (attempt $retry/$max_retries), attempting to fix...${NC}"

            # Run fixers manually
            echo -e "   ${BLUE}🔧 Running dart format...${NC}"
            dart format lib/ 2>/dev/null || true

            echo -e "   ${BLUE}🔧 Running dart fix...${NC}"
            dart fix --apply lib/ 2>/dev/null || true

            # Re-stage all changes
            git add -A

            # If still failing after manual fixes, ask Claude to fix
            if [ $retry -eq 2 ]; then
                echo -e "   ${BLUE}🤖 Asking Claude to fix remaining issues...${NC}"
                claude -p "The commit is failing due to pre-commit hook errors. Please check the staged files, fix any linting/formatting issues, and ensure the code passes dart analyze. Fix the issues now." --dangerously-skip-permissions --verbose
                git add -A
            fi
        fi
    done

    if [ "$commit_success" = false ]; then
        echo -e "   ${RED}❌ Commit failed after $max_retries attempts${NC}"
        gh issue comment "$number" --repo "$REPO" --body "## ⚠️ Commit Failed

The implementation was created but the commit failed after multiple retry attempts due to pre-commit hook errors.

**Branch:** \`${branch}\`

Please review and fix manually.

---
*🤖 Claude Code Bot*"
        git checkout "$default_branch"
        return
    fi

    # Push with retry
    echo -e "   ${BLUE}📤 Pushing to origin...${NC}"
    if ! git push origin "$branch" 2>&1; then
        echo -e "   ${YELLOW}⚠️ Push failed, retrying...${NC}"
        sleep 2
        git push origin "$branch" || {
            echo -e "   ${RED}❌ Push failed${NC}"
            gh issue comment "$number" --repo "$REPO" --body "## ⚠️ Push Failed

The commit succeeded but push failed. Branch \`${branch}\` exists locally.

---
*🤖 Claude Code Bot*"
            return
        }
    fi
    
    # Create PR
    echo -e "   ${BLUE}📝 Creating pull request...${NC}"
    local pr_url=$(gh pr create \
        --repo "$REPO" \
        --title "${emoji} ${title}" \
        --body "## ${emoji} Auto-implemented by Claude Code

Closes #${number}

### Type: \`${type}\`

### Files Changed
\`\`\`
$(git diff --name-only HEAD~1)
\`\`\`

### Review Checklist
- [ ] Code review completed
- [ ] Tests pass  
- [ ] Ready to merge

---
*🤖 Implemented using Claude Code with Max subscription*" \
        --base "$default_branch" \
        --head "$branch" 2>&1)
    
    # Comment on issue
    gh issue comment "$number" --repo "$REPO" --body "## ${emoji} Implementation Complete!

I've created a pull request: ${pr_url}

Please review and merge when ready.

---
*🤖 Claude Code Bot*"
    
    # Remove label to prevent re-processing
    gh issue edit "$number" --repo "$REPO" --remove-label "claude-implement"
    
    echo -e "   ${GREEN}✅ Done! PR: ${pr_url}${NC}"
    
    # Return to default branch
    git checkout "$default_branch"
}

# Process PR review comments
process_pr_review() {
    local pr_number="$1"
    local pr_title="$2"
    local pr_branch="$3"

    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🔄 ${CYAN}PR #${pr_number}${NC}: ${pr_title}"
    echo -e "   Branch: ${YELLOW}${pr_branch}${NC}"

    # Get inline code review comments
    local inline_comments=$(gh api "repos/${REPO}/pulls/${pr_number}/comments" --jq '.[] | {id: .id, path: .path, line: .line, body: .body, user: .user.login}' 2>/dev/null || echo "")

    # Get review threads (requested changes)
    local reviews=$(gh api "repos/${REPO}/pulls/${pr_number}/reviews" --jq '.[] | select(.state == "CHANGES_REQUESTED") | {id: .id, body: .body, user: .user.login}' 2>/dev/null || echo "")

    # Get PR issue comments (regular comments - exclude bot's own comments)
    local issue_comments=$(gh api "repos/${REPO}/issues/${pr_number}/comments" --jq '[.[] | select(.body | test("Claude Code Bot"; "i") | not)] | .[-5:] | .[] | {id: .id, body: .body, user: .user.login}' 2>/dev/null || echo "")

    # Combine all feedback
    local all_feedback=""

    if [ -n "$reviews" ]; then
        all_feedback+="## Review Comments (Changes Requested):\n"
        all_feedback+="$reviews\n\n"
    fi

    if [ -n "$inline_comments" ]; then
        all_feedback+="## Inline Code Comments:\n"
        all_feedback+="$inline_comments\n\n"
    fi

    if [ -n "$issue_comments" ]; then
        all_feedback+="## PR Comments:\n"
        all_feedback+="$issue_comments\n\n"
    fi

    if [ -z "$all_feedback" ]; then
        echo -e "   ${YELLOW}No review comments found${NC}"
        gh pr edit "$pr_number" --repo "$REPO" --remove-label "needs-changes" 2>/dev/null || true
        return
    fi

    echo -e "   ${GREEN}Found review feedback${NC}"

    # Get default branch
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    # Checkout PR branch
    echo -e "   ${BLUE}📥 Checking out PR branch...${NC}"
    git fetch origin "$pr_branch" 2>/dev/null || true
    git checkout "$pr_branch" 2>/dev/null || git checkout -b "$pr_branch" "origin/$pr_branch"
    git pull origin "$pr_branch" 2>/dev/null || true

    # Generate prompt for Claude
    local prompt=$(cat <<EOF
# 🔄 PR Review Fixes Required

## PR #${pr_number}: ${pr_title}

## Reviewer Feedback:
${all_feedback}

## Instructions
1. **Read CLAUDE.md first** to understand the project architecture
2. Read each review comment carefully
3. Make the requested changes to address ALL feedback
4. Follow existing code patterns and conventions
5. Do NOT remove or break existing functionality

Please fix all the issues mentioned in the review comments now.
EOF
)

    echo -e "   ${BLUE}🤖 Running Claude Code to fix review comments...${NC}"
    echo -e "   ${CYAN}━━━━━━━━━━━ Claude Output ━━━━━━━━━━━${NC}"
    claude -p "$prompt" --dangerously-skip-permissions --verbose
    echo -e "   ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check for changes
    git add -A
    if git diff --staged --quiet; then
        echo -e "   ${YELLOW}No changes made${NC}"
        gh pr comment "$pr_number" --repo "$REPO" --body "## ℹ️ Review Processed

I reviewed the feedback but couldn't determine what changes to make. Please provide more specific details.

---
*🤖 Claude Code Bot*"
        gh pr edit "$pr_number" --repo "$REPO" --remove-label "needs-changes"
        git checkout "$default_branch"
        return
    fi

    # Commit with retry logic
    echo -e "   ${BLUE}💾 Committing fixes...${NC}"
    local commit_success=false
    local retry=0
    local max_retries=3

    while [ $retry -lt $max_retries ] && [ "$commit_success" = false ]; do
        if git commit -m "fix: address PR review comments (#${pr_number})" 2>&1; then
            commit_success=true
            echo -e "   ${GREEN}✅ Commit successful${NC}"
        else
            retry=$((retry + 1))
            echo -e "   ${YELLOW}⚠️ Commit failed (attempt $retry/$max_retries), fixing...${NC}"
            dart format lib/ 2>/dev/null || true
            dart fix --apply lib/ 2>/dev/null || true
            git add -A

            if [ $retry -eq 2 ]; then
                claude -p "Fix any linting/formatting issues in the staged files." --dangerously-skip-permissions --verbose
                git add -A
            fi
        fi
    done

    if [ "$commit_success" = false ]; then
        echo -e "   ${RED}❌ Commit failed${NC}"
        git checkout "$default_branch"
        return
    fi

    # Push
    echo -e "   ${BLUE}📤 Pushing fixes...${NC}"
    if ! git push origin "$pr_branch" 2>&1; then
        echo -e "   ${YELLOW}⚠️ Push failed, retrying...${NC}"
        sleep 2
        git push origin "$pr_branch" || {
            echo -e "   ${RED}❌ Push failed${NC}"
            git checkout "$default_branch"
            return
        }
    fi

    # Comment on PR
    gh pr comment "$pr_number" --repo "$REPO" --body "## ✅ Review Comments Addressed

I've pushed fixes to address the review feedback:

\`\`\`
$(git diff --name-only HEAD~1)
\`\`\`

Please review the changes.

---
*🤖 Claude Code Bot*"

    # Remove label
    gh pr edit "$pr_number" --repo "$REPO" --remove-label "needs-changes"

    echo -e "   ${GREEN}✅ PR review comments addressed!${NC}"

    # Return to default branch
    git checkout "$default_branch"
}

# Main loop
main() {
    check_requirements
    
    if [ -z "$REPO" ]; then
        echo -e "${RED}❌ Could not determine repository${NC}"
        echo "Usage: $0 <owner/repo> [poll-interval]"
        exit 1
    fi
    
    echo -e "Repository: ${GREEN}${REPO}${NC}"
    echo -e "Poll interval: ${YELLOW}${POLL_INTERVAL}s${NC}"
    echo -e "\n${CYAN}Watching for:${NC}"
    echo -e "  • Issues with ${GREEN}'claude-implement'${NC} label"
    echo -e "  • PRs with ${GREEN}'needs-changes'${NC} label"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}\n"

    while true; do
        echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} Checking..."

        # ═══════════════════════════════════════════════════════
        # Check for issues with claude-implement label
        # ═══════════════════════════════════════════════════════
        echo -e "   ${BLUE}📋 Issues:${NC}"
        local issues=$(gh issue list \
            --repo "$REPO" \
            --label "claude-implement" \
            --state open \
            --json number,title,body,labels \
            --limit 10 2>/dev/null || echo "[]")

        local issue_count=$(echo "$issues" | jq length)

        if [ "$issue_count" -eq 0 ]; then
            echo -e "      ${YELLOW}No issues with 'claude-implement' label${NC}"
        else
            echo -e "      ${GREEN}Found ${issue_count} issue(s) to implement${NC}"

            # Process each issue
            echo "$issues" | jq -c '.[]' | while read -r issue; do
                local number=$(echo "$issue" | jq -r '.number')
                local title=$(echo "$issue" | jq -r '.title')
                local body=$(echo "$issue" | jq -r '.body')
                local labels=$(echo "$issue" | jq -r '[.labels[].name] | join(",")')

                process_issue "$number" "$title" "$body" "$labels"
            done
        fi

        # ═══════════════════════════════════════════════════════
        # Check for PRs with needs-changes label
        # ═══════════════════════════════════════════════════════
        echo -e "   ${BLUE}🔄 Pull Requests:${NC}"
        local prs=$(gh pr list \
            --repo "$REPO" \
            --label "needs-changes" \
            --state open \
            --json number,title,headRefName \
            --limit 10 2>/dev/null || echo "[]")

        local pr_count=$(echo "$prs" | jq length)

        if [ "$pr_count" -eq 0 ]; then
            echo -e "      ${YELLOW}No PRs with 'needs-changes' label${NC}"
        else
            echo -e "      ${GREEN}Found ${pr_count} PR(s) needing changes${NC}"

            # Process each PR
            echo "$prs" | jq -c '.[]' | while read -r pr; do
                local pr_number=$(echo "$pr" | jq -r '.number')
                local pr_title=$(echo "$pr" | jq -r '.title')
                local pr_branch=$(echo "$pr" | jq -r '.headRefName')

                process_pr_review "$pr_number" "$pr_title" "$pr_branch"
            done
        fi

        echo -e "${YELLOW}Next check in ${POLL_INTERVAL}s...${NC}\n"
        sleep "$POLL_INTERVAL"
    done
}

# Run
main
