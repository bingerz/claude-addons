#!/bin/bash

# Default value for KEEP_REPOS
KEEP_REPOS=false

# Process command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --keep-repos)
            KEEP_REPOS=true
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            shift
            ;;
    esac
done

# Global variable: whether to use proxy link
USE_PROXY=false
# Tool installation function (with version check)
install_tool() {
    local tool_name="$1"
    local check_command="$2"
    local install_command="$3"
    local version_command="$4"
    local version_pattern="$5"
    
    echo "Installing $tool_name tool..."
    if eval "$check_command" &> /dev/null; then
        echo "$tool_name is already installed, checking version..."
        if [ -n "$version_command" ]; then
            current_version=$(eval "$version_command" 2>&1)
            if [ -n "$version_pattern" ]; then
                current_version=$(echo "$current_version" | grep -E "$version_pattern" | head -1)
            else
                current_version=$(echo "$current_version" | head -1)
            fi
        else
            current_version="Installed"
        fi
        
        if [ -n "$current_version" ]; then
            echo "Current $tool_name version: $current_version"
            echo "✓ $tool_name tool is already installed"
        else
            echo "$tool_name version check failed, reinstalling..."
            eval "$install_command"
            echo "✓ $tool_name tool installation completed"
        fi
    else
        echo "$tool_name is not installed, starting installation..."
        eval "$install_command"
        echo "✓ $tool_name tool installation completed"
    fi
    echo ""
}

# Git repository processing function
process_repo() {
    local repo_name="$1"
    local repo_url_var="$2"
    
    echo "Processing $repo_name project..."
    if [ "$KEEP_REPOS" = "true" ] && [ -d "$repo_name/.git" ]; then
        git_operation "pull" "" "$repo_name"
    else
        echo "$repo_name directory does not exist or is not a git repository, starting clone..."
        rm -rf "$repo_name"
        local repo_url=$(get_repo_url "${!repo_url_var}")
        git_operation "clone" "$repo_url" "$repo_name"
    fi
    echo ""
}

# Skill installation function
install_skill() {
    local skill_name="$1"
    local source_dir="$2"
    local target_dir="$3"
    
    echo "Installing $skill_name..."
    mkdir -p "$target_dir"
    if [ -d "$source_dir" ]; then
        rm -rf "$target_dir"
        cp -r "$source_dir" "$target_dir"
        echo "✓ $skill_name installation completed"
    else
        echo "✗ $skill_name source directory does not exist"
    fi
    echo ""
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Original repository links
AGENTS_REPO="https://github.com/msitarzewski/agency-agents.git"
PLUGINS_REPO="https://github.com/anthropics/claude-plugins-official.git"
GSTACK_REPO="https://github.com/garrytan/gstack.git"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"
COMPOUND_ENGINEERING_REPO="https://github.com/EveryInc/compound-engineering-plugin.git"
GRAPHIFY_REPO="https://github.com/safishamsi/graphify.git"
CODE_REVIEW_GRAPH_REPO="https://github.com/tirth8205/code-review-graph.git"
GITNEXUS_REPO="https://github.com/abhigyanpatwari/GitNexus.git"
RTK_REPO="https://github.com/rtk-ai/rtk.git"
EVERYTHING_CLAUDE_CODE_REPO="https://github.com/affaan-m/everything-claude-code.git"

# GitHub acceleration tool
GITHUB_PROXY="https://gh-proxy.org"

# Global variable: whether to use proxy link
USE_PROXY=false

# Network test function
check_network() {
    local url="$1"
    local timeout=3
    
    if curl -s --max-time $timeout "$url" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Get repository link (based on network status)
get_repo_url() {
    local repo_url="$1"
    local proxy_url="$GITHUB_PROXY/$repo_url"
    
    # Check if the original link is already an accelerated link
    if [[ "$repo_url" == *"$GITHUB_PROXY"* ]]; then
        echo "Using accelerated link: $repo_url" >&2
        # Set global variable, subsequent repositories use accelerated links by default
        USE_PROXY=true
        echo "$repo_url"
        return
    fi
    
    # If already determined to use accelerated link, return directly
    if [ "$USE_PROXY" = "true" ]; then
        echo "Using accelerated link: $proxy_url" >&2
        echo "$proxy_url"
        return
    fi
    
    # Test original link
    if check_network "$repo_url"; then
        echo "Using original link: $repo_url" >&2
        echo "$repo_url"
    else
        echo "Using accelerated link: $proxy_url" >&2
        # Set global variable, subsequent repositories use accelerated links by default
        USE_PROXY=true
        echo "$proxy_url"
    fi
}

# Git operation function (with timeout and retry)
git_operation() {
    local operation="$1"
    local repo_url="$2"
    local target_dir="$3"
    local max_retries=1  # Reduce retry times to save time
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        echo "Attempting $operation ($((retry+1))/$max_retries)..."
        
        if [ "$operation" = "clone" ]; then
            if git clone --depth 1 "$repo_url" "$target_dir" 2>&1; then
                echo "✓ $operation successful"
                return 0
            else
                # Try using accelerated link
                echo "Trying accelerated link..."
                local proxy_url="$GITHUB_PROXY/$repo_url"
                if git clone --depth 1 "$proxy_url" "$target_dir" 2>&1; then
                    echo "✓ $operation successful (using accelerated link)"
                    # Set global variable, subsequent repositories use accelerated links by default
                    USE_PROXY=true
                    return 0
                fi
            fi
        elif [ "$operation" = "pull" ]; then
            cd "$target_dir"
            
            # Get original remote
            local original_remote=$(git remote get-url origin)
            
            # Check if original remote is already an accelerated link
            if [[ "$original_remote" == *"$GITHUB_PROXY"* ]]; then
                local is_proxy_remote=true
            else
                local is_proxy_remote=false
            fi
            
            # If global setting to use accelerated link, switch directly
            if [ "$USE_PROXY" = "true" ] && [ "$is_proxy_remote" = "false" ]; then
                echo "Using accelerated link for pull..."
                local proxy_remote="$GITHUB_PROXY/$original_remote"
                git remote set-url origin "$proxy_remote"
                
                if git pull 2>&1; then
                    # Restore original remote
                    git remote set-url origin "$original_remote"
                    cd "$SCRIPT_DIR"
                    echo "✓ $operation successful (using accelerated link)"
                    return 0
                fi
                
                # Restore original remote
                git remote set-url origin "$original_remote"
                cd "$SCRIPT_DIR"
                return 1
            fi
            
            # Try original pull
            if git pull 2>&1; then
                cd "$SCRIPT_DIR"
                echo "✓ $operation successful"
                return 0
            fi
            
            # If failed, try using accelerated link (if not already using)
            if [ "$is_proxy_remote" = "false" ]; then
                echo "Trying accelerated link..."
                local proxy_remote="$GITHUB_PROXY/$original_remote"
                git remote set-url origin "$proxy_remote"
                
                if git pull 2>&1; then
                    # Restore original remote
                    git remote set-url origin "$original_remote"
                    cd "$SCRIPT_DIR"
                    echo "✓ $operation successful (using accelerated link)"
                    # Set global variable, subsequent repositories use accelerated links by default
                    USE_PROXY=true
                    return 0
                fi
                
                # Restore original remote
                git remote set-url origin "$original_remote"
            fi
            
            cd "$SCRIPT_DIR"
        fi
        
        retry=$((retry+1))
        if [ $retry -lt $max_retries ]; then
            echo "Retrying..."
            sleep 2
        fi
    done
    
    echo "✗ $operation failed"
    return 1
}

echo "======================================"
echo "Claude Code Installation and Update Script"
echo "======================================"
echo ""

echo "======================================"
echo "Stage 1: Git Repository Update/Clone"
echo "======================================"
echo ""

# Process each Git repository
process_repo "agency-agents" "AGENTS_REPO"
process_repo "claude-plugins-official" "PLUGINS_REPO"
process_repo "gstack" "GSTACK_REPO"
process_repo "superpowers" "SUPERPOWERS_REPO"
process_repo "compound-engineering-plugin" "COMPOUND_ENGINEERING_REPO"
process_repo "graphify" "GRAPHIFY_REPO"
process_repo "code-review-graph" "CODE_REVIEW_GRAPH_REPO"
process_repo "GitNexus" "GITNEXUS_REPO"
process_repo "rtk" "RTK_REPO"
process_repo "everything-claude-code" "EVERYTHING_CLAUDE_CODE_REPO"

echo "======================================"
echo "Stage 2: Tool Installation"
echo "======================================"
echo ""

# Install each tool
install_tool "graphify" "command -v graphify" "cd graphify && pip install . && cd \"$SCRIPT_DIR\"" "graphify --version" ""
install_tool "code-review-graph" "command -v code-review-graph" "cd code-review-graph && pip install . && cd \"$SCRIPT_DIR\"" "code-review-graph --version" ""
install_tool "GitNexus" "command -v npx && npx gitnexus --version 2>&1 | grep -q 'version'" "npm install -g gitnexus" "npx gitnexus --version" "version.*[0-9]+\\.[0-9]+\\.[0-9]+"

# Install rtk tool
echo "Installing rtk tool..."
if command -v rtk &> /dev/null; then
    echo "rtk is already installed, checking version..."
    current_version=$(rtk --version 2>&1 | grep -E 'rtk [0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}')
    if [ -n "$current_version" ]; then
        echo "Current rtk version: $current_version"
        echo "✓ rtk tool is already installed"
    else
        echo "rtk version check failed, reinstalling..."
        if command -v brew &> /dev/null; then
            echo "Installing rtk using Homebrew..."
            brew install rtk
            if [ $? -eq 0 ]; then
                echo "✓ rtk tool installation completed"
            else
                echo "Homebrew installation failed, trying quick installation..."
                curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
                echo "✓ rtk tool installation completed"
            fi
        else
            echo "Homebrew not available, using quick installation..."
            curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
            echo "✓ rtk tool installation completed"
        fi
    fi
else
    echo "rtk is not installed, starting installation..."
    if command -v brew &> /dev/null; then
        echo "Installing rtk using Homebrew..."
        brew install rtk
        if [ $? -eq 0 ]; then
            echo "✓ rtk tool installation completed"
        else
            echo "Homebrew installation failed, trying quick installation..."
            curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
            echo "✓ rtk tool installation completed"
        fi
    else
        echo "Homebrew not available, using quick installation..."
        curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
        echo "✓ rtk tool installation completed"
    fi
fi
echo ""

echo "======================================"
echo "Stage 3: Skills Installation"
echo "======================================"
echo ""

# Install gstack skill
install_skill "gstack" "gstack" "$HOME/.claude/skills/gstack"
# Enter gstack directory and execute setup
cd "$HOME/.claude/skills/gstack"
./setup --host claude
cd "$SCRIPT_DIR"

# Install superpowers skills
echo "Installing superpowers skills..."
mkdir -p "$HOME/.claude/skills"
for skill_dir in superpowers/skills/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "  - Copying skill: $skill_name"
        rm -rf "$HOME/.claude/skills/$skill_name"
        cp -r "$skill_dir" "$HOME/.claude/skills/"
    fi
done
echo "✓ superpowers skills installation completed"
echo ""

# Install compound-engineering skills
echo "Installing compound-engineering skills..."
mkdir -p "$HOME/.claude/skills"
for skill_dir in compound-engineering-plugin/plugins/compound-engineering/skills/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "  - Copying skill: $skill_name"
        rm -rf "$HOME/.claude/skills/$skill_name"
        cp -r "$skill_dir" "$HOME/.claude/skills/"
    fi
done
echo "✓ compound-engineering skills installation completed"
echo ""

# Install graphify skill
echo "Installing graphify skill..."
graphify install --platform claude
echo "✓ graphify skill installation completed"
echo ""
echo ""
echo "Installing everything-claude-code skills..."
mkdir -p "$HOME/.claude/skills"
for skill_dir in everything-claude-code/skills/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "  - Copying skill: $skill_name"
        rm -rf "$HOME/.claude/skills/$skill_name"
        cp -r "$skill_dir" "$HOME/.claude/skills/"
    fi
done
echo "✓ everything-claude-code skills installation completed"

echo "======================================"
echo "Stage 4: Agents Installation"
echo "======================================"
echo ""

echo "Copying Agents to Claude configuration directory..."
mkdir -p "$HOME/.claude/agents"
cp -r agency-agents/* "$HOME/.claude/agents/"
echo "✓ Agents installation completed"
echo ""

echo "Copying compound-engineering agents to Claude configuration directory..."
mkdir -p "$HOME/.claude/agents"
cp -r compound-engineering-plugin/plugins/compound-engineering/agents/* "$HOME/.claude/agents/"
echo "✓ compound-engineering agents installation completed"
echo ""
echo ""
echo "Copying everything-claude-code agents to Claude configuration directory..."
mkdir -p "$HOME/.claude/agents"
cp -r everything-claude-code/agents/* "$HOME/.claude/agents/" 2>/dev/null || true
echo "✓ everything-claude-code agents installation completed"

echo "======================================"
echo "Stage 5: Plugins Installation"
echo "======================================"
echo ""

echo "Copying Plugins to Claude configuration directory..."
mkdir -p "$HOME/.claude/plugins/marketplaces"
cp -r claude-plugins-official/* "$HOME/.claude/plugins/marketplaces/claude-plugins-official"
echo "✓ Plugins installation completed"
echo ""

echo "======================================"
echo "Stage 6: Claude Plugins Installation"
echo "======================================"
echo ""

plugins=(
    "ralph-loop"
    "code-review"
    "code-simplifier"
    "security-guidance"
    "feature-dev"
    "rust-analyzer-lsp"
    "pyright-lsp"
)

echo "Installing Claude plugins..."
for plugin in "${plugins[@]}"; do
    echo "  - Installing plugin: $plugin"
    if claude plugin install "$plugin" 2>&1; then
        echo "    ✓ Installation successful"
    else
        echo "    ✗ Installation failed (plugin may not exist or marketplace not configured)"
    fi
done
echo "✓ Claude plugins installation completed"
echo ""
echo ""
echo "======================================"
echo "Stage 7: Rules Installation"
echo "======================================"
echo ""
echo "Installing everything-claude-code rules..."
mkdir -p "$HOME/.claude/rules"
cp -r everything-claude-code/rules/* "$HOME/.claude/rules/" 2>/dev/null || true
echo "✓ everything-claude-code rules installation completed"
echo ""
echo "======================================"
echo "Stage 8: Commands Installation"
echo "======================================"
echo ""
echo "Installing everything-claude-code commands..."
mkdir -p "$HOME/.claude/commands"
cp -r everything-claude-code/commands/* "$HOME/.claude/commands/" 2>/dev/null || true
echo "✓ everything-claude-code commands installation completed"

echo "======================================"
echo "✓ All installation steps completed!"
echo "======================================"
echo ""

# Clean up git repositories (if user chooses not to keep)
if [ "$KEEP_REPOS" = "false" ]; then
    echo "======================================"
echo "Cleaning up temporary files"
echo "======================================"
echo ""
echo "Deleting git repositories..."
    rm -rf agency-agents claude-plugins-official gstack superpowers compound-engineering-plugin graphify code-review-graph GitNexus rtk everything-claude-code
echo "✓ Cleanup completed"
echo ""
echo "Note: If you need to keep git repositories for future updates, please run the script with --keep-repos parameter."
echo ""
fi

echo "======================================"
echo "Usage Guide"
echo "======================================"
echo ""
echo "code-review-graph Usage Guide:"
echo "Please execute the following commands in the root directory of your code project:"
echo "  1. code-review-graph install --platform claude-code  # Configure code-review-graph"
echo "  2. code-review-graph build                         # Build codebase graph"
echo ""
echo "This way, Claude Code will only read relevant files when processing code, greatly reducing token usage."
echo ""
echo "GitNexus Usage Guide:"
echo "Please execute the following commands in the root directory of your code project:"
echo "  1. npx gitnexus analyze  # Analyze codebase and create knowledge graph"
echo "  2. npx gitnexus setup    # Configure MCP server (only need to execute once)"
echo ""
echo "This way, Claude Code will obtain a deep architectural view of the codebase, avoiding missing dependencies and breaking call chains."
echo ""
echo "rtk Usage Guide:"
echo "1. Initialize rtk (only need to execute once):"
echo "   rtk init -g  # Configure for Claude Code / Copilot"
echo "   rtk init -g --gemini  # Configure for Gemini CLI"
echo "   rtk init -g --codex  # Configure for Codex (OpenAI)"
echo ""
echo "2. Restart your AI tool, then test:"
echo "   git status  # Will be automatically rewritten to rtk git status"
echo ""
echo "This can reduce LLM token consumption by 60-90%, greatly improving code processing efficiency."
echo ""
echo ""
echo "======================================"
echo "everything-claude-code Usage Guide:"
echo "======================================"
echo ""
echo "everything-claude-code 是一个完整的 Claude Code 配置集合，包含："
echo "  - 13 个专业代理（planner, architect, tdd-guide, code-reviewer 等）"
echo "  - 43 个技能（coding-standards, backend-patterns, frontend-patterns 等）"
echo "  - 31 个命令（/tdd, /plan, /e2e, /code-review 等）"
echo "  - 规则、钩子、脚本和 MCP 配置"
echo ""
echo "快速开始："
echo "1. 使用斜杠命令尝试功能规划："
echo "   /plan \"添加用户认证\""
echo ""
echo "2. 查看所有可用命令："
echo "   /help"
echo ""
echo "3. 使用 TDD 工作流："
echo "   /tdd"
echo ""
echo "4. 代码审查："
echo "   /code-review"
echo ""
echo "有关详细信息，请参考：https://github.com/affaan-m/everything-claude-code"
