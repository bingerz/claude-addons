#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 原始仓库链接
AGENTS_REPO="https://github.com/msitarzewski/agency-agents.git"
PLUGINS_REPO="https://github.com/anthropics/claude-plugins-official.git"
GSTACK_REPO="https://github.com/garrytan/gstack.git"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"
COMPOUND_ENGINEERING_REPO="https://github.com/EveryInc/compound-engineering-plugin.git"
GRAPHIFY_REPO="https://github.com/safishamsi/graphify.git"
CODE_REVIEW_GRAPH_REPO="https://github.com/tirth8205/code-review-graph.git"
GITNEXUS_REPO="https://github.com/abhigyanpatwari/GitNexus.git"
RTK_REPO="https://github.com/rtk-ai/rtk.git"

# GitHub加速工具
GITHUB_PROXY="https://gh-proxy.org"

# 全局变量：是否使用加速链接
USE_PROXY=false

# 网络测试函数
check_network() {
    local url="$1"
    local timeout=3
    
    if curl -s --max-time $timeout "$url" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# 获取仓库链接（根据网络状况）
get_repo_url() {
    local repo_url="$1"
    local proxy_url="$GITHUB_PROXY/$repo_url"
    
    # 检查原始链接是否已经是加速链接
    if [[ "$repo_url" == *"$GITHUB_PROXY"* ]]; then
        echo "使用加速链接: $repo_url" >&2
        # 设置全局变量，后续仓库默认使用加速链接
        USE_PROXY=true
        echo "$repo_url"
        return
    fi
    
    # 如果已经确定使用加速链接，直接返回
    if [ "$USE_PROXY" = "true" ]; then
        echo "使用加速链接: $proxy_url" >&2
        echo "$proxy_url"
        return
    fi
    
    # 测试原始链接
    if check_network "$repo_url"; then
        echo "使用原始链接: $repo_url" >&2
        echo "$repo_url"
    else
        echo "使用加速链接: $proxy_url" >&2
        # 设置全局变量，后续仓库默认使用加速链接
        USE_PROXY=true
        echo "$proxy_url"
    fi
}

# Git操作函数（带超时和重试）
git_operation() {
    local operation="$1"
    local repo_url="$2"
    local target_dir="$3"
    local max_retries=1  # 减少重试次数以节省时间
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        echo "尝试 $operation ($((retry+1))/$max_retries)..."
        
        if [ "$operation" = "clone" ]; then
            if git clone --depth 1 "$repo_url" "$target_dir" 2>&1; then
                echo "✓ $operation 成功"
                return 0
            else
                # 尝试使用加速链接
                echo "尝试使用加速链接..."
                local proxy_url="$GITHUB_PROXY/$repo_url"
                if git clone --depth 1 "$proxy_url" "$target_dir" 2>&1; then
                    echo "✓ $operation 成功（使用加速链接）"
                    # 设置全局变量，后续仓库默认使用加速链接
                    USE_PROXY=true
                    return 0
                fi
            fi
        elif [ "$operation" = "pull" ]; then
            cd "$target_dir"
            
            # 获取原始 remote
            local original_remote=$(git remote get-url origin)
            
            # 检查原始 remote 是否已经是加速链接
            if [[ "$original_remote" == *"$GITHUB_PROXY"* ]]; then
                local is_proxy_remote=true
            else
                local is_proxy_remote=false
            fi
            
            # 如果全局设置了使用加速链接，直接切换
            if [ "$USE_PROXY" = "true" ] && [ "$is_proxy_remote" = "false" ]; then
                echo "使用加速链接进行 pull..."
                local proxy_remote="$GITHUB_PROXY/$original_remote"
                git remote set-url origin "$proxy_remote"
                
                if git pull 2>&1; then
                    # 恢复原始 remote
                    git remote set-url origin "$original_remote"
                    cd "$SCRIPT_DIR"
                    echo "✓ $operation 成功（使用加速链接）"
                    return 0
                fi
                
                # 恢复原始 remote
                git remote set-url origin "$original_remote"
                cd "$SCRIPT_DIR"
                return 1
            fi
            
            # 尝试原始 pull
            if git pull 2>&1; then
                cd "$SCRIPT_DIR"
                echo "✓ $operation 成功"
                return 0
            fi
            
            # 如果失败，尝试使用加速链接（如果还没有使用）
            if [ "$is_proxy_remote" = "false" ]; then
                echo "尝试使用加速链接..."
                local proxy_remote="$GITHUB_PROXY/$original_remote"
                git remote set-url origin "$proxy_remote"
                
                if git pull 2>&1; then
                    # 恢复原始 remote
                    git remote set-url origin "$original_remote"
                    cd "$SCRIPT_DIR"
                    echo "✓ $operation 成功（使用加速链接）"
                    # 设置全局变量，后续仓库默认使用加速链接
                    USE_PROXY=true
                    return 0
                fi
                
                # 恢复原始 remote
                git remote set-url origin "$original_remote"
            fi
            
            cd "$SCRIPT_DIR"
        fi
        
        retry=$((retry+1))
        if [ $retry -lt $max_retries ]; then
            echo "重试中..."
            sleep 2
        fi
    done
    
    echo "✗ $operation 失败"
    return 1
}

echo "======================================"
echo "Claude Code 安装和更新脚本"
echo "======================================"
echo ""

echo "======================================"
echo "第一阶段: Git 仓库更新/克隆"
echo "======================================"
echo ""

echo "正在处理 agency-agents 项目..."
if [ -d "agency-agents/.git" ]; then
    git_operation "pull" "" "agency-agents"
else
    echo "agency-agents 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf agency-agents
    repo_url=$(get_repo_url "$AGENTS_REPO")
    git_operation "clone" "$repo_url" "agency-agents"
fi
echo ""

echo "正在处理 claude-plugins-official 项目..."
if [ -d "claude-plugins-official/.git" ]; then
    git_operation "pull" "" "claude-plugins-official"
else
    echo "claude-plugins-official 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf claude-plugins-official
    repo_url=$(get_repo_url "$PLUGINS_REPO")
    git_operation "clone" "$repo_url" "claude-plugins-official"
fi
echo ""

echo "正在处理 gstack 项目..."
if [ -d "gstack/.git" ]; then
    git_operation "pull" "" "gstack"
else
    echo "gstack 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf gstack
    repo_url=$(get_repo_url "$GSTACK_REPO")
    git_operation "clone" "$repo_url" "gstack"
fi
echo ""

echo "正在处理 superpowers 项目..."
if [ -d "superpowers/.git" ]; then
    git_operation "pull" "" "superpowers"
else
    echo "superpowers 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf superpowers
    repo_url=$(get_repo_url "$SUPERPOWERS_REPO")
    git_operation "clone" "$repo_url" "superpowers"
fi
echo ""

echo "正在处理 compound-engineering-plugin 项目..."
if [ -d "compound-engineering-plugin/.git" ]; then
    git_operation "pull" "" "compound-engineering-plugin"
else
    echo "compound-engineering-plugin 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf compound-engineering-plugin
    repo_url=$(get_repo_url "$COMPOUND_ENGINEERING_REPO")
    git_operation "clone" "$repo_url" "compound-engineering-plugin"
fi
echo ""

echo "正在处理 graphify 项目..."
if [ -d "graphify/.git" ]; then
    git_operation "pull" "" "graphify"
else
    echo "graphify 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf graphify
    repo_url=$(get_repo_url "$GRAPHIFY_REPO")
    git_operation "clone" "$repo_url" "graphify"
fi
echo ""

echo "正在处理 code-review-graph 项目..."
if [ -d "code-review-graph/.git" ]; then
    git_operation "pull" "" "code-review-graph"
else
    echo "code-review-graph 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf code-review-graph
    repo_url=$(get_repo_url "$CODE_REVIEW_GRAPH_REPO")
    git_operation "clone" "$repo_url" "code-review-graph"
fi
echo ""

echo "正在处理 GitNexus 项目..."
if [ -d "GitNexus/.git" ]; then
    git_operation "pull" "" "GitNexus"
else
    echo "GitNexus 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf GitNexus
    repo_url=$(get_repo_url "$GITNEXUS_REPO")
    git_operation "clone" "$repo_url" "GitNexus"
fi
echo ""

echo "正在处理 rtk 项目..."
if [ -d "rtk/.git" ]; then
    git_operation "pull" "" "rtk"
else
    echo "rtk 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf rtk
    repo_url=$(get_repo_url "$RTK_REPO")
    git_operation "clone" "$repo_url" "rtk"
fi
echo ""

echo "======================================"
echo "第二阶段: 工具安装"
echo "======================================"
echo ""

echo "正在安装 graphify 工具..."
cd graphify
pip install -e .
cd "$SCRIPT_DIR"
echo "✓ graphify 工具安装完成"
echo ""

echo "正在安装 code-review-graph 工具..."
cd code-review-graph
pip install -e .
cd "$SCRIPT_DIR"
echo "✓ code-review-graph 工具安装完成"
echo ""

echo "正在安装 GitNexus 工具..."
npm install -g gitnexus
echo "✓ GitNexus 工具安装完成"
echo ""

echo "正在安装 rtk 工具..."
if command -v brew &> /dev/null; then
    echo "使用 Homebrew 安装 rtk..."
    brew install rtk
    if [ $? -eq 0 ]; then
        echo "✓ rtk 工具安装完成"
    else
        echo "Homebrew 安装失败，尝试快速安装..."
        curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
        echo "✓ rtk 工具安装完成"
    fi
else
    echo "Homebrew 不可用，使用快速安装..."
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    echo "✓ rtk 工具安装完成"
fi
echo ""

echo "======================================"
echo "第三阶段: Skills 安装"
echo "======================================"
echo ""

echo "正在安装 gstack..."
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/gstack
cp -r gstack ~/.claude/skills/
cd ~/.claude/skills/gstack
./setup --host claude
cd "$SCRIPT_DIR"
echo "✓ gstack 安装完成"
echo ""

echo "正在安装 superpowers 技能..."
mkdir -p ~/.claude/skills
for skill_dir in superpowers/skills/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "  - 复制技能: $skill_name"
        rm -rf ~/.claude/skills/"$skill_name"
        cp -r "$skill_dir" ~/.claude/skills/
    fi
done
echo "✓ superpowers 技能安装完成"
echo ""

echo "正在安装 compound-engineering 技能..."
mkdir -p ~/.claude/skills
for skill_dir in compound-engineering-plugin/plugins/compound-engineering/skills/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "  - 复制技能: $skill_name"
        rm -rf ~/.claude/skills/"$skill_name"
        cp -r "$skill_dir" ~/.claude/skills/
    fi
done
echo "✓ compound-engineering 技能安装完成"
echo ""

echo "正在安装 graphify 技能..."
graphify install --platform claude
echo "✓ graphify 技能安装完成"
echo ""

echo "======================================"
echo "第四阶段: Agents 安装"
echo "======================================"
echo ""

echo "正在复制 Agents 到 Claude 配置目录..."
mkdir -p ~/.claude/agents
cp -r agency-agents/* ~/.claude/agents/
echo "✓ Agents 安装完成"
echo ""

echo "正在复制 compound-engineering agents 到 Claude 配置目录..."
mkdir -p ~/.claude/agents
cp -r compound-engineering-plugin/plugins/compound-engineering/agents/* ~/.claude/agents/
echo "✓ compound-engineering agents 安装完成"
echo ""

echo "======================================"
echo "第五阶段: Plugins 安装"
echo "======================================"
echo ""

echo "正在复制 Plugins 到 Claude 配置目录..."
mkdir -p ~/.claude/plugins/marketplaces
cp -r claude-plugins-official/* ~/.claude/plugins/marketplaces/claude-plugins-official
echo "✓ Plugins 安装完成"
echo ""

echo "======================================"
echo "第六阶段: Claude 插件安装"
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

echo "正在安装 Claude 插件..."
for plugin in "${plugins[@]}"; do
    echo "  - 安装插件: $plugin"
    claude plugin install "$plugin"
done
echo "✓ Claude 插件安装完成"
echo ""

echo "======================================"
echo "✓ 所有安装步骤完成!"
echo "======================================"
echo ""
echo "======================================"
echo "使用说明"
echo "======================================"
echo ""
echo "code-review-graph 使用指南:"
echo "请在具体的代码项目根目录中执行以下命令:"
echo "  1. code-review-graph install --platform claude-code  # 配置 code-review-graph"
echo "  2. code-review-graph build                         # 构建代码库图谱"
echo ""
echo "这样 Claude Code 在处理代码时会只读取相关文件，大幅减少 token 使用。"
echo ""
echo "GitNexus 使用指南:"
echo "请在具体的代码项目根目录中执行以下命令:"
echo "  1. npx gitnexus analyze  # 分析代码库并创建知识图谱"
echo "  2. npx gitnexus setup    # 配置 MCP 服务器（仅需执行一次）"
echo ""
echo "这样 Claude Code 会获得代码库的深度架构视图，避免遗漏依赖和破坏调用链。"
echo ""
echo "rtk 使用指南:"
echo "1. 初始化 rtk（仅需执行一次）:"
echo "   rtk init -g  # 为 Claude Code / Copilot 配置"
echo "   rtk init -g --gemini  # 为 Gemini CLI 配置"
echo "   rtk init -g --codex  # 为 Codex (OpenAI) 配置"
echo ""
echo "2. 重新启动你的 AI 工具，然后测试:"
echo "   git status  # 会自动重写为 rtk git status"
echo ""
echo "这样可以减少 LLM token 消耗 60-90%，大幅提高代码处理效率。"
echo ""