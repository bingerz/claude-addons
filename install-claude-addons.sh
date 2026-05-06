#!/bin/bash

# Default value for KEEP_REPOS
KEEP_REPOS=false
# Default value for UNINSTALL
UNINSTALL=false
# Default value for SKIP_CONFIRM
SKIP_CONFIRM=false

# Process command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --keep-repos)
            KEEP_REPOS=true
            shift
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        --yes|--skip-confirm|-y)
            SKIP_CONFIRM=true
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            shift
            ;;
    esac
done

# Check if uninstall mode is enabled
if [ "$UNINSTALL" = "true" ]; then
    echo "======================================"
    echo "Claude Addons Uninstall Script"
    echo "======================================"
    echo ""

    read -p "Are you sure you want to uninstall all Claude Addons? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    echo ""
    echo "======================================"
    echo "Stage 1: Removing Tools"
    echo "======================================"
    echo ""

    # Remove graphify
    echo "Removing graphify..."
    if command -v graphify &> /dev/null; then
        pip uninstall -y graphifyy 2>/dev/null || pip uninstall -y graphify 2>/dev/null || true
        echo "✓ graphify removed"
    else
        echo "- graphify is not installed"
    fi

    # Remove code-review-graph
    echo "Removing code-review-graph..."
    if command -v code-review-graph &> /dev/null; then
        pip uninstall -y code-review-graph 2>/dev/null || true
        echo "✓ code-review-graph removed"
    else
        echo "- code-review-graph is not installed"
    fi

    # Remove GitNexus
    echo "Removing GitNexus..."
    if command -v gitnexus &> /dev/null || npm list -g gitnexus &> /dev/null; then
        npm uninstall -g gitnexus 2>/dev/null || true
        echo "✓ GitNexus removed"
    else
        echo "- GitNexus is not installed"
    fi

    # Remove rtk
    echo "Removing rtk..."
    if command -v rtk &> /dev/null; then
        if command -v brew &> /dev/null; then
            brew uninstall rtk 2>/dev/null || true
        fi
        npm uninstall -g rtk 2>/dev/null || true
        rm -f /usr/local/bin/rtk 2>/dev/null || true
        rm -f /usr/bin/rtk 2>/dev/null || true
        echo "✓ rtk removed"
    else
        echo "- rtk is not installed"
    fi

    echo ""
    echo "======================================"
    echo "Stage 2: Removing Skills"
    echo "======================================"
    echo ""

    echo "Removing skills..."
    skills_to_remove=(
        "gstack"
        "coding-standards"
        "backend-patterns"
        "frontend-patterns"
        "continuous-learning"
        "continuous-learning-v2"
        "iterative-retrieval"
        "strategic-compact"
        "tdd-workflow"
        "security-review"
        "eval-harness"
        "verification-loop"
        "golang-patterns"
        "golang-testing"
        "cpp-testing"
        "compound-engineering"
        "graphify"
    )

    for skill in "${skills_to_remove[@]}"; do
        if [ -d "$HOME/.claude/skills/$skill" ]; then
            rm -rf "$HOME/.claude/skills/$skill"
            echo "  - Removed skill: $skill"
        fi
    done
    echo "✓ Skills removed"

    echo ""
    echo "======================================"
    echo "Stage 3: Removing Agents"
    echo "======================================"
    echo ""

    echo "Removing agents..."
    agents_to_remove=(
        "planner"
        "architect"
        "tdd-guide"
        "code-reviewer"
        "security-reviewer"
        "build-error-resolver"
        "e2e-runner"
        "refactor-cleaner"
        "doc-updater"
        "go-reviewer"
        "go-build-resolver"
        "frontend-developer"
        "backend-architect"
        "mobile-app-builder"
        "ai-engineer"
        "devops-automation-expert"
        "rapid-prototyper"
        "security-engineer"
        "database-optimizer"
        "technical-writer"
    )

    for agent in "${agents_to_remove[@]}"; do
        if [ -f "$HOME/.claude/agents/$agent.md" ]; then
            rm -f "$HOME/.claude/agents/$agent.md"
            echo "  - Removed agent: $agent"
        fi
    done
    echo "✓ Agents removed"

    echo ""
    echo "======================================"
    echo "Stage 4: Removing Rules"
    echo "======================================"
    echo ""

    echo "Removing rules..."
    rules_to_remove=(
        "security"
        "coding-style"
        "testing"
        "git-workflow"
        "agents"
        "performance"
    )

    for rule in "${rules_to_remove[@]}"; do
        if [ -f "$HOME/.claude/rules/$rule.md" ]; then
            rm -f "$HOME/.claude/rules/$rule.md"
            echo "  - Removed rule: $rule"
        fi
    done
    echo "✓ Rules removed"

    echo ""
    echo "======================================"
    echo "Stage 5: Removing Commands"
    echo "======================================"
    echo ""

    echo "Removing commands..."
    commands_to_remove=(
        "tdd"
        "plan"
        "e2e"
        "code-review"
        "build-fix"
        "refactor-clean"
        "learn"
        "checkpoint"
        "verify"
        "setup-pm"
        "go-review"
        "go-test"
        "go-build"
        "skill-create"
        "instinct-status"
        "instinct-import"
        "instinct-export"
        "evolve"
    )

    for cmd in "${commands_to_remove[@]}"; do
        if [ -f "$HOME/.claude/commands/$cmd.md" ]; then
            rm -f "$HOME/.claude/commands/$cmd.md"
            echo "  - Removed command: $cmd"
        fi
    done
    echo "✓ Commands removed"

    echo ""
    echo "======================================"
    echo "Stage 6: Removing Plugins"
    echo "======================================"
    echo ""

    echo "Removing Claude plugins..."
    plugins_to_remove=(
        "ralph-loop"
        "code-review"
        "code-simplifier"
        "security-guidance"
        "feature-dev"
        "rust-analyzer-lsp"
        "pyright-lsp"
    )

    for plugin in "${plugins_to_remove[@]}"; do
        if claude plugin list 2>/dev/null | grep -q "$plugin"; then
            claude plugin uninstall "$plugin" 2>/dev/null || true
            echo "  - Removed plugin: $plugin"
        fi
    done
    echo "✓ Claude plugins removed"

    echo ""
    echo "======================================"
    echo "Stage 7: Removing Plugin Marketplaces"
    echo "======================================"
    echo ""

    echo "Removing plugin marketplaces..."
    if [ -d "$HOME/.claude/plugins/marketplaces" ]; then
        rm -rf "$HOME/.claude/plugins/marketplaces/claude-plugins-official"
        rm -rf "$HOME/.claude/plugins/marketplaces/everything-claude-code"
        echo "✓ Plugin marketplaces removed"
    fi

    echo ""
    echo "======================================"
    echo "Stage 8: Cleaning Configuration Files"
    echo "======================================"
    echo ""

    echo "Cleaning configuration files..."
    # Remove hooks from settings.json if present
    if [ -f "$HOME/.claude/settings.json" ]; then
        echo "- settings.json preserved (manual cleanup required for hooks)"
    fi

    # Remove MCP configs
    if [ -f "$HOME/.claude.json" ]; then
        echo "- ~/.claude.json preserved (manual cleanup required for MCP configs)"
    fi

    echo "✓ Configuration files noted for manual cleanup"

    echo ""
    echo "======================================"
    echo "✓ Uninstall completed!"
    echo "======================================"
    echo ""
    echo "Note: Some configuration files may need manual cleanup:"
    echo "  - ~/.claude/settings.json (hooks)"
    echo "  - ~/.claude.json (MCP servers)"
    echo "  - ~/.claude/package-manager.json"
    echo ""
    echo "If you want to completely remove all Claude configurations, run:"
    echo "  rm -rf ~/.claude"
    echo ""

    exit 0
fi

# Global variable: whether to use proxy link
USE_PROXY=false

# Language detection function
detect_lang() {
    local lang="${LANG:-${LC_ALL:-${LANGUAGE:-}}}"
    case "$lang" in
        *zh*) echo "cn" ;;
        *CN*) echo "cn" ;;
        *) echo "en" ;;
    esac
}

# Confirm installation for a specific project
confirm_project_install() {
    local project_name="$1"
    local project_desc="$2"
    local project_type="$3"
    local project_components="$4"
    
    if [ "$SKIP_CONFIRM" = "true" ]; then
        return 0
    fi
    
    show_project_details "$project_name"
    
    echo ""
    read -p "  [Y] Install  [N] Skip  [A] Skip all: " -n 1 -r
    echo ""
    
    case $REPLY in
        [Yy])
            echo "✓ Installing $project_name..."
            return 0
            ;;
        [Nn])
            echo "- Skipping $project_name"
            return 1
            ;;
        [Aa])
            echo "- Skipping all remaining projects"
            exit 0
            ;;
        *)
            echo "- Invalid input, skipping $project_name"
            return 1
            ;;
    esac
}

# Show detailed project information
show_project_details() {
    local project_name="$1"
    local lang=$(detect_lang)
    
    echo ""
    echo "------------------------------------------------------------"
    
    case "$project_name" in
        agency-agents)
            if [ "$lang" = "cn" ]; then
                echo "安装 agency-agents? (代理)"
                echo "------------------------------------------------------------"
                echo "类型: 专业代理集合"
                echo ""
                echo "包含的代理:"
                echo "  • frontend-developer    - 前端开发专家"
                echo "  • backend-architect     - 后端架构师"
                echo "  • mobile-app-builder    - 移动应用开发"
                echo "  • ai-engineer           - AI工程师"
                echo "  • devops-automation-expert - DevOps自动化专家"
                echo "  • rapid-prototyper      - 快速原型开发"
                echo "  • security-engineer     - 安全工程师"
                echo "  • code-reviewer         - 代码审查员"
                echo "  • database-optimizer    - 数据库优化师"
                echo "  • technical-writer      - 技术文档撰写"
                echo ""
                echo "功能说明: 提供10+专业领域的AI代理，覆盖前后端开发、移动应用、AI工程、DevOps等场景"
            else
                echo "Install agency-agents? (Agents)"
                echo "------------------------------------------------------------"
                echo "Type: Professional Agent Collection"
                echo ""
                echo "Included agents:"
                echo "  • frontend-developer    - Frontend development expert"
                echo "  • backend-architect     - Backend architect"
                echo "  • mobile-app-builder    - Mobile app developer"
                echo "  • ai-engineer           - AI engineer"
                echo "  • devops-automation-expert - DevOps automation expert"
                echo "  • rapid-prototyper      - Rapid prototyping"
                echo "  • security-engineer     - Security engineer"
                echo "  • code-reviewer         - Code reviewer"
                echo "  • database-optimizer    - Database optimizer"
                echo "  • technical-writer      - Technical writer"
                echo ""
                echo "Description: Provides 10+ professional AI agents covering frontend/backend dev, mobile apps, AI engineering, DevOps, etc."
            fi
            ;;
        claude-plugins-official)
            if [ "$lang" = "cn" ]; then
                echo "安装 claude-plugins-official? (插件市场)"
                echo "------------------------------------------------------------"
                echo "类型: 官方插件仓库"
                echo ""
                echo "包含的插件:"
                echo "  • ralph-loop           - 循环优化助手"
                echo "  • code-review          - 代码审查工具"
                echo "  • code-simplifier      - 代码简化器"
                echo "  • security-guidance    - 安全性指导"
                echo "  • feature-dev          - 功能开发助手"
                echo "  • rust-analyzer-lsp    - Rust语言分析"
                echo "  • pyright-lsp          - Python类型检查"
                echo ""
                echo "功能说明: 官方插件仓库，支持代码审查、安全性指导、LSP语言服务集成等"
            else
                echo "Install claude-plugins-official? (Plugin Marketplace)"
                echo "------------------------------------------------------------"
                echo "Type: Official Plugin Repository"
                echo ""
                echo "Included plugins:"
                echo "  • ralph-loop           - Loop optimization assistant"
                echo "  • code-review          - Code review tool"
                echo "  • code-simplifier      - Code simplifier"
                echo "  • security-guidance    - Security guidance"
                echo "  • feature-dev          - Feature development assistant"
                echo "  • rust-analyzer-lsp    - Rust language analysis"
                echo "  • pyright-lsp          - Python type checking"
                echo ""
                echo "Description: Official plugin repository supporting code review, security guidance, LSP integration, etc."
            fi
            ;;
        gstack)
            if [ "$lang" = "cn" ]; then
                echo "安装 gstack? (技能)"
                echo "------------------------------------------------------------"
                echo "类型: Google风格工作流技能"
                echo ""
                echo "包含的技能:"
                echo "  • /office-hours        - 团队咨询时段安排"
                echo "  • /plan-ceo-review     - CEO视角审查计划"
                echo "  • /plan-design-review  - 设计方案审查"
                echo "  • /plan-eng-review     - 工程实现审查"
                echo "  • /design-consultation - 设计咨询"
                echo "  • /design-shotgun      - 设计发散讨论"
                echo "  • /design-html         - HTML设计实现"
                echo "  • /review              - 代码审查"
                echo "  • /investigate         - 问题调查分析"
                echo "  • /devex-review        - 开发者体验审查"
                echo "  • /qa                  - 质量保证测试"
                echo "  • /qa-only             - 仅QA测试"
                echo "  • /browse              - 代码浏览"
                echo "  • /ship                - 部署发布"
                echo "  • /land-and-deploy     - 完整部署流程"
                echo ""
                echo "功能说明: 15个专业技能，涵盖设计审查、代码审查、QA测试、部署发布等完整工作流"
            else
                echo "Install gstack? (Skills)"
                echo "------------------------------------------------------------"
                echo "Type: Google-style Workflow Skills"
                echo ""
                echo "Included skills:"
                echo "  • /office-hours        - Team office hours scheduling"
                echo "  • /plan-ceo-review     - CEO perspective review"
                echo "  • /plan-design-review  - Design review"
                echo "  • /plan-eng-review     - Engineering review"
                echo "  • /design-consultation - Design consultation"
                echo "  • /design-shotgun      - Design brainstorming"
                echo "  • /design-html         - HTML design implementation"
                echo "  • /review              - Code review"
                echo "  • /investigate         - Issue investigation"
                echo "  • /devex-review        - Developer experience review"
                echo "  • /qa                  - QA testing"
                echo "  • /qa-only             - QA only"
                echo "  • /browse              - Code browsing"
                echo "  • /ship                - Deployment"
                echo "  • /land-and-deploy     - Full deployment workflow"
                echo ""
                echo "Description: 15 professional skills covering design review, code review, QA testing, deployment, etc."
            fi
            ;;
        superpowers)
            if [ "$lang" = "cn" ]; then
                echo "安装 superpowers? (技能)"
                echo "------------------------------------------------------------"
                echo "类型: 进阶开发技能"
                echo ""
                echo "包含的技能:"
                echo "  • brainstorming                - 头脑风暴"
                echo "  • using-git-worktrees          - Git工作树使用"
                echo "  • writing-plans                - 编写计划文档"
                echo "  • subagent-driven-development  - 子代理驱动开发"
                echo "  • test-driven-development      - 测试驱动开发"
                echo "  • requesting-code-review       - 请求代码审查"
                echo "  • finishing-a-development-branch - 完成开发分支"
                echo ""
                echo "功能说明: 7个进阶技能，支持TDD开发、分支管理、子代理协作等高级工作流"
            else
                echo "Install superpowers? (Skills)"
                echo "------------------------------------------------------------"
                echo "Type: Advanced Development Skills"
                echo ""
                echo "Included skills:"
                echo "  • brainstorming                - Brainstorming"
                echo "  • using-git-worktrees          - Git worktrees"
                echo "  • writing-plans                - Plan writing"
                echo "  • subagent-driven-development  - Subagent-driven development"
                echo "  • test-driven-development      - Test-driven development"
                echo "  • requesting-code-review       - Code review request"
                echo "  • finishing-a-development-branch - Finish development branch"
                echo ""
                echo "Description: 7 advanced skills supporting TDD, branch management, subagent collaboration, etc."
            fi
            ;;
        compound-engineering)
            if [ "$lang" = "cn" ]; then
                echo "安装 compound-engineering? (技能+代理)"
                echo "------------------------------------------------------------"
                echo "类型: 复合工程工作流"
                echo ""
                echo "包含的技能:"
                echo "  • /ce:brainstorm      - 头脑风暴讨论"
                echo "  • /ce:plan            - 项目规划"
                echo "  • /ce:build           - 代码构建"
                echo "  • /ce:review          - 代码审查"
                echo "  • /ce:compound        - 复合工程集成"
                echo ""
                echo "功能说明: 复合工程工作流，支持头脑风暴、规划、构建、审查的完整闭环"
            else
                echo "Install compound-engineering? (Skills + Agents)"
                echo "------------------------------------------------------------"
                echo "Type: Compound Engineering Workflow"
                echo ""
                echo "Included skills:"
                echo "  • /ce:brainstorm      - Brainstorming"
                echo "  • /ce:plan            - Project planning"
                echo "  • /ce:build           - Code building"
                echo "  • /ce:review          - Code review"
                echo "  • /ce:compound        - Compound engineering integration"
                echo ""
                echo "Description: Compound engineering workflow supporting brainstorming, planning, building, and review"
            fi
            ;;
        graphify)
            if [ "$lang" = "cn" ]; then
                echo "安装 graphify? (工具+技能)"
                echo "------------------------------------------------------------"
                echo "类型: 知识图谱工具"
                echo ""
                echo "包含的组件:"
                echo "  • 多模态知识图谱构建器"
                echo "  • 图谱查询技能"
                echo ""
                echo "功能说明: 帮助构建代码库的知识图谱，理解代码结构和依赖关系，提升代码分析效率"
            else
                echo "Install graphify? (Tool + Skill)"
                echo "------------------------------------------------------------"
                echo "Type: Knowledge Graph Tool"
                echo ""
                echo "Included components:"
                echo "  • Multi-modal knowledge graph builder"
                echo "  • Graph query skills"
                echo ""
                echo "Description: Build knowledge graphs for codebases to understand structure and dependencies"
            fi
            ;;
        code-review-graph)
            if [ "$lang" = "cn" ]; then
                echo "安装 code-review-graph? (工具)"
                echo "------------------------------------------------------------"
                echo "类型: 代码审查图谱工具"
                echo ""
                echo "包含的组件:"
                echo "  • 本地知识图谱构建"
                echo "  • 代码分析优化"
                echo ""
                echo "功能说明: 为代码审查构建本地知识图谱，大幅降低代码分析时的token消耗"
            else
                echo "Install code-review-graph? (Tool)"
                echo "------------------------------------------------------------"
                echo "Type: Code Review Graph Tool"
                echo ""
                echo "Included components:"
                echo "  • Local knowledge graph building"
                echo "  • Code analysis optimization"
                echo ""
                echo "Description: Build local knowledge graphs for code review, reducing token usage significantly"
            fi
            ;;
        GitNexus)
            if [ "$lang" = "cn" ]; then
                echo "安装 GitNexus? (工具)"
                echo "------------------------------------------------------------"
                echo "类型: 代码智能引擎"
                echo ""
                echo "包含的组件:"
                echo "  • 零服务器代码智能引擎"
                echo "  • 代码库知识图谱"
                echo ""
                echo "功能说明: 从代码库自动构建知识图谱，帮助Claude深入理解代码架构和依赖关系"
            else
                echo "Install GitNexus? (Tool)"
                echo "------------------------------------------------------------"
                echo "Type: Code Intelligence Engine"
                echo ""
                echo "Included components:"
                echo "  • Serverless code intelligence engine"
                echo "  • Codebase knowledge graph"
                echo ""
                echo "Description: Automatically builds knowledge graphs from codebases to help Claude understand architecture"
            fi
            ;;
        rtk)
            if [ "$lang" = "cn" ]; then
                echo "安装 rtk? (工具)"
                echo "------------------------------------------------------------"
                echo "类型: Token优化工具"
                echo ""
                echo "包含的组件:"
                echo "  • 多平台支持 (Claude/Copilot/Gemini/Codex)"
                echo "  • 智能上下文压缩"
                echo ""
                echo "功能说明: 减少LLM token使用60-90%，支持多种AI工具，大幅提升代码处理效率"
            else
                echo "Install rtk? (Tool)"
                echo "------------------------------------------------------------"
                echo "Type: Token Optimization Tool"
                echo ""
                echo "Included components:"
                echo "  • Multi-platform support (Claude/Copilot/Gemini/Codex)"
                echo "  • Smart context compression"
                echo ""
                echo "Description: Reduces LLM token consumption by 60-90%, supports multiple AI tools"
            fi
            ;;
        everything-claude-code)
            if [ "$lang" = "cn" ]; then
                echo "安装 everything-claude-code? (完整套件)"
                echo "------------------------------------------------------------"
                echo "类型: 完整配置套件"
                echo ""
                echo "包含的组件:"
                echo "  • 13个代理: planner, architect, tdd-guide, code-reviewer等"
                echo "  • 43个技能: coding-standards, backend-patterns, frontend-patterns等"
                echo "  • 31个命令: /tdd, /plan, /e2e, /code-review等"
                echo "  • 6个规则: security, coding-style, testing, git-workflow等"
                echo ""
                echo "功能说明: 全面的Claude Code配置，包含规划、架构、TDD、安全审查等完整工作流"
            else
                echo "Install everything-claude-code? (Complete Suite)"
                echo "------------------------------------------------------------"
                echo "Type: Complete Configuration Suite"
                echo ""
                echo "Included components:"
                echo "  • 13 Agents: planner, architect, tdd-guide, code-reviewer, etc."
                echo "  • 43 Skills: coding-standards, backend-patterns, frontend-patterns, etc."
                echo "  • 31 Commands: /tdd, /plan, /e2e, /code-review, etc."
                echo "  • 6 Rules: security, coding-style, testing, git-workflow, etc."
                echo ""
                echo "Description: Comprehensive Claude Code configuration with planning, architecture, TDD, security review workflows"
            fi
            ;;
        agent-skills)
            if [ "$lang" = "cn" ]; then
                echo "安装 agent-skills? (技能)"
                echo "------------------------------------------------------------"
                echo "类型: AI代理技能集合"
                echo ""
                echo "包含的组件:"
                echo "  • AI智能体专业技能"
                echo "  • 工作流程优化技能"
                echo ""
                echo "功能说明: 提供AI代理的专业工作流程支持，增强代理能力和协作效率"
            else
                echo "Install agent-skills? (Skills)"
                echo "------------------------------------------------------------"
                echo "Type: AI Agent Skills Collection"
                echo ""
                echo "Included components:"
                echo "  • AI agent professional skills"
                echo "  • Workflow optimization skills"
                echo ""
                echo "Description: Provides professional workflow support for AI agents, enhancing capabilities and collaboration"
            fi
            ;;
        *)
            if [ "$lang" = "cn" ]; then
                echo "安装 $project_name?"
            else
                echo "Install $project_name?"
            fi
            echo "------------------------------------------------------------"
            echo "$project_components"
            ;;
    esac
}

# Tool installation function (with version check and timeout)
install_tool() {
    local tool_name="$1"
    local check_command="$2"
    local install_command="$3"
    local version_command="$4"
    local version_pattern="$5"
    local timeout=120  # 2 minutes timeout

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
            timeout $timeout eval "$install_command"
            echo "✓ $tool_name tool installation completed"
        fi
    else
        echo "$tool_name is not installed, starting installation..."
        timeout $timeout eval "$install_command"
        if [ $? -eq 124 ]; then
            echo "✗ $tool_name installation timed out, please install manually"
        else
            echo "✓ $tool_name tool installation completed"
        fi
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
AGENT_SKILLS_REPO="https://github.com/addyosmani/agent-skills.git"

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

# ======================================
# SECTION 1: PROJECT INTRODUCTION
# ======================================
echo "Claude Addons Installer"
echo "----------------------"
echo "Enhance Claude Code with tools, skills, agents and plugins."
echo ""
echo "Projects (11):"
echo "  [1] agency-agents           - 10+ Agents"
echo "  [2] claude-plugins-official - Plugin Marketplace"
echo "  [3] gstack                  - 15+ Skills"
echo "  [4] superpowers             - 7 Skills"
echo "  [5] compound-engineering    - 5 Skills + Agents"
echo "  [6] graphify                - Knowledge graph tool"
echo "  [7] code-review-graph       - Code review graph"
echo "  [8] GitNexus               - Code intelligence"
echo "  [9] rtk                    - Token optimizer"
echo " [10] everything-claude-code  - Complete Suite"
echo " [11] agent-skills            - AI agent skills"
echo ""
echo "Requires: Python 3.7+, Node.js 16+, Git 2.0+, Claude Code"
echo ""

# Track installed and skipped projects
INSTALLED_PROJECTS=""
SKIPPED_PROJECTS=""

# Process each Git repository with confirmation
if confirm_project_install "agency-agents" "" "Agents" "10+ professional agents"; then
    process_repo "agency-agents" "AGENTS_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS agency-agents"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS agency-agents"
fi

if confirm_project_install "claude-plugins-official" "" "Plugin Marketplace" "Official plugins repository"; then
    process_repo "claude-plugins-official" "PLUGINS_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS claude-plugins-official"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS claude-plugins-official"
fi

if confirm_project_install "gstack" "" "Skills" "15+ skills"; then
    process_repo "gstack" "GSTACK_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS gstack"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS gstack"
fi

if confirm_project_install "superpowers" "" "Skills" "7 skills (TDD, brainstorming)"; then
    process_repo "superpowers" "SUPERPOWERS_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS superpowers"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS superpowers"
fi

if confirm_project_install "compound-engineering-plugin" "" "Skills + Agents" "5 Skills + Agents"; then
    process_repo "compound-engineering-plugin" "COMPOUND_ENGINEERING_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS compound-engineering-plugin"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS compound-engineering-plugin"
fi

if confirm_project_install "graphify" "" "Tool" "Knowledge graph builder"; then
    process_repo "graphify" "GRAPHIFY_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS graphify"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS graphify"
fi

if confirm_project_install "code-review-graph" "" "Tool" "Code review graph"; then
    process_repo "code-review-graph" "CODE_REVIEW_GRAPH_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS code-review-graph"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS code-review-graph"
fi

if confirm_project_install "GitNexus" "" "Tool" "Code intelligence engine"; then
    process_repo "GitNexus" "GITNEXUS_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS GitNexus"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS GitNexus"
fi

if confirm_project_install "rtk" "" "Tool" "Token optimizer (60-90% reduction)"; then
    process_repo "rtk" "RTK_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS rtk"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS rtk"
fi

if confirm_project_install "everything-claude-code" "" "Suite" "Agents+Skills+Commands+Rules"; then
    process_repo "everything-claude-code" "EVERYTHING_CLAUDE_CODE_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS everything-claude-code"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS everything-claude-code"
fi

if confirm_project_install "agent-skills" "" "Skills" "AI agent skills collection"; then
    process_repo "agent-skills" "AGENT_SKILLS_REPO"
    INSTALLED_PROJECTS="$INSTALLED_PROJECTS agent-skills"
else
    SKIPPED_PROJECTS="$SKIPPED_PROJECTS agent-skills"
fi

# Check if a project was installed
project_installed() {
    echo "$INSTALLED_PROJECTS" | grep -q "$1"
    return $?
}

# ======================================
# STAGE 2: TOOL INSTALLATION
# ======================================
echo "======================================"
echo "Stage 2: Tool Installation"
echo "======================================"
echo ""

# Install each tool only if its project was selected
if project_installed "graphify"; then
    install_tool "graphify" "command -v graphify" "cd graphify && pip install . && cd \"$SCRIPT_DIR\"" "graphify --version" ""
else
    echo "- Skipping graphify tool (project not selected)"
fi

if project_installed "code-review-graph"; then
    install_tool "code-review-graph" "command -v code-review-graph" "cd code-review-graph && pip install . && cd \"$SCRIPT_DIR\"" "code-review-graph --version" ""
else
    echo "- Skipping code-review-graph tool (project not selected)"
fi

if project_installed "GitNexus"; then
    install_tool "GitNexus" "npm list -g gitnexus &> /dev/null" "npm install -g gitnexus" "gitnexus --version" "version.*[0-9]+\\.[0-9]+\\.[0-9]+"
else
    echo "- Skipping GitNexus tool (project not selected)"
fi

# Install rtk tool
if project_installed "rtk"; then
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
else
    echo "- Skipping rtk tool (project not selected)"
fi
echo ""

# ======================================
# STAGE 3: SKILLS INSTALLATION
# ======================================
echo "======================================"
echo "Stage 3: Skills Installation"
echo "======================================"
echo ""

# Install gstack skill
if project_installed "gstack"; then
    install_skill "gstack" "gstack" "$HOME/.claude/skills/gstack"
    # Enter gstack directory and execute setup
    cd "$HOME/.claude/skills/gstack"
    ./setup --host claude
    cd "$SCRIPT_DIR"
else
    echo "- Skipping gstack skills (project not selected)"
fi

# Install superpowers skills
if project_installed "superpowers"; then
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
else
    echo "- Skipping superpowers skills (project not selected)"
    echo ""
fi

# Install compound-engineering skills
if project_installed "compound-engineering-plugin"; then
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
else
    echo "- Skipping compound-engineering skills (project not selected)"
    echo ""
fi

# Install graphify skill
if project_installed "graphify"; then
    echo "Installing graphify skill..."
    graphify install --platform claude
    echo "✓ graphify skill installation completed"
    echo ""
else
    echo "- Skipping graphify skill (project not selected)"
    echo ""
fi

if project_installed "everything-claude-code"; then
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
else
    echo "- Skipping everything-claude-code skills (project not selected)"
fi

# Install agent-skills
if project_installed "agent-skills"; then
    echo "Installing agent-skills..."
    mkdir -p "$HOME/.claude/skills"
    for skill_dir in agent-skills/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            echo "  - Copying skill: $skill_name"
            rm -rf "$HOME/.claude/skills/$skill_name"
            cp -r "$skill_dir" "$HOME/.claude/skills/"
        fi
    done
    echo "✓ agent-skills installation completed"
else
    echo "- Skipping agent-skills (project not selected)"
fi

# ======================================
# STAGE 4: AGENTS INSTALLATION
# ======================================
echo ""
echo "======================================"
echo "Stage 4: Agents Installation"
echo "======================================"
echo ""

if project_installed "agency-agents"; then
    echo "Copying Agents to Claude configuration directory..."
    mkdir -p "$HOME/.claude/agents"
    cp -r agency-agents/* "$HOME/.claude/agents/"
    echo "✓ Agents installation completed"
    echo ""
else
    echo "- Skipping agency-agents (project not selected)"
    echo ""
fi

if project_installed "compound-engineering-plugin"; then
    echo "Copying compound-engineering agents to Claude configuration directory..."
    mkdir -p "$HOME/.claude/agents"
    cp -r compound-engineering-plugin/plugins/compound-engineering/agents/* "$HOME/.claude/agents/"
    echo "✓ compound-engineering agents installation completed"
    echo ""
else
    echo "- Skipping compound-engineering agents (project not selected)"
    echo ""
fi

if project_installed "everything-claude-code"; then
    echo "Copying everything-claude-code agents to Claude configuration directory..."
    mkdir -p "$HOME/.claude/agents"
    cp -r everything-claude-code/agents/* "$HOME/.claude/agents/" 2>/dev/null || true
    echo "✓ everything-claude-code agents installation completed"
    echo ""
else
    echo "- Skipping everything-claude-code agents (project not selected)"
    echo ""
fi

# ======================================
# STAGE 5: PLUGINS INSTALLATION
# ======================================
echo "======================================"
echo "Stage 5: Plugins Installation"
echo "======================================"
echo ""

if project_installed "claude-plugins-official"; then
    echo "Copying Plugins to Claude configuration directory..."
    mkdir -p "$HOME/.claude/plugins/marketplaces"
    cp -r claude-plugins-official/* "$HOME/.claude/plugins/marketplaces/claude-plugins-official"
    echo "✓ Plugins installation completed"
    echo ""
else
    echo "- Skipping claude-plugins-official (project not selected)"
    echo ""
fi

# ======================================
# STAGE 6: CLAUDE PLUGINS INSTALLATION
# ======================================
echo "======================================"
echo "Stage 6: Claude Plugins Installation"
echo "======================================"
echo ""

if project_installed "claude-plugins-official"; then
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
else
    echo "- Skipping Claude plugins installation (claude-plugins-official not selected)"
    echo ""
fi

# ======================================
# STAGE 7: RULES INSTALLATION
# ======================================
echo "======================================"
echo "Stage 7: Rules Installation"
echo "======================================"
echo ""
if project_installed "everything-claude-code"; then
    echo "Installing everything-claude-code rules..."
    mkdir -p "$HOME/.claude/rules"
    cp -r everything-claude-code/rules/* "$HOME/.claude/rules/" 2>/dev/null || true
    echo "✓ everything-claude-code rules installation completed"
else
    echo "- Skipping everything-claude-code rules (project not selected)"
fi
echo ""

# ======================================
# STAGE 8: COMMANDS INSTALLATION
# ======================================
echo "======================================"
echo "Stage 8: Commands Installation"
echo "======================================"
echo ""
if project_installed "everything-claude-code"; then
    echo "Installing everything-claude-code commands..."
    mkdir -p "$HOME/.claude/commands"
    cp -r everything-claude-code/commands/* "$HOME/.claude/commands/" 2>/dev/null || true
    echo "✓ everything-claude-code commands installation completed"
else
    echo "- Skipping everything-claude-code commands (project not selected)"
fi

# ======================================
# INSTALLATION COMPLETED
# ======================================
echo "======================================"
echo "✓ Installation completed!"
echo "======================================"
echo ""

# Show installation summary
echo "Installation Summary:"
echo "---------------------"
echo "Installed projects:"
if [ -n "$INSTALLED_PROJECTS" ]; then
    for project in $INSTALLED_PROJECTS; do
        echo "  ✓ $project"
    done
else
    echo "  (none)"
fi

echo ""
echo "Skipped projects:"
if [ -n "$SKIPPED_PROJECTS" ]; then
    for project in $SKIPPED_PROJECTS; do
        echo "  - $project"
    done
else
    echo "  (none)"
fi
echo ""

# Clean up git repositories (if user chooses not to keep)
if [ "$KEEP_REPOS" = "false" ]; then
    echo "======================================"
    echo "Cleaning up temporary files"
    echo "======================================"
    echo ""
    echo "Deleting git repositories..."
    for project in $INSTALLED_PROJECTS; do
        rm -rf "$project"
        echo "  - Deleted: $project"
    done
    echo "✓ Cleanup completed"
    echo ""
    echo "Note: If you need to keep git repositories for future updates, please run the script with --keep-repos parameter."
    echo ""
fi

# ======================================
# USAGE GUIDE
# ======================================
show_usage_guide() {
    local lang=$(detect_lang)
    
    if [ "$lang" = "cn" ]; then
        echo "======================================"
        echo "使用指南"
        echo "======================================"
        echo ""
        echo "--- 代理 (Agents) ---"
        echo "已安装的代理：planner, architect, tdd-guide, code-reviewer,"
        echo "security-reviewer, frontend-developer, backend-architect 等"
        echo "用法：在 Claude Code 中直接提及代理名称即可激活"
        echo ""
        echo "--- 技能 (Skills) ---"
        echo "可用的斜杠命令："
        echo "  /office-hours    - 团队咨询时段"
        echo "  /plan-ceo-review - CEO 视角审查计划"
        echo "  /plan-design-review - 设计审查"
        echo "  /plan-eng-review - 工程审查"
        echo "  /review          - 代码审查"
        echo "  /investigate     - 问题调查"
        echo "  /ship            - 部署发布"
        echo "  /tdd             - TDD 开发流程"
        echo "  /plan            - 功能规划"
        echo "  /code-review     - 代码审查"
        echo "  /e2e             - 端到端测试"
        echo "  /help            - 显示所有命令"
        echo ""
        echo "--- 插件 (Plugins) ---"
        echo "已安装 Claude 插件：ralph-loop, code-review, code-simplifier,"
        echo "security-guidance, feature-dev, rust-analyzer-lsp, pyright-lsp"
        echo "用法：claude plugin list  # 查看已安装插件"
        echo ""
        echo "--- 规则 (Rules) ---"
        echo "已安装规则：security, coding-style, testing, git-workflow, agents"
        echo "用法：规则自动应用于相关文件类型的分析"
        echo ""
        echo "--- 工具 (Tools) ---"
        echo ""
        echo "code-review-graph:"
        echo "  在项目根目录：code-review-graph install --platform claude-code"
        echo "                code-review-graph build"
        echo "  提示：降低代码审查的 token 消耗"
        echo ""
        echo "graphify:"
        echo "  在项目根目录：graphify --help"
        echo "  提示：构建知识图谱帮助理解代码结构"
        echo ""
        echo "GitNexus:"
        echo "  在项目根目录：npx gitnexus analyze  # 分析代码"
        echo "                npx gitnexus setup    # 配置 MCP"
        echo "  提示：深入理解代码架构和依赖关系"
        echo ""
        echo "rtk:"
        echo "  初始化：rtk init -g              # Claude Code"
        echo "         rtk init -g --gemini     # Gemini"
        echo "         rtk init -g --codex      # Codex"
        echo "  测试：git status  # 自动优化"
        echo "  提示：减少 60-90% token 消耗"
        echo ""
        echo "详细说明："
        echo "  https://github.com/affaan-m/everything-claude-code"
        echo "  https://github.com/addyosmani/agent-skills"
    else
        echo "======================================"
        echo "Usage Guide"
        echo "======================================"
        echo ""
        echo "--- Agents ---"
        echo "Installed agents: planner, architect, tdd-guide, code-reviewer,"
        echo "security-reviewer, frontend-developer, backend-architect, etc."
        echo "Usage: Mention agent name directly in Claude Code"
        echo ""
        echo "--- Skills ---"
        echo "Available slash commands:"
        echo "  /office-hours    - Team consultation"
        echo "  /plan-ceo-review - CEO review"
        echo "  /plan-design-review - Design review"
        echo "  /plan-eng-review - Engineering review"
        echo "  /review          - Code review"
        echo "  /investigate     - Issue investigation"
        echo "  /ship            - Deploy & release"
        echo "  /tdd             - TDD workflow"
        echo "  /plan            - Feature planning"
        echo "  /code-review     - Code review"
        echo "  /e2e             - End-to-end testing"
        echo "  /help            - Show all commands"
        echo ""
        echo "--- Plugins ---"
        echo "Installed plugins: ralph-loop, code-review, code-simplifier,"
        echo "security-guidance, feature-dev, rust-analyzer-lsp, pyright-lsp"
        echo "Usage: claude plugin list  # List installed plugins"
        echo ""
        echo "--- Rules ---"
        echo "Installed rules: security, coding-style, testing, git-workflow, agents"
        echo "Usage: Automatically applied when analyzing relevant file types"
        echo ""
        echo "--- Tools ---"
        echo ""
        echo "code-review-graph:"
        echo "  In project root: code-review-graph install --platform claude-code"
        echo "                  code-review-graph build"
        echo "  Tip: Reduces token usage in code reviews"
        echo ""
        echo "graphify:"
        echo "  In project root: graphify --help"
        echo "  Tip: Build knowledge graphs to understand code structure"
        echo ""
        echo "GitNexus:"
        echo "  In project root: npx gitnexus analyze  # Analyze code"
        echo "                  npx gitnexus setup    # Configure MCP"
        echo "  Tip: Deep understanding of code architecture"
        echo ""
        echo "rtk:"
        echo "  Init: rtk init -g              # Claude Code"
        echo "       rtk init -g --gemini     # Gemini"
        echo "       rtk init -g --codex      # Codex"
        echo "  Test: git status  # Auto-optimized"
        echo "  Tip: Reduces token consumption by 60-90%"
        echo ""
        echo "Details:"
        echo "  https://github.com/affaan-m/everything-claude-code"
        echo "  https://github.com/addyosmani/agent-skills"
    fi
}

show_usage_guide
