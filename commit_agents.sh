#!/bin/bash

# Simple script to commit agent files
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create a .env file with your GitHub credentials."
    echo "See .env.example for the required format."
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Check required variables
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_REPO" ]; then
    echo -e "${RED}Error: Missing required variables in .env file${NC}"
    echo "Required: GITHUB_TOKEN, GITHUB_USERNAME, GITHUB_REPO"
    exit 1
fi

# Set default branch
BRANCH="${GITHUB_BRANCH:-main}"

echo -e "${BLUE}Committing agent files...${NC}"

# Navigate to script directory
cd "$SCRIPT_DIR"

# Add agent files, .gitignore, and the commit script itself
git add .github/agents/*.agent.md .gitignore commit_agents.sh

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${BLUE}No changes to commit.${NC}"
    exit 0
fi

# Show what will be committed
echo -e "${GREEN}Files to be committed:${NC}"
git diff --cached --name-only

# Create commit message
COMMIT_MSG="${1:-"Update agent files $(date '+%Y-%m-%d %H:%M:%S')"}"
echo -e "${BLUE}Commit message: ${COMMIT_MSG}${NC}"

# Commit changes
git commit -m "$COMMIT_MSG"

# Push to GitHub
REMOTE_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git"
echo -e "${BLUE}Pushing to GitHub...${NC}"
git push "$REMOTE_URL" "$BRANCH"

echo -e "${GREEN}✓ Successfully committed and pushed agent files!${NC}"
echo -e "${GREEN}Repository: https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}${NC}"