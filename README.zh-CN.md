# Claude Addons 安装脚本

[English Version](README.md)

## 脚本简介

这是一个用于管理 Claude Code 相关项目的安装和更新脚本，能够自动处理 Git 仓库的克隆/更新、工具安装、技能配置等操作。

## 主要功能

- **Git 仓库管理**：自动克隆或更新多个 Claude 相关项目
- **网络优化**：内置网络测试和 GitHub 加速链接，提高克隆成功率
- **工具安装**：自动安装 graphify、code-review-graph、GitNexus、rtk 等工具
- **技能配置**：自动复制和配置 gstack、superpowers、compound-engineering、agent-skills 等技能
- **版本检查**：避免重复安装同一个版本的工具
- **清理选项**：可选择是否保留 Git 仓库，保持目录整洁
- **错误处理**：插件安装失败时不会中断整个脚本执行
- **逐项目确认**：安装每个项目前显示详细信息并进行交互式确认
- **双语支持**：自动检测系统语言，显示中文或英文提示

## 支持的项目

- **Agents**：agency-agents、compound-engineering-plugin/agents、everything-claude-code/agents
- **Plugins**：claude-plugins-official、understand-anything、claude-for-legal
- **Skills**：gstack、superpowers/skills、compound-engineering-plugin/skills、graphify、agent-skills、everything-claude-code/skills
- **Tools**：graphify、code-review-graph、GitNexus、rtk
- **完整套件**：everything-claude-code（13 个代理 + 43 个技能 + 31 个命令 + 6 个规则）
- **知识图谱**：understand-anything（交互式代码可视化和分析）
- **法律工作流**：claude-for-legal（商业、公司、隐私、雇佣法律插件）

## 安装方法

### 方法一：直接下载脚本

1. 下载脚本到本地：
   ```bash
   curl -fsSL https://raw.githubusercontent.com/bingerz/claude-addons/master/install-claude-addons.sh -o install-claude-addons.sh
   ```

2. 赋予执行权限：
   ```bash
   chmod +x install-claude-addons.sh
   ```

3. 运行脚本：
   ```bash
   ./install-claude-addons.sh
   ```

### 方法二：直接执行（一键安装）

```bash
curl -fsSL https://raw.githubusercontent.com/bingerz/claude-addons/master/install-claude-addons.sh | sh -s -- --yes
```

> **注意**：`--yes` 参数会跳过所有交互式确认，自动安装所有项目。如需选择性安装，请下载脚本后手动运行。

## 使用方法

### 基本用法

- **默认模式**（安装后清理 Git 仓库）：
  ```bash
  ./install-claude-addons.sh
  ```

- **保留仓库模式**（保留 Git 仓库以便后续更新）：
  ```bash
  ./install-claude-addons.sh --keep-repos
  ```

- **跳过确认模式**（直接安装所有项目）：
  ```bash
  ./install-claude-addons.sh --yes
  ```

### 安装流程

1. **项目列表展示**：显示所有可用项目及其简要描述
2. **逐项目确认**：对每个项目显示详细信息，包括：
   - 类型（代理/技能/工具/插件）
   - 包含的组件及描述
   - 功能说明
3. **交互选项**：
   - `Y` - 安装此项目
   - `N` - 跳过此项目
   - `A` - 跳过所有剩余项目

### 工具使用指南

#### code-review-graph

1. 在代码项目根目录执行：
   ```bash
   code-review-graph install --platform claude-code  # 配置 code-review-graph
   code-review-graph build                         # 构建代码图谱
   ```

2. 用途：Claude Code 在处理代码时只会读取相关文件，大幅降低 token 使用。

#### GitNexus

1. 在代码项目根目录执行：
   ```bash
   npx gitnexus analyze  # 分析代码库并创建知识图谱
   npx gitnexus setup    # 配置 MCP 服务器（仅需执行一次）
   ```

2. 用途：帮助 Claude Code 深入理解代码架构，避免遗漏依赖和破坏调用链。

#### rtk

1. 初始化 rtk（仅需执行一次）：
   ```bash
   rtk init -g                     # 配置 Claude Code / Copilot
   rtk init -g --gemini            # 配置 Gemini CLI
   rtk init -g --codex             # 配置 Codex (OpenAI)
   ```

2. 重启 AI 工具后测试：
   ```bash
   git status  # 会自动重写为 rtk git status
   ```

3. 用途：减少 LLM token 消耗 60-90%，大幅提高代码处理效率。

#### graphify

1. 安装技能：
   ```bash
   graphify install --platform claude
   ```

2. 用途：提供代码可视化和分析功能，帮助更好地理解代码结构。

### 技能使用指南

#### gstack

- 安装后会自动配置到 Claude 的技能目录
- 可在 Claude Code 中激活 gstack 模式，获得更强大的代码分析能力
- 主要命令：/office-hours、/plan-ceo-review、/plan-design-review、/review、/ship

#### superpowers

- 包含多个专业技能，如前端开发、后端开发、数据分析等
- 安装后会自动复制到 Claude 的技能目录
- 主要技能：brainstorming、test-driven-development、systematic-debugging、using-git-worktrees

#### compound-engineering

- 提供工程相关的技能和代理
- 安装后会自动复制到 Claude 的技能和代理目录
- 主要命令：/ce:brainstorm、/ce:plan、/ce:build、/ce:review

#### agent-skills

- AI 智能体专业技能集合
- 增强代理能力和协作效率

#### understand-anything

- 知识图谱插件，用于代码可视化和分析
- 主要命令：/understand、/understand-dashboard、/understand-chat、/understand-diff
- 功能：交互式仪表板、引导式学习路径、模糊搜索、影响分析
- 用途：将代码库转换为交互式知识图谱，便于探索和理解

#### claude-for-legal

- Anthropic 官方法律工作流插件集
- 插件：commercial-legal、corporate-legal、employment-legal、privacy-legal、product-legal、regulatory-legal、litigation-legal、ip-legal、ai-governance-legal
- 功能：合同审查、NDA分类、尽职调查、DSAR响应、策略起草
- 用途：自动化公司法务、隐私、雇佣、监管等法律工作流程

#### everything-claude-code

- 完整的配置套件，包含全面的技能和命令
- 主要命令：/plan、/tdd、/code-review、/e2e、/help

## 使用技巧

1. **网络问题解决**：如果遇到 GitHub 连接问题，脚本会自动尝试使用加速链接。

2. **快速更新**：使用 `--keep-repos` 参数可以保留 Git 仓库，后续运行脚本时会自动 pull 最新代码。

3. **工具版本管理**：脚本会检查工具是否已安装，避免重复安装同一个版本。

4. **目录清理**：默认情况下，脚本会在安装完成后清理 Git 仓库，保持目录整洁。

5. **插件安装**：如果某些插件安装失败，脚本会继续执行其他任务，不会中断整个安装过程。

6. **环境变量**：脚本会自动检测系统环境，选择最合适的安装方式（如 Homebrew 或快速安装）。

7. **语言检测**：脚本自动检测系统语言，并相应地显示中文或英文提示。

## 注意事项

- 脚本需要网络连接才能克隆 Git 仓库和安装工具
- 部分工具需要 Python 或 Node.js 环境
- 首次运行可能需要较长时间，因为需要克隆多个仓库和安装多个工具
- 建议定期运行脚本以保持工具和技能的更新

## 故障排除

- **Git 克隆失败**：检查网络连接，脚本会自动尝试使用加速链接
- **工具安装失败**：检查 Python 或 Node.js 环境是否正常
- **插件安装失败**：某些插件可能不存在于 Claude 的插件市场，这是正常现象
- **技能配置失败**：检查目标目录权限是否正确
- **语言问题**：脚本使用系统语言设置（LANG、LC_ALL、LANGUAGE 环境变量）

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个脚本！

## 许可证

MIT License