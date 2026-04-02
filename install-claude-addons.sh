#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AGENTS_REPO="https://github.com/msitarzewski/agency-agents.git"
PLUGINS_REPO="https://github.com/anthropics/claude-plugins-official.git"
GSTACK_REPO="https://github.com/garrytan/gstack.git"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"
COMPOUND_ENGINEERING_REPO="https://github.com/EveryInc/compound-engineering-plugin.git"

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
    cd agency-agents
    git pull
    cd ..
    echo "✓ agency-agents 更新完成"
else
    echo "agency-agents 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf agency-agents
    git clone "$AGENTS_REPO" agency-agents
    echo "✓ agency-agents clone 完成"
fi
echo ""

echo "正在处理 claude-plugins-official 项目..."
if [ -d "claude-plugins-official/.git" ]; then
    cd claude-plugins-official
    git pull
    cd ..
    echo "✓ claude-plugins-official 更新完成"
else
    echo "claude-plugins-official 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf claude-plugins-official
    git clone "$PLUGINS_REPO" claude-plugins-official
    echo "✓ claude-plugins-official clone 完成"
fi
echo ""

echo "正在处理 gstack 项目..."
if [ -d "gstack/.git" ]; then
    cd gstack
    git pull
    cd ..
    echo "✓ gstack 更新完成"
else
    echo "gstack 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf gstack
    git clone --single-branch --depth 1 "$GSTACK_REPO" gstack
    echo "✓ gstack clone 完成"
fi
echo ""

echo "正在处理 superpowers 项目..."
if [ -d "superpowers/.git" ]; then
    cd superpowers
    git pull
    cd ..
    echo "✓ superpowers 更新完成"
else
    echo "superpowers 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf superpowers
    git clone "$SUPERPOWERS_REPO" superpowers
    echo "✓ superpowers clone 完成"
fi
echo ""

echo "正在处理 compound-engineering-plugin 项目..."
if [ -d "compound-engineering-plugin/.git" ]; then
    cd compound-engineering-plugin
    git pull
    cd ..
    echo "✓ compound-engineering-plugin 更新完成"
else
    echo "compound-engineering-plugin 目录不存在或不是 git 仓库，开始 clone..."
    rm -rf compound-engineering-plugin
    git clone "$COMPOUND_ENGINEERING_REPO" compound-engineering-plugin
    echo "✓ compound-engineering-plugin clone 完成"
fi
echo ""

echo "======================================"
echo "第二阶段: Skills 安装"
echo "======================================"
echo ""

echo "正在安装 gstack..."
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/gstack
cp -r gstack ~/.claude/skills/
cd ~/.claude/skills/gstack
./setup
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

echo "======================================"
echo "第三阶段: Agents 安装"
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
echo "第四阶段: Plugins 安装"
echo "======================================"
echo ""

echo "正在复制 Plugins 到 Claude 配置目录..."
mkdir -p ~/.claude/plugins/marketplaces
cp -r claude-plugins-official/* ~/.claude/plugins/marketplaces/claude-plugins-official
echo "✓ Plugins 安装完成"
echo ""

echo "======================================"
echo "第五阶段: Claude 插件安装"
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