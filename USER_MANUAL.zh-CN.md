# Claude Addons 使用手册

## 1. 项目概述

Claude Addons 是一个用于管理 Claude Code 相关项目的工具集，能够自动处理 Git 仓库的克隆/更新、工具安装、技能配置等操作。本手册将详细介绍各个 addons 的功能、安装方法和使用技巧，帮助您充分发挥这些工具的价值。

### 1.1 主要功能

- **Git 仓库管理**：自动克隆或更新多个 Claude 相关项目
- **网络优化**：内置网络测试和 GitHub 加速链接，提高克隆成功率
- **工具安装**：自动安装 graphify、code-review-graph、GitNexus、rtk 等工具
- **技能配置**：自动复制和配置 gstack、superpowers、compound-engineering 等技能
- **版本检查**：避免重复安装同一个版本的工具
- **清理选项**：可选择是否保留 Git 仓库，保持目录整洁
- **错误处理**：插件安装失败时不会中断整个脚本执行

### 1.2 支持的项目

- **Agents**：agency-agents、compound-engineering-plugin/agents
- **Plugins**：claude-plugins-official
- **Skills**：gstack、superpowers/skills、compound-engineering-plugin/skills、graphify
- **Tools**：graphify、code-review-graph、GitNexus、rtk

## 2. 安装指南

### 2.1 安装方法

#### 方法一：直接下载脚本

1. 下载脚本到本地：
   ```bash
   curl -fsSL https://raw.githubusercontent.com/bingerz/claude-addons/refs/heads/master/install-claude-addons.sh -o install-claude-addons.sh
   ```

2. 赋予执行权限：
   ```bash
   chmod +x install-claude-addons.sh
   ```

3. 运行脚本：
   ```bash
   ./install-claude-addons.sh
   ```

#### 方法二：直接执行（一键安装）

```bash
curl -fsSL https://raw.githubusercontent.com/bingerz/claude-addons/refs/heads/master/install-claude-addons.sh | sh
```

### 2.2 安装模式

- **默认模式**（安装后清理 Git 仓库）：
  ```bash
  ./install-claude-addons.sh
  ```

- **保留仓库模式**（保留 Git 仓库以便后续更新）：
  ```bash
  ./install-claude-addons.sh --keep-repos
  ```

### 2.3 安装注意事项

- 脚本需要网络连接才能克隆 Git 仓库和安装工具
- 部分工具需要 Python 或 Node.js 环境
- 首次运行可能需要较长时间，因为需要克隆多个仓库和安装多个工具
- 建议定期运行脚本以保持工具和技能的更新

## 3. 工具使用指南

### 3.1 code-review-graph

#### 3.1.1 项目概述

code-review-graph 是一个本地知识图谱工具，为 Claude Code 构建代码库的持久映射，使 Claude 只读取重要的内容，从而在代码审查时减少 6.8 倍的 token 使用，在日常编码任务中最多减少 49 倍的 token 使用。

#### 3.1.2 核心功能

- **代码结构映射**：使用 Tree-sitter 将代码库解析为 AST，构建节点（函数、类、导入）和边（调用、继承、测试覆盖）的图谱
- **增量更新**：在每次文件编辑和 git 提交时自动更新图谱，大型项目的重新索引时间不到 2 秒
- **影响范围分析**：当文件更改时，图谱追踪可能受影响的每个调用者、依赖项和测试，计算变更的"影响范围"
- **多语言支持**：支持 19 种语言 + Jupyter 笔记本
- **最小上下文提取**：计算 AI 助手需要读取的最小文件集，而不是扫描整个项目
- **Monorepo 支持**：解决大型 monorepo 的 token 浪费问题

#### 3.1.3 安装与配置

##### 系统要求

- Python 3.10+
- 推荐安装 uv（MCP 配置会使用 uvx，如果可用，否则回退到直接使用 code-review-graph 命令）

##### 安装步骤

```bash
pip install code-review-graph  # 或: pipx install code-review-graph
code-review-graph install     # 自动检测并配置所有支持的平台
code-review-graph build       # 解析代码库
```

##### 平台特定配置

```bash
# 仅配置 Codex
code-review-graph install --platform codex

# 仅配置 Cursor
code-review-graph install --platform cursor

# 仅配置 Claude Code
code-review-graph install --platform claude-code
```

#### 3.1.4 使用方法

##### 基本使用

在项目中打开 Claude Code 并运行：

```
Build the code review graph for this project
```

初始构建对于 500 文件的项目大约需要 10 秒。之后，图谱会在每次文件编辑和 git 提交时自动更新。

##### 工作原理

1. **解析**：使用 Tree-sitter 将代码库解析为 AST
2. **构建**：构建节点（函数、类、导入）和边（调用、继承、测试覆盖）的图谱
3. **分析**：当文件更改时，计算变更的"影响范围"
4. **提取**：提取 AI 助手需要读取的最小文件集
5. **更新**：在每次文件编辑和 git 提交时自动更新图谱

#### 3.1.5 性能基准

所有数字来自针对 6 个真实开源存储库（共 13 个提交）的自动评估运行。使用 `code-review-graph eval --all` 重现。

##### Token 效率：平均减少 8.2 倍（原始 vs 图谱）

| 存储库 | 提交数 | 平均原始 Token | 平均图谱 Token | 减少倍数 |
|--------|--------|---------------|---------------|----------|
| express | 2 | 693 | 983 | 0.7x |
| fastapi | 2 | 4,944 | 614 | 8.1x |
| flask | 2 | 44,751 | 4,252 | 9.1x |
| gin | 3 | 21,972 | 1,153 | 16.4x |
| httpx | 2 | 12,044 | 1,728 | 6.9x |
| nextjs | 2 | 9,882 | 1,249 | 8.0x |
| **平均** | **13** | | | **8.2x** |

**注意**：对于小型包中的单文件更改，图谱上下文（元数据、边、审查指南）可能会超过原始文件大小。图谱方法在多文件更改时发挥作用，因为它会修剪不相关的代码。

##### 影响准确性：100% 召回率，平均 F1 为 0.54

| 存储库 | 提交数 | 平均 F1 | 平均精确率 | 召回率 |
|--------|--------|---------|------------|--------|
| express | 2 | 0.667 | 0.50 | 1.0 |
| fastapi | 2 | 0.584 | 0.42 | 1.0 |
| flask | 2 | 0.475 | 0.34 | 1.0 |
| gin | 3 | 0.429 | 0.29 | 1.0 |
| httpx | 2 | 0.762 | 0.63 | 1.0 |
| nextjs | 2 | 0.331 | 0.20 | 1.0 |
| **平均** | **13** | **0.54** | **0.38** | **1.0** |

#### 3.1.6 使用技巧

1. **初始构建**：在开始使用项目前，首先运行 `code-review-graph build` 构建初始图谱
2. **定期更新**：虽然图谱会自动更新，但在大型代码变更后，手动运行 `code-review-graph build` 确保图谱完整性
3. **关注影响范围**：使用图谱分析代码变更的影响范围，了解可能受影响的文件和测试
4. **结合代码审查**：在代码审查时，利用图谱提供的上下文，减少 token 使用并提高审查质量
5. **处理大型项目**：对于大型 monorepo，使用图谱减少 token 消耗，提高 AI 助手的响应速度
6. **多语言项目**：利用多语言支持，处理包含多种编程语言的项目
7. **Jupyter 笔记本**：利用对 Jupyter/Databricks 笔记本的支持，处理包含笔记本的项目

#### 3.1.7 在软件开发中的价值

1. **减少 token 消耗**：在代码审查时减少 6.8 倍的 token 使用，在日常编码任务中最多减少 49 倍
2. **提高代码审查质量**：提供更准确的上下文，帮助 AI 助手更好地理解代码变更
3. **加速开发流程**：减少 AI 助手读取代码的时间，提高响应速度
4. **减少技术债务**：通过更好的代码理解，减少引入新问题的风险
5. **提高团队协作**：提供代码库的结构视图，促进团队成员之间的理解和协作
6. **支持大型项目**：解决大型 monorepo 的 token 浪费问题，使 AI 助手能够有效处理大型代码库
7. **准确的影响分析**：100% 的召回率确保不会错过任何受影响的文件

#### 3.1.8 注意事项

1. **小型变更**：对于小型单文件变更，图谱上下文可能会超过原始文件大小
2. **搜索质量**：关键词搜索的排名需要改进，某些查询可能返回 0 个结果
3. **流检测**：仅在 Python 存储库中可靠地检测入口点，JavaScript 和 Go 的流检测需要改进
4. **精确率与召回率**：为了确保不遗漏任何受影响的文件，图谱可能会过度预测，这是一种保守的权衡
5. **性能影响**：虽然增量更新很快，但初始构建大型代码库可能需要一些时间

#### 3.1.9 故障排除

- **安装失败**：确保 Python 版本为 3.10+，并安装所有必要的依赖项
- **构建失败**：检查是否有语法错误的文件，这可能会导致解析失败
- **图谱不更新**：确保 git 提交或文件保存操作触发了更新，或手动运行 `code-review-graph build`
- **性能问题**：对于非常大的代码库，可能需要增加内存或处理时间
- **平台特定问题**：参考平台特定的安装指南和故障排除提示

### 3.2 GitNexus

#### 3.2.1 项目概述

GitNexus 是一个零服务器代码智能引擎，是一个客户端知识图谱创建器，完全在浏览器中运行。它可以将任何代码库索引到知识图谱中，跟踪每个依赖项、调用链、集群和执行流程，然后通过智能工具将其暴露出来，使 AI 代理永远不会错过代码。

#### 3.2.2 核心功能

- **知识图谱构建**：将任何代码库索引到知识图谱中，跟踪每个依赖项、调用链、集群和执行流程
- **双模式使用**：
  - CLI + MCP：本地索引存储库，通过 MCP 连接 AI 代理
  - Web UI：浏览器中的可视化图谱探索器 + AI 聊天
- **多编辑器支持**：支持 Claude Code、Cursor、Codex、Windsurf、OpenCode 等
- **Bridge 模式**：`gitnexus serve` 连接两种模式，Web UI 自动检测本地服务器
- **企业功能**：包括 PR 审查、自动更新代码 Wiki、自动重新索引、多存储库支持等

#### 3.2.3 安装与配置

##### CLI + MCP（推荐）

```bash
# 全局安装
npm install -g gitnexus

# 或使用 npx
npx gitnexus analyze  # 分析代码库并创建知识图谱
npx gitnexus setup    # 配置 MCP 服务器（仅需执行一次）
```

##### 编辑器支持

| 编辑器 | MCP | 技能 | 钩子（自动增强） | 支持 |
|--------|-----|------|------------------|------|
| Claude Code | 是 | 是 | 是（PreToolUse + PostToolUse） | 完整 |
| Cursor | 是 | 是 | — | MCP + 技能 |
| Codex | 是 | 是 | — | MCP + 技能 |
| Windsurf | 是 | — | — | MCP |
| OpenCode | 是 | 是 | — | MCP + 技能 |

##### 手动 MCP 配置

**Claude Code**：
```bash
# macOS / Linux
claude mcp add gitnexus -- npx -y gitnexus@latest mcp

# Windows
claude mcp add gitnexus -- cmd /c npx -y gitnexus@latest mcp
```

**Codex**：
```bash
codex mcp add gitnexus -- npx -y gitnexus@latest mcp
```

**Cursor**（~/.cursor/mcp.json — 全局，适用于所有项目）：
```json
{
  "mcpServers": {
    "gitnexus": {
      "command": "npx -y gitnexus@latest mcp"
    }
  }
}
```

#### 3.2.4 使用方法

##### CLI + MCP 模式

1. **索引存储库**：在项目根目录运行 `npx gitnexus analyze`
2. **配置 MCP**：运行 `npx gitnexus setup` 自动检测编辑器并写入正确的全局 MCP 配置
3. **使用 AI 助手**：打开编辑器，AI 助手现在可以访问代码库的知识图谱

##### Web UI 模式

访问 https://gitnexus.vercel.app，上传 GitHub 存储库或 ZIP 文件，获得交互式知识图谱和内置的 Graph RAG Agent。

##### Bridge 模式

1. **启动服务器**：在项目根目录运行 `gitnexus serve`
2. **访问 Web UI**：Web UI 会自动检测本地服务器，可以浏览所有 CLI 索引的存储库，无需重新上传或重新索引

#### 3.2.5 使用技巧

1. **定期分析**：在代码库发生重大变化时，运行 `npx gitnexus analyze` 更新知识图谱
2. **结合 AI 助手**：让 AI 助手使用 GitNexus 提供的深度代码库视图，避免遗漏依赖和破坏调用链
3. **使用 Web UI**：对于快速探索和演示，使用 Web UI 模式
4. **利用 Bridge 模式**：在开发过程中，使用 Bridge 模式在浏览器中可视化代码库结构
5. **企业功能**：对于大型团队，考虑使用企业版获得额外功能
6. **多存储库管理**：使用企业版的多存储库支持，获得跨存储库的统一图谱
7. **代码 Wiki**：利用自动更新的代码 Wiki，保持文档与代码同步

#### 3.2.6 在软件开发中的价值

1. **深度代码理解**：提供代码库的深度架构视图，帮助 AI 助手更好地理解代码
2. **避免依赖问题**：识别依赖关系，避免遗漏依赖和破坏调用链
3. **提高开发效率**：减少 AI 助手在理解代码库上花费的时间
4. **降低错误率**：通过完整的依赖关系视图，减少引入错误的风险
5. **知识共享**：通过可视化图谱和自动生成的文档，促进团队知识共享
6. **支持大型项目**：即使是小型模型也能获得完整的架构清晰度，使其能够与大型模型竞争
7. **持续维护**：自动重新索引确保知识图谱保持最新

#### 3.2.7 注意事项

1. **性能影响**：索引大型代码库可能需要一些时间和资源
2. **存储需求**：知识图谱可能占用一定的磁盘空间
3. **平台差异**：不同编辑器的集成方式略有不同
4. **Web UI 限制**：Web UI 模式受浏览器内存限制（约 5k 文件），或通过后端模式无限制
5. **企业功能**：某些高级功能需要企业版

#### 3.2.8 故障排除

- **分析失败**：确保代码库没有语法错误，并且有足够的内存
- **MCP 连接问题**：检查 MCP 配置是否正确，确保 GitNexus 服务器正在运行
- **编辑器集成问题**：参考编辑器特定的集成指南
- **性能问题**：对于大型代码库，可能需要增加内存或处理时间
- **Web UI 问题**：对于大型代码库，考虑使用 Bridge 模式或企业版

### 3.3 rtk

#### 3.3.1 项目概述

rtk 是一个用于减少 LLM token 消耗的工具，能够减少 60-90% 的 token 消耗，同时提高代码处理速度和效率。它通过智能命令重写，自动将 git 命令重写为优化版本，从而减少 AI 工具在处理代码时的 token 使用。

#### 3.3.2 核心功能

- **Token 消耗优化**：减少 LLM token 消耗 60-90%
- **代码处理效率**：大幅提高代码处理速度和效率
- **智能命令重写**：自动将 git 命令重写为优化版本
- **多平台支持**：支持 Claude Code、Copilot、Gemini CLI、Codex (OpenAI) 等
- **自动集成**：初始化后自动集成到 AI 工具中，无需手动操作

#### 3.3.3 安装与配置

##### 安装

```bash
# 全局安装
npm install -g rtk

# 或使用 npx
npx rtk init -g
```

##### 平台特定配置

```bash
# 为 Claude Code / Copilot 配置
rtk init -g

# 为 Gemini CLI 配置
rtk init -g --gemini

# 为 Codex (OpenAI) 配置
rtk init -g --codex
```

##### 验证安装

重新启动 AI 工具，然后测试：

```bash
git status  # 会自动重写为 rtk git status
```

#### 3.3.4 使用方法

##### 基本使用

rtk 会自动集成到 AI 工具中，无需手动调用。当 AI 工具执行 git 命令时，rtk 会自动重写命令，优化输出，减少 token 消耗。

##### 常见命令

```bash
# 查看 git 状态
git status  # 自动重写为 rtk git status

# 查看 git 日志
git log     # 自动重写为 rtk git log

# 查看 git 差异
git diff    # 自动重写为 rtk git diff
```

#### 3.3.5 使用技巧

1. **全局配置**：在系统中全局安装 rtk，使其在所有项目中生效
2. **多平台配置**：根据使用的 AI 工具，配置相应的平台
3. **定期更新**：保持 rtk 版本最新，以获得最佳性能
4. **结合其他工具**：与 code-review-graph、GitNexus 和 graphify 等工具结合使用，获得最佳效果
5. **监控 token 使用**：观察使用 rtk 前后的 token 消耗变化，了解优化效果
6. **大型项目**：在大型项目中使用 rtk，获得更显著的 token 消耗减少
7. **频繁操作**：在需要频繁执行 git 命令的场景中使用 rtk，最大化效率

#### 3.3.6 在软件开发中的价值

1. **减少 token 消耗**：减少 60-90% 的 LLM token 消耗，降低使用成本
2. **提高响应速度**：减少 token 处理时间，提高 AI 工具的响应速度
3. **优化代码处理**：通过智能命令重写，提供更清晰、更有用的代码信息
4. **降低延迟**：减少 AI 工具处理代码的延迟，提高开发效率
5. **支持大型项目**：使 AI 工具能够更有效地处理大型代码库
6. **无缝集成**：自动集成到 AI 工具中，无需额外操作
7. **跨平台支持**：支持多种 AI 工具，提供一致的优化体验

#### 3.3.7 注意事项

1. **平台兼容性**：确保 rtk 与使用的 AI 工具兼容
2. **版本更新**：定期更新 rtk 以获得最新的优化和功能
3. **命令覆盖**：rtk 会覆盖某些 git 命令的行为，确保了解这些变化
4. **性能影响**：虽然 rtk 提高了 AI 工具的性能，但可能会略微增加本地命令执行时间
5. **配置冲突**：避免与其他 git 相关工具的配置冲突

#### 3.3.8 故障排除

- **命令不生效**：确保 rtk 已正确安装并初始化，尝试重新启动 AI 工具
- **配置问题**：检查 rtk 配置是否正确，特别是平台特定配置
- **性能问题**：如果遇到性能问题，尝试更新 rtk 到最新版本
- **兼容性问题**：确保 rtk 版本与使用的 AI 工具版本兼容
- **集成问题**：参考 rtk 文档了解如何正确集成到特定 AI 工具中

### 3.4 graphify

#### 3.4.1 项目概述

graphify 是一个 AI 编码助手技能，能够将任何代码、文档、论文、图像、视频或 YouTube 链接的文件夹转换为可查询的知识图谱。它支持多模态输入，能够从各种类型的文件中提取概念和关系，并将它们连接成一个统一的图谱。

#### 3.4.2 核心功能

- **多模态支持**：处理代码、PDF、Markdown、截图、图表、白板照片、其他语言的图像或视频和音频文件
- **知识图谱构建**：从所有输入文件中提取概念和关系，构建统一的知识图谱
- **视频转录**：使用 Whisper 对视频进行转录，使用从语料库派生的领域感知提示
- **多语言支持**：通过 tree-sitter AST 支持 22 种语言
- **高效查询**：与读取原始文件相比，每个查询的 token 减少 71.5 倍
- **会话持久性**：图谱在会话之间保持持久，无需重新读取
- **透明推理**：标记提取的、推断的和模糊的关系，让您始终知道哪些是发现的，哪些是猜测的

#### 3.4.3 安装与配置

##### 系统要求

- Python 3.10+
- 一个支持的 AI 编码助手：Claude Code、Codex、OpenCode、Cursor、Gemini CLI、GitHub Copilot CLI、Aider、OpenClaw、Factory Droid 或 Trae

##### 安装步骤

```bash
pip install graphifyy && graphify install
```

##### 平台特定安装

```bash
# Claude Code (Linux/Mac)
graphify install

# Claude Code (Windows)
graphify install --platform windows

# Codex
graphify install --platform codex

# OpenCode
graphify install --platform opencode

# GitHub Copilot CLI
graphify install --platform copilot

# Aider
graphify install --platform aider

# OpenClaw
graphify install --platform claw

# Factory Droid
graphify install --platform droid

# Trae
graphify install --platform trae

# Trae CN
graphify install --platform trae-cn

# Gemini CLI
graphify install --platform gemini

# Cursor
graphify cursor install
```

##### 配置

创建 `.graphifyignore` 文件来排除不需要包含在图谱中的文件夹：

```
# .graphifyignore
vendor/
node_modules/
dist/
*.generated.py
```

语法与 `.gitignore` 相同。模式匹配相对于运行 graphify 的文件夹的文件路径。

#### 3.4.4 使用方法

##### 基本使用

在 Claude Code 中使用斜杠命令：

```
/graphify .  # 分析当前文件夹
```

**注意**：Codex 使用 `$` 而不是 `/` 来调用技能，因此请输入 `$graphify .`。

##### 输出文件

运行后会生成以下文件：

```
graphify-out/
├── graph.html       # 交互式图谱 - 点击节点，搜索，按社区过滤
├── GRAPH_REPORT.md  # 核心节点，令人惊讶的连接，建议的问题
├── graph.json       # 持久图谱 - 数周后查询无需重新读取
└── cache/           # SHA256 缓存 - 仅处理更改的文件
```

##### 让助手始终使用图谱（推荐）

构建图谱后，在项目中运行一次：

```bash
# Claude Code
graphify claude install

# Codex
graphify codex install

# OpenCode
graphify opencode install

# GitHub Copilot CLI
graphify copilot install

# Aider
graphify aider install

# OpenClaw
graphify claw install

# Factory Droid
graphify droid install

# Trae
graphify trae install

# Gemini CLI
graphify gemini install
```

#### 3.4.5 工作原理

graphify 通过三个阶段运行：

1. **确定性 AST 阶段**：从代码文件中提取结构（类、函数、导入、调用图、文档字符串、原理注释），无需 LLM
2. **多媒体处理阶段**：使用 faster-whisper 在本地转录视频和音频文件，使用从语料库核心节点派生的领域感知提示
3. **概念提取阶段**：Claude 子代理并行处理文档、论文、图像和转录，提取概念、关系和设计原理

结果合并到 NetworkX 图谱中，使用 Leiden 社区检测进行聚类，并导出为交互式 HTML、可查询的 JSON 和 Plain-language 审计报告。

#### 3.4.6 使用技巧

1. **从根目录运行**：在项目根目录运行 `/graphify .` 以包含所有相关文件
2. **使用 .graphifyignore**：创建 `.graphifyignore` 文件排除不需要的文件夹，如 `node_modules`、`vendor` 等
3. **定期更新**：当代码库发生重大变化时，重新运行 `/graphify .` 更新图谱
4. **探索交互式图谱**：使用生成的 `graph.html` 交互式地探索代码库结构
5. **参考 GRAPH_REPORT.md**：查看核心节点、连接和建议的问题，获得对代码库的深入理解
6. **跨会话使用**：利用 `graph.json` 的持久性，在多个会话中使用相同的图谱
7. **多模态输入**：除了代码外，还可以添加文档、论文、图像和视频，获得更全面的理解

#### 3.4.7 在软件开发中的价值

1. **加速代码库理解**：快速了解大型代码库的结构和关系，减少上手时间
2. **发现隐藏结构**：揭示代码库中可能被忽略的架构决策和依赖关系
3. **跨文件分析**：理解代码库的全局结构，而不仅仅是单个文件
4. **知识共享**：通过可视化图谱向团队成员展示代码库结构，促进知识共享
5. **减少 token 消耗**：与直接读取原始文件相比，查询图谱使用的 token 减少 71.5 倍
6. **多模态集成**：将代码、文档、设计和其他资源整合到一个统一的知识表示中
7. **设计原理理解**：提取并理解代码背后的设计决策和原理

#### 3.4.8 注意事项

1. **性能影响**：处理大型代码库或包含大量多媒体文件时可能需要较长时间
2. **存储需求**：生成的图谱和缓存可能占用一定的磁盘空间
3. **平台差异**：不同平台的安装和使用方式略有不同
4. **依赖项**：需要 Python 3.10+ 和相关依赖项
5. **准确性**：虽然努力保持准确性，但某些关系可能是推断的，需要验证

#### 3.4.9 故障排除

- **安装失败**：确保 Python 版本为 3.10+，并安装所有必要的依赖项
- **处理大型文件**：对于大型代码库，可能需要增加内存或处理时间
- **图谱不完整**：检查 `.graphifyignore` 文件，确保没有排除重要文件
- **多媒体处理失败**：确保安装了 whisper 相关依赖项
- **平台特定问题**：参考平台特定的安装指南和故障排除提示

## 4. 技能使用指南

### 4.1 gstack

#### 4.1.1 项目概述

gstack 是由 Y Combinator CEO Garry Tan 创建的工具集，它将 Claude Code 转变为一个虚拟工程团队，包含多个专业角色，如 CEO、设计师、工程师、QA 负责人、安全官和发布工程师等。gstack 的目标是帮助开发者以更高的效率和质量构建软件，实现"一个人如同一支团队"的开发能力。

#### 4.1.2 核心功能

- **完整开发工作流**：实现从思考 → 计划 → 构建 → 审查 → 测试 → 部署 → 反思的完整流程
- **专业技能**：提供 23 个专业技能，覆盖产品规划、设计、工程、测试、安全等各个领域
- **强大工具**：包含 8 个强大工具，如浏览器操作、安全审计、代码审查等
- **并行开发**：支持同时运行多个项目的开发
- **多代理支持**：兼容多个 AI 代理，不仅限于 Claude Code

#### 4.1.3 安装与配置

##### 快速安装

```bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup
```

##### 团队模式（推荐）

```bash
cd ~/.claude/skills/gstack && ./setup --team
```

然后引导你的仓库，让团队成员也能使用：

```bash
cd <your-repo>
~/.claude/skills/gstack/bin/gstack-team-init required  # 或: optional
git add .claude/ CLAUDE.md && git commit -m "require gstack for AI-assisted work"
```

##### 多代理支持

```bash
# 自动检测已安装的代理
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/gstack && cd ~/gstack && ./setup

# 或指定特定代理
./setup --host <name>  # 如: codex, opencode, cursor, factory, slate, kiro
```

#### 4.1.4 主要技能

##### 产品规划与设计
- **/office-hours**：产品规划和需求分析，通过六个强制问题重新构建产品框架
- **/plan-ceo-review**：战略审查，重新思考问题，找到隐藏的优质产品
- **/plan-design-review**：设计审查，对每个设计维度进行评分并提出改进建议
- **/plan-devex-review**：开发者体验审查，探索开发者角色，基准测试和设计优化
- **/design-consultation**：设计咨询，从头构建完整的设计系统
- **/design-shotgun**：设计探索，生成多个设计变体并收集反馈
- **/design-html**：设计工程师，将设计转换为生产级 HTML/CSS

##### 代码与架构
- **/plan-eng-review**：工程架构审查，锁定架构、数据流、图表和测试计划
- **/review**：代码审查，发现生产环境中可能出现的 bug
- **/investigate**：调试，系统的根因分析和问题解决
- **/devex-review**：开发者体验测试，实际测试入职流程和使用体验

##### 测试与质量保证
- **/qa**：QA 测试，测试应用、发现 bug、修复并生成回归测试
- **/qa-only**：QA 报告，仅报告 bug 而不进行代码更改
- **/browse**：浏览器操作，提供真实的 Chromium 浏览器进行测试
- **/open-gstack-browser**：启动 GStack 浏览器，带有侧边栏和反机器人功能
- **/setup-browser-cookies**：会话管理，从真实浏览器导入 cookie 进行认证测试

##### 安全与部署
- **/cso**：安全审计，运行 OWASP Top 10 + STRIDE 威胁模型
- **/ship**：发布工程师，同步主分支、运行测试、推送和打开 PR
- **/land-and-deploy**：部署，合并 PR、等待 CI 和部署、验证生产健康状态
- **/canary**：SRE，部署后监控，观察控制台错误和性能回归
- **/benchmark**：性能测试，基准页面加载时间和核心 Web 指标
- **/document-release**：技术文档，更新所有项目文档以匹配已发布的内容

##### 协作与管理
- **/retro**：团队回顾，团队感知的每周回顾和绩效分析
- **/pair-agent**：多代理协调，与其他 AI 代理共享浏览器
- **/autoplan**：自动规划，自动运行 CEO → 设计 → 工程审查
- **/learn**：记忆管理，管理 gstack 在会话中学习的内容

##### 安全工具
- **/careful**：安全护栏，在执行破坏性命令前发出警告
- **/freeze**：编辑锁定，将文件编辑限制在一个目录中
- **/guard**：完全安全，同时激活 /careful 和 /freeze
- **/unfreeze**：解锁，移除 /freeze 边界
- **/gstack-upgrade**：自更新，将 gstack 升级到最新版本

#### 4.1.5 使用方法

##### 基本使用

在 Claude Code 中使用斜杠命令激活技能：

```
/{skill-name} [parameters]
```

例如：

```
/office-hours  # 开始产品规划
/plan-ceo-review  # 进行战略审查
/review  # 进行代码审查
/qa https://staging.myapp.com  # 测试应用
/ship  # 部署和发布
```

##### 工作流程示例

1. **产品规划**：使用 `/office-hours` 重新构建产品框架
2. **战略审查**：使用 `/plan-ceo-review` 重新思考问题
3. **架构审查**：使用 `/plan-eng-review` 锁定架构和测试计划
4. **设计审查**：使用 `/plan-design-review` 评估和改进设计
5. **代码实现**：根据计划实现功能
6. **代码审查**：使用 `/review` 发现和修复 bug
7. **安全审计**：使用 `/cso` 进行安全检查
8. **质量保证**：使用 `/qa` 测试应用并修复问题
9. **部署发布**：使用 `/ship` 和 `/land-and-deploy` 部署到生产环境
10. **监控**：使用 `/canary` 监控部署后的应用状态
11. **回顾**：使用 `/retro` 进行团队回顾

#### 4.1.6 使用技巧

1. **按照工作流程使用**：遵循思考 → 计划 → 构建 → 审查 → 测试 → 部署 → 反思的流程
2. **选择合适的审查**：
   - 面向最终用户的产品：使用 `/plan-design-review` 和 `/design-review`
   - 面向开发者的产品：使用 `/plan-devex-review` 和 `/devex-review`
   - 架构和性能：使用 `/plan-eng-review` 和 `/review`
   - 全面审查：使用 `/autoplan`（自动运行 CEO → 设计 → 工程 → DX 审查）
3. **并行开发**：使用 Conductor 同时运行多个 Claude Code 会话，每个会话处理不同的任务
4. **浏览器操作**：使用 `/browse` 和 `/open-gstack-browser` 进行真实的浏览器测试
5. **安全保障**：在处理敏感操作时使用 `/careful`、`/freeze` 和 `/guard` 保护代码
6. **多代理协作**：使用 `/pair-agent` 与其他 AI 代理共享浏览器进行协作
7. **持续学习**：使用 `/learn` 管理 gstack 在会话中学习的内容，提高后续会话的效率

#### 4.1.7 在软件开发中的价值

1. **提高开发效率**：每天可生成 10,000-20,000 行代码，大幅提高开发速度
2. **保证代码质量**：通过专业的代码审查、安全审计和测试，确保代码质量
3. **完整的开发工作流**：提供从产品规划到部署的完整工作流程，确保项目的系统性和完整性
4. **专业的角色分工**：模拟真实团队的角色分工，提供专业的建议和审查
5. **多代理协作**：支持与多个 AI 代理协同工作，充分利用不同 AI 的优势
6. **并行开发能力**：支持同时运行多个项目，提高资源利用率
7. **开源免费**：MIT 许可证，完全免费使用和修改

#### 4.1.8 注意事项

1. **系统要求**：需要 Claude Code、Git、Bun v1.0+，Windows 用户还需要 Node.js
2. **安全警告**：在使用 `/browse` 等浏览器操作时，确保只访问可信的网站
3. **性能影响**：运行多个并行会话可能会消耗较多系统资源
4. **学习曲线**：gstack 功能丰富，需要一定时间学习和掌握
5. **隐私与遥测**：gstack 包含可选的使用遥测，默认关闭，可随时开启或关闭

#### 4.1.9 故障排除

- **技能不显示**：运行 `cd ~/.claude/skills/gstack && ./setup`
- **/browse 失败**：运行 `cd ~/.claude/skills/gstack && bun install && bun run build`
- **安装过时**：运行 `/gstack-upgrade` 或在 `~/.gstack/config.yaml` 中设置 `auto_upgrade: true`
- **命令前缀**：使用 `./setup --no-prefix` 获得更短的命令，或使用 `./setup --prefix` 获得命名空间命令
- **Windows 用户**：gstack 在 Windows 11 上通过 Git Bash 或 WSL 工作，需要同时安装 Bun 和 Node.js
- **Claude 看不到技能**：确保项目的 `CLAUDE.md` 文件包含 gstack 部分

### 4.2 superpowers

#### 4.2.1 项目概述

superpowers 是一个完整的软件开发工作流框架，为编码代理提供一系列可组合的"技能"，确保代理能够以系统化、结构化的方式进行开发。它由 Jesse Vincent 创建，旨在帮助开发者通过自动化和结构化的流程提高开发效率和代码质量。

#### 4.2.2 核心功能

- **完整开发工作流**：从需求分析到代码实现、测试、审查和部署的完整流程
- **自动技能触发**：技能会根据上下文自动触发，无需手动激活
- **子代理驱动开发**：使用多个子代理协作完成开发任务
- **测试驱动开发**：强制遵循 RED-GREEN-REFACTOR 循环
- **系统化调试**：提供四阶段根因分析流程
- **Git 工作树管理**：支持并行开发分支

#### 4.2.3 安装与配置

##### Claude Code 官方市场

```bash
/plugin install superpowers@claude-plugins-official
```

##### Claude Code（通过插件市场）

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

##### 其他平台

- **Cursor**：在 Cursor Agent 聊天中输入 `/add-plugin superpowers`
- **Codex**：告诉 Codex 执行 `Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md`
- **OpenCode**：告诉 OpenCode 执行 `Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md`
- **GitHub Copilot CLI**：`copilot plugin marketplace add obra/superpowers-marketplace && copilot plugin install superpowers@superpowers-marketplace`
- **Gemini CLI**：`gemini extensions install https://github.com/obra/superpowers`

#### 4.2.4 基本工作流程

1. **brainstorming** - 在编写代码前激活。通过问题细化想法，探索替代方案，分部分呈现设计以供验证。保存设计文档。

2. **using-git-worktrees** - 设计批准后激活。在新分支上创建隔离工作区，运行项目设置，验证干净的测试基线。

3. **writing-plans** - 有批准的设计后激活。将工作分解为小块任务（每个 2-5 分钟）。每个任务都有确切的文件路径、完整的代码和验证步骤。

4. **subagent-driven-development** 或 **executing-plans** - 有计划后激活。为每个任务分配新的子代理，进行两阶段审查（规格合规性，然后是代码质量），或分批执行并设置人工检查点。

5. **test-driven-development** - 实现期间激活。强制遵循 RED-GREEN-REFACTOR：编写失败的测试，观察它失败，编写最小代码，观察它通过，提交。删除测试前编写的代码。

6. **requesting-code-review** - 任务之间激活。根据计划进行审查，按严重程度报告问题。关键问题会阻止进度。

7. **finishing-a-development-branch** - 任务完成时激活。验证测试，提供选项（合并/PR/保留/丢弃），清理工作树。

**代理在任何任务前都会检查相关技能。** 这些是强制工作流，而非建议。

#### 4.2.5 技能库

##### 测试
- **test-driven-development** - RED-GREEN-REFACTOR 循环（包含测试反模式参考）

##### 调试
- **systematic-debugging** - 四阶段根因分析流程（包含根因追踪、深度防御、基于条件的等待技术）
- **verification-before-completion** - 确保问题真正被修复

##### 协作
- **brainstorming** - 苏格拉底式设计细化
- **writing-plans** - 详细的实施计划
- **executing-plans** - 带检查点的批量执行
- **dispatching-parallel-agents** - 并发子代理工作流
- **requesting-code-review** - 预审查清单
- **receiving-code-review** - 回应用户反馈
- **using-git-worktrees** - 并行开发分支
- **finishing-a-development-branch** - 合并/PR 决策工作流
- **subagent-driven-development** - 快速迭代，两阶段审查（规格合规性，然后是代码质量）

##### 元技能
- **writing-skills** - 遵循最佳实践创建新技能（包含测试方法）
- **using-superpowers** - 技能系统介绍

#### 4.2.6 使用方法

##### 自动激活

superpowers 技能会根据上下文自动激活，无需手动触发。当你开始讨论开发任务时，相关技能会自动启动。

##### 手动激活

你也可以通过明确请求来激活特定技能：

```
Hey Claude, use [skill name] to help me [task description]
```

例如：

```
Hey Claude, use brainstorming to help me design a new feature
Hey Claude, use test-driven-development to implement this function
Hey Claude, use systematic-debugging to fix this issue
```

##### 命令行使用

在 Claude Code 中，你可以使用斜杠命令来执行特定操作：

```
/brainstorm [topic]
/write-plan [description]
/execute-plan
```

#### 4.2.7 使用技巧

1. **遵循工作流程**：让 superpowers 按顺序执行其工作流程，不要跳过步骤
2. **提供详细信息**：在初始请求中提供尽可能多的上下文信息
3. **验证设计**：在进入实施阶段前，仔细审查和验证设计文档
4. **关注测试**：利用 test-driven-development 技能确保代码质量
5. **利用子代理**：对于复杂任务，让 subagent-driven-development 技能处理细节
6. **定期审查**：使用 requesting-code-review 技能定期检查代码质量
7. **使用 Git 工作树**：利用 using-git-worktrees 技能管理并行开发
8. **系统调试**：遇到问题时，使用 systematic-debugging 技能进行根因分析

#### 4.2.8 在软件开发中的价值

1. **提高开发效率**：自动化工作流程，减少手动决策和错误
2. **保证代码质量**：强制遵循测试驱动开发和代码审查流程
3. **减少技术债务**：强调简单性和代码质量，避免过度工程
4. **增强团队协作**：结构化的工作流程和文档使团队成员更容易理解项目
5. **降低开发风险**：系统化的调试和测试流程减少了生产环境中的问题
6. **提高可预测性**：结构化的工作流程使项目进度更可预测
7. **促进最佳实践**：内置了测试驱动开发、YAGNI（你不需要它）和 DRY（不要重复自己）等最佳实践

#### 4.2.9 注意事项

1. **学习曲线**：superpowers 有一定的学习曲线，需要时间适应其工作流程
2. **平台兼容性**：不同平台的安装和使用方式略有不同
3. **性能影响**：使用多个子代理可能会增加系统资源消耗
4. **自动触发**：技能会自动触发，可能会在某些情况下打断你的思路
5. **版本更新**：定期更新插件以获取新功能和改进

#### 4.2.10 故障排除

- **技能不自动触发**：确保插件已正确安装，尝试明确请求使用特定技能
- **子代理失败**：检查网络连接和平台权限，尝试重新启动会话
- **测试失败**：检查测试环境配置，确保依赖项已正确安装
- **Git 工作树问题**：确保 Git 已正确配置，尝试手动创建和管理工作树
- **更新问题**：使用 `/plugin update superpowers` 命令更新插件

### 4.3 compound-engineering

#### 4.3.1 项目概述

compound-engineering-plugin 是一个为 AI 编码代理提供工程化工作流程的插件，其核心哲学是"每个工程工作单元应该使后续单元更容易，而不是更难"。它通过结构化的工作流程和专业的代理，帮助开发者从需求分析到代码实现、测试、审查和知识文档化的完整流程，旨在减少技术债务，提高代码质量和开发效率。

#### 4.3.2 核心功能

- **完整工程工作流程**：Brainstorm → Plan → Work → Review → Compound → Repeat
- **专业代理**：包含设计、文档、审查、研究等多个领域的专业代理
- **智能命令**：提供 /ce:ideate、/ce:brainstorm、/ce:plan、/ce:work、/ce:review、/ce:compound 等命令
- **跨平台支持**：支持 Claude Code、Cursor、OpenCode、Codex、Droid、Pi、Gemini、Copilot、Kiro、Windsurf、OpenClaw 和 Qwen
- **知识复利**：通过文档化学习，使未来工作更容易

#### 4.3.3 安装与配置

##### Claude Code

```bash
/plugin marketplace add EveryInc/compound-engineering-plugin
/plugin install compound-engineering
```

##### Cursor

```text
/add-plugin compound-engineering
```

##### 其他平台

```bash
# 转换为 OpenCode 格式
bunx @every-env/compound-plugin install compound-engineering --to opencode

# 转换为 Codex 格式
bunx @every-env/compound-plugin install compound-engineering --to codex

# 转换为 Factory Droid 格式
bunx @every-env/compound-plugin install compound-engineering --to droid

# 转换为 Pi 格式
bunx @every-env/compound-plugin install compound-engineering --to pi

# 转换为 Gemini CLI 格式
bunx @every-env/compound-plugin install compound-engineering --to gemini

# 转换为 GitHub Copilot 格式
bunx @every-env/compound-plugin install compound-engineering --to copilot

# 转换为 Kiro CLI 格式
bunx @every-env/compound-plugin install compound-engineering --to kiro

# 转换为 OpenClaw 格式
bunx @every-env/compound-plugin install compound-engineering --to openclaw

# 转换为 Windsurf 格式
bunx @every-env/compound-plugin install compound-engineering --to windsurf

# 自动检测已安装工具并安装到所有平台
bunx @every-env/compound-plugin install compound-engineering --to all
```

##### 项目设置

安装后，在任何项目中运行：

```
/ce-setup
```

这将检查环境，安装缺失的工具（agent-browser、gh、jq、vhs、silicon、ffmpeg），并引导项目配置。

#### 4.3.4 工作流程

```
Brainstorm → Plan → Work → Review → Compound → Repeat
    ^
  Ideate (optional -- when you need ideas)
```

##### 主要命令

| 命令 | 目的 |
|------|------|
| `/ce:ideate` | 通过发散思维和对抗性过滤发现高影响力的项目改进 |
| `/ce:brainstorm` | 在规划前探索需求和方法 |
| `/ce:plan` | 将功能想法转化为详细的实施计划 |
| `/ce:work` | 使用工作树和任务跟踪执行计划 |
| `/ce:review` | 合并前进行多代理代码审查 |
| `/ce:compound` | 记录学习内容，使未来工作更容易 |

- **/ce:brainstorm** 是主要入口点 - 它通过交互式问答将想法细化为需求计划，并在不需要仪式时自动短路。
- **/ce:plan** 接受来自头脑风暴的需求文档或详细想法，并将其提炼为代理（或人类）可以遵循的技术计划。
- **/ce:ideate** 不常用但可以是力量倍增器 - 它基于代码库主动提出强有力的改进想法，可选择由你指导。

每个循环都会产生复利效应：头脑风暴使计划更清晰，计划为未来计划提供信息，审查捕获更多问题，模式被记录下来。

#### 4.3.5 专业代理

##### 设计代理
- **design-implementation-reviewer**：审查设计实现
- **design-iterator**：迭代设计
- **figma-design-sync**：与 Figma 设计同步

##### 文档代理
- **ankane-readme-writer**：生成 README 文档

##### 文档审查代理
- **adversarial-document-reviewer**：对抗性文档审查
- **coherence-reviewer**：连贯性审查
- **design-lens-reviewer**：设计视角审查
- **feasibility-reviewer**：可行性审查
- **product-lens-reviewer**：产品视角审查
- **scope-guardian-reviewer**：范围守护者审查
- **security-lens-reviewer**：安全视角审查

##### 研究代理
- **best-practices-researcher**：最佳实践研究
- **framework-docs-researcher**：框架文档研究
- **git-history-analyzer**：Git 历史分析
- **issue-intelligence-analyst**：问题情报分析
- **learnings-researcher**：学习研究
- **repo-research-analyst**：代码库研究分析
- **session-historian**：会话历史记录
- **slack-researcher**：Slack 研究

##### 审查代理
- **adversarial-reviewer**：对抗性审查
- **agent-native-reviewer**：代理原生审查
- **api-contract-reviewer**：API 合同审查
- **architecture-strategist**：架构策略师
- **cli-agent-readiness-reviewer**：CLI 代理就绪审查
- **cli-readiness-reviewer**：CLI 就绪审查
- **code-simplicity-reviewer**：代码简洁性审查
- **correctness-reviewer**：正确性审查
- **data-integrity-guardian**：数据完整性守护者
- **data-migration-expert**：数据迁移专家
- **data-migrations-reviewer**：数据迁移审查
- **deployment-verification-agent**：部署验证代理
- **dhh-rails-reviewer**：DHH Rails 审查
- **julik-frontend-races-reviewer**：Julik 前端竞争条件审查
- **kieran-python-reviewer**：Kieran Python 审查
- **kieran-rails-reviewer**：Kieran Rails 审查
- **kieran-typescript-reviewer**：Kieran TypeScript 审查
- **maintainability-reviewer**：可维护性审查
- **pattern-recognition-specialist**：模式识别专家
- **performance-oracle**：性能预言家
- **performance-reviewer**：性能审查
- **previous-comments-reviewer**：先前评论审查
- **project-standards-reviewer**：项目标准审查
- **reliability-reviewer**：可靠性审查
- **schema-drift-detector**：模式漂移检测
- **security-reviewer**：安全审查
- **security-sentinel**：安全哨兵
- **testing-reviewer**：测试审查

##### 工作流代理
- **pr-comment-resolver**：PR 评论解析器
- **spec-flow-analyzer**：规范流程分析器

#### 4.3.6 使用方法

##### 基本使用

在 Claude Code 中使用斜杠命令：

```
/ce:ideate [topic]
/ce:brainstorm [idea]
/ce:plan [description]
/ce:work [plan]
/ce:review [code]
/ce:compound [learnings]
```

##### 工作流程示例

1. **创意生成**：使用 `/ce:ideate` 发现项目改进机会
2. **需求分析**：使用 `/ce:brainstorm` 探索需求和方法
3. **计划制定**：使用 `/ce:plan` 创建详细的实施计划
4. **执行计划**：使用 `/ce:work` 执行计划，跟踪任务
5. **代码审查**：使用 `/ce:review` 进行多代理代码审查
6. **知识复利**：使用 `/ce:compound` 记录学习内容
7. **重复循环**：根据新的学习和需求重复流程

#### 4.3.7 使用技巧

1. **从头脑风暴开始**：使用 `/ce:brainstorm` 作为主要入口点，它会自动处理简单情况
2. **充分规划**：在编写代码前使用 `/ce:plan` 制定详细计划，减少后期修改
3. **利用多代理审查**：使用 `/ce:review` 进行全面的代码审查，发现潜在问题
4. **记录学习**：使用 `/ce:compound` 记录学习内容，为未来工作做准备
5. **按需创意**：当需要新想法时，使用 `/ce:ideate` 发现改进机会
6. **环境准备**：在新项目中首先运行 `/ce-setup` 确保环境配置正确
7. **跨平台使用**：利用 CLI 工具在不同平台间同步配置和技能

#### 4.3.8 在软件开发中的价值

1. **减少技术债务**：通过结构化的工作流程和审查，减少技术债务的积累
2. **提高代码质量**：多代理审查确保代码质量和安全性
3. **知识复用**：通过 `/ce:compound` 记录学习内容，使知识可复用
4. **提高开发效率**：结构化的工作流程减少了重复工作和错误
5. **降低开发风险**：充分的规划和审查降低了项目风险
6. **促进团队协作**：标准化的工作流程和文档使团队协作更顺畅
7. **持续改进**：每个循环都能从之前的经验中学习，不断改进

#### 4.3.9 注意事项

1. **学习曲线**：需要时间适应其工作流程和命令
2. **工具依赖**：某些功能需要外部工具支持，如 agent-browser、gh、jq 等
3. **平台差异**：不同平台的安装和使用方式略有不同
4. **性能影响**：使用多个代理可能会增加系统资源消耗
5. **版本更新**：定期更新插件以获取新功能和改进

#### 4.3.10 故障排除

- **命令不工作**：确保插件已正确安装，尝试重新安装
- **环境问题**：运行 `/ce-setup` 检查并安装缺失的工具
- **代理失败**：检查网络连接和平台权限，尝试重新启动会话
- **跨平台同步问题**：使用 `bunx @every-env/compound-plugin sync` 同步配置
- **性能问题**：减少同时使用的代理数量，或升级系统资源

#### 4.3.11 高级功能

##### 本地开发

```bash
# 添加 shell 别名以便本地副本与正常插件一起加载
alias cce='claude --plugin-dir ~/code/compound-engineering-plugin/plugins/compound-engineering'

# 运行 cce 而不是 claude 来测试更改
cce
```

##### 分支测试

```bash
# 获取缓存的克隆路径
bun run src/index.ts plugin-path compound-engineering --branch feat/new-agents

# 使用分支路径运行 Claude Code
claude --plugin-dir ~/.cache/compound-engineering/branches/compound-engineering-feat~new-agents/plugins/compound-engineering
```

##### 配置同步

```bash
# 同步到所有检测到的工具
bunx @every-env/compound-plugin sync

# 同步到特定工具
bunx @every-env/compound-plugin sync --target codex
```

## 5. 代理使用指南

### 5.1 Agency-Agents

#### 5.1.1 项目概述

Agency-Agents 是一个精心设计的 AI 代理集合，为各种专业领域提供专业的 AI 助手。这些代理不仅具有专业知识，还具备独特的个性和工作流程，能够在软件开发等多种场景中提供高质量的输出。

#### 5.1.2 代理类型

Agency-Agents 包含多个领域的专业代理，特别是工程领域，包括：

- **前端开发者**：专注于现代 Web 技术、React/Vue/Angular 框架、UI 实现和性能优化
- **后端架构师**：API 设计、数据库架构、可扩展性
- **移动应用构建者**：iOS/Android、React Native、Flutter
- **AI 工程师**：ML 模型、部署、AI 集成
- **DevOps 自动化专家**：CI/CD、基础设施自动化、云运维
- **快速原型开发师**：快速 POC 开发、MVP
- **安全工程师**：威胁建模、安全代码审查、安全架构
- **代码审查员**：建设性代码审查、安全、可维护性
- **数据库优化器**：架构设计、查询优化、索引策略
- **技术作家**：开发者文档、API 参考、教程

#### 5.1.3 代理特点

每个代理都具有以下特点：
- **专业化**：在特定领域拥有深度专业知识
- **个性化**：独特的声音、沟通风格和方法
- **可交付成果**：提供实际代码、流程和可衡量的成果
- **生产就绪**：经过实战测试的工作流程和成功指标

#### 5.1.4 使用方法

在 Claude Code 会话中，使用以下命令格式激活特定代理：

```
Hey Claude, activate [Agent Name] mode and help me [task description]
```

#### 5.1.5 具体示例

1. **前端开发任务**：
   ```
   Hey Claude, activate Frontend Developer mode and help me build a responsive React component for a data table
   ```

2. **后端架构任务**：
   ```
   Hey Claude, activate Backend Architect mode and help me design a RESTful API for a user management system
   ```

3. **代码审查任务**：
   ```
   Hey Claude, activate Code Reviewer mode and review this PR for security vulnerabilities
   ```

4. **数据库优化任务**：
   ```
   Hey Claude, activate Database Optimizer mode and help me optimize this slow SQL query
   ```

#### 5.1.6 使用技巧

1. **选择合适的代理**：根据具体任务选择最合适的代理
2. **提供详细上下文**：为代理提供足够的项目背景和具体要求
3. **利用代理的专业工作流程**：每个代理都有预定义的工作流程，遵循这些流程可以获得更专业的结果
4. **结合其他工具**：与 code-review-graph、GitNexus 等工具配合使用，提高效率

#### 5.1.7 在软件开发中的价值

- **提高开发效率**：快速原型开发、专业问题解决、自动化常规任务
- **保证代码质量**：代码审查、安全检查、性能优化
- **跨领域协作**：知识共享、统一标准、无缝集成
- **持续学习和改进**：定期更新、反馈循环、领域扩展

### 5.2 compound-engineering-plugin/agents

#### 5.2.1 安装与配置

- 安装后会自动复制到 Claude 的代理目录
- 无需额外配置，直接在 Claude Code 中激活使用

#### 5.2.2 功能与优势

- **工程化专业代理**：提供专注于工程实践的专业代理
- **综合解决方案**：涵盖从设计到部署的完整工程流程
- **质量保证**：强调代码质量和工程标准

#### 5.2.3 使用方法

在 Claude Code 中激活相应的代理模式：
```
Hey Claude, activate [agent name] mode and help me [task description]
```

## 6. 插件使用指南

### 6.1 claude-plugins-official

#### 6.1.1 项目概述

claude-plugins-official 是 Anthropic 官方维护的高质量 Claude Code 插件目录，包含由 Anthropic 团队开发的内部插件和来自合作伙伴与社区的第三方插件。这些插件旨在扩展 Claude Code 的功能，提供专业工具和集成能力。

#### 6.1.2 插件结构

每个插件遵循标准结构：

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # 插件元数据（必需）
├── .mcp.json            # MCP 服务器配置（可选）
├── commands/            # 斜杠命令（可选）
├── agents/              # 代理定义（可选）
├── skills/              # 技能定义（可选）
└── README.md            # 文档
```

#### 6.1.3 插件分类

- **内部插件**（/plugins）：由 Anthropic 团队开发和维护的插件
- **第三方插件**（/external_plugins）：来自合作伙伴和社区的插件

#### 6.1.4 核心插件功能

##### 代码相关插件
- **code-review**：提供专业的代码审查功能，帮助识别代码问题和改进机会
- **code-simplifier**：帮助简化复杂代码，提高可读性和可维护性
- **feature-dev**：辅助新功能开发，提供代码架构和探索能力
- **commit-commands**：提供 Git 提交相关命令，简化版本控制工作流

##### 语言服务器插件
- **rust-analyzer-lsp**：Rust 语言分析和智能提示
- **pyright-lsp**：Python 类型检查和智能提示
- **clangd-lsp**：C/C++ 语言分析
- **gopls-lsp**：Go 语言分析
- **jdtls-lsp**：Java 语言分析
- **csharp-lsp**：C# 语言分析
- **kotlin-lsp**：Kotlin 语言分析
- **lua-lsp**：Lua 语言分析
- **php-lsp**：PHP 语言分析

##### 开发工具插件
- **plugin-dev**：辅助插件开发，包括代理创建和插件验证
- **mcp-server-dev**：帮助开发 MCP 服务器和应用
- **agent-sdk-dev**：辅助开发基于 Agent SDK 的应用
- **claude-code-setup**：Claude Code 自动化推荐和设置
- **claude-md-management**：管理和改进 Claude MD 文件

##### 输出风格插件
- **explanatory-output-style**：提供解释性输出风格
- **learning-output-style**：提供学习型输出风格

##### 第三方集成插件
- **github**：GitHub 集成
- **discord**：Discord 集成
- **asana**：Asana 项目管理集成
- **firebase**：Firebase 集成
- **linear**：Linear 项目管理集成
- **telegram**：Telegram 集成
- **supabase**：Supabase 集成
- **terraform**：Terraform 集成
- **playwright**：Playwright 测试集成

#### 6.1.5 安装与配置

##### 手动安装

在 Claude Code 中使用以下命令安装插件：

```
/plugin install {plugin-name}@claude-plugins-official
```

例如，安装代码审查插件：

```
/plugin install code-review@claude-plugins-official
```

##### 通过发现页面安装

1. 在 Claude Code 中输入 `/plugin` 命令
2. 选择 `Discover` 选项
3. 浏览可用插件并点击安装

##### 自动安装

使用安装脚本时，会自动安装以下常用插件：
- ralph-loop
- code-review
- code-simplifier
- security-guidance
- feature-dev
- rust-analyzer-lsp
- pyright-lsp

#### 6.1.6 使用方法

##### 斜杠命令

许多插件提供斜杠命令，可以直接在 Claude Code 中使用：

```
/{command-name} [parameters]
```

例如，使用代码审查插件：

```
/code-review [代码片段或文件路径]
```

##### 技能激活

部分插件提供技能，可以通过激活模式使用：

```
Hey Claude, activate [skill-name] mode and help me [task description]
```

##### 直接集成

一些插件会自动集成到 Claude Code 的工作流程中，无需额外命令即可使用。

#### 6.1.7 使用技巧

1. **选择合适的插件**：根据具体任务选择最合适的插件
2. **组合使用**：多个插件可以组合使用，提高工作效率
3. **查看文档**：每个插件都有 README.md 文件，提供详细使用说明
4. **定期更新**：插件会不断更新，定期检查更新以获得新功能
5. **安全使用**：确保只安装和使用来自可信来源的插件

#### 6.1.8 在软件开发中的价值

- **提高代码质量**：通过代码审查和简化插件，提高代码质量和可维护性
- **加速开发流程**：通过功能开发和 commit 命令插件，加速开发和版本控制流程
- **增强语言支持**：通过各种 LSP 插件，获得更好的语言分析和智能提示
- **扩展集成能力**：通过第三方集成插件，与其他工具和服务无缝协作
- **简化开发工作流**：通过专用开发工具插件，简化常见开发任务

#### 6.1.9 注意事项

- **安全警告**：确保在安装、更新或使用插件前信任该插件。Anthropic 无法控制插件中包含的 MCP 服务器、文件或其他软件，也无法验证它们是否按预期工作或是否会发生变化。
- **兼容性**：某些插件可能需要特定的环境或依赖项
- **性能影响**：安装过多插件可能会影响 Claude Code 的性能
- **插件冲突**：不同插件之间可能存在冲突，如遇到问题可以尝试禁用部分插件

## 7. 高级使用技巧

### 7.1 工具组合使用

#### 7.1.1 代码分析与理解工作流

- **深度代码分析**：code-review-graph + GitNexus + graphify
  - **第一步**：使用 code-review-graph 构建代码库图谱，识别文件间的依赖关系和调用链
  - **第二步**：使用 GitNexus 分析深度架构，获得代码库的完整依赖视图
  - **第三步**：使用 graphify 可视化代码结构，发现隐藏的架构模式和关系
  - **适用场景**：新团队成员入职、大型代码库重构、架构评估

- **多模态知识整合**：graphify + Claude Code 插件
  - **第一步**：使用 graphify 处理代码、文档、设计图和视频等多模态内容
  - **第二步**：利用 claude-plugins-official 中的代码审查和分析插件
  - **第三步**：结合 Agency-Agents 中的技术作家代理生成文档
  - **适用场景**：全栈项目理解、跨团队知识传递、项目文档更新

#### 7.1.2 开发优化工作流

- **效率提升组合**：rtk + gstack + superpowers
  - **第一步**：使用 rtk 优化 token 消耗，减少 60-90% 的 token 使用
  - **第二步**：激活 gstack 模式进行深度代码分析和多代理协作
  - **第三步**：根据需要使用 superpowers 中的专业技能，如 test-driven-development
  - **适用场景**：快速原型开发、大型功能实现、性能优化

- **工程化工作流**：compound-engineering + superpowers + code-review-graph
  - **第一步**：使用 compound-engineering 的 /ce:brainstorm 探索需求
  - **第二步**：使用 superpowers 的 writing-plans 制定详细计划
  - **第三步**：使用 code-review-graph 分析代码变更的影响范围
  - **第四步**：使用 compound-engineering 的 /ce:review 进行多代理代码审查
  - **适用场景**：企业级应用开发、复杂功能实现、团队协作项目

### 7.2 代理协作

#### 7.2.1 多代理协作工作流

- **全栈开发协作**：后端架构师 + 前端开发者 + 数据库优化器
  - **第一步**：使用后端架构师代理设计 API 和系统架构
  - **第二步**：使用数据库优化器代理设计数据库 schema 和查询优化
  - **第三步**：使用前端开发者代理实现用户界面
  - **适用场景**：全栈应用开发、架构设计与实现

- **DevOps 协作**：DevOps 自动化专家 + 安全工程师 + 性能优化专家
  - **第一步**：使用 DevOps 自动化专家设置 CI/CD 流程
  - **第二步**：使用安全工程师进行安全审计
  - **第三步**：使用性能优化专家优化系统性能
  - **适用场景**：生产环境部署、安全合规、性能优化

#### 7.2.2 代理与技能组合

- **代码质量保障**：Code Reviewer 代理 + gstack 的 /review + compound-engineering 的 /ce:review
  - **第一步**：使用 Code Reviewer 代理进行初步代码审查
  - **第二步**：使用 gstack 的 /review 进行深度代码分析
  - **第三步**：使用 compound-engineering 的 /ce:review 进行多代理审查
  - **适用场景**：代码质量检查、安全审计、性能评估

- **前端开发优化**：Frontend Developer 代理 + superpowers 的 test-driven-development + graphify
  - **第一步**：使用 Frontend Developer 代理设计和实现 UI 组件
  - **第二步**：使用 superpowers 的 test-driven-development 确保代码质量
  - **第三步**：使用 graphify 可视化组件关系和依赖
  - **适用场景**：前端组件开发、用户界面优化、响应式设计

### 7.3 插件与工具集成

#### 7.3.1 开发工具集成

- **代码编辑与分析**：claude-plugins-official 中的 LSP 插件 + code-review-graph
  - **第一步**：使用 LSP 插件（如 rust-analyzer-lsp、pyright-lsp）获得智能代码提示
  - **第二步**：使用 code-review-graph 分析代码变更的影响
  - **适用场景**：日常编码、代码重构、错误排查

- **版本控制优化**：claude-plugins-official 中的 commit-commands + rtk
  - **第一步**：使用 commit-commands 插件生成规范的 commit 信息
  - **第二步**：使用 rtk 优化 git 命令输出，减少 token 消耗
  - **适用场景**：版本控制、代码提交、分支管理

#### 7.3.2 第三方服务集成

- **项目管理集成**：claude-plugins-official 中的 asana、linear 插件 + compound-engineering
  - **第一步**：使用 compound-engineering 的 /ce:plan 制定项目计划
  - **第二步**：使用 asana 或 linear 插件将任务同步到项目管理工具
  - **适用场景**：团队项目管理、任务跟踪、进度监控

- **代码托管集成**：claude-plugins-official 中的 github 插件 + gstack
  - **第一步**：使用 gstack 的 /ship 准备代码发布
  - **第二步**：使用 github 插件创建 PR 和管理代码 review
  - **适用场景**：代码发布、PR 管理、团队协作

### 7.4 性能优化策略

#### 7.4.1 Token 管理

- **多层 Token 优化**：rtk + code-review-graph + GitNexus
  - **第一层**：使用 rtk 优化 git 命令输出
  - **第二层**：使用 code-review-graph 只处理相关文件
  - **第三层**：使用 GitNexus 提供结构化的代码库视图
  - **效果**：减少 60-90% 的 token 消耗，提高响应速度

#### 7.4.2 并行处理

- **多会话并行**：gstack 的 Conductor + superpowers 的 dispatching-parallel-agents
  - **第一步**：使用 gstack 的 Conductor 同时运行多个 Claude Code 会话
  - **第二步**：使用 superpowers 的 dispatching-parallel-agents 分配并行任务
  - **适用场景**：大型项目开发、多模块并行开发、快速原型验证

#### 7.4.3 资源管理

- **内存与存储优化**：graphify 的 .graphifyignore + code-review-graph 的增量更新
  - **第一步**：使用 .graphifyignore 排除不需要的文件和目录
  - **第二步**：利用 code-review-graph 的增量更新功能，只处理变更的文件
  - **适用场景**：大型代码库、资源受限环境、持续集成

### 7.5 软件开发场景应用

#### 7.5.1 新项目开发

1. **需求分析**：使用 compound-engineering 的 /ce:brainstorm 探索需求
2. **架构设计**：使用 Agency-Agents 中的后端架构师设计系统架构
3. **原型开发**：使用 Agency-Agents 中的快速原型开发师构建 MVP
4. **代码实现**：使用 gstack 的 /office-hours 和 /plan-eng-review 指导开发
5. **测试验证**：使用 superpowers 的 test-driven-development 确保代码质量
6. **部署发布**：使用 gstack 的 /ship 和 /land-and-deploy 部署应用

#### 7.5.2 代码库维护与优化

1. **代码分析**：使用 code-review-graph + GitNexus + graphify 分析代码库
2. **问题识别**：使用 Agency-Agents 中的代码审查员和安全工程师识别问题
3. **优化实施**：使用 Agency-Agents 中的性能优化专家和数据库优化器
4. **测试验证**：使用 superpowers 的 systematic-debugging 和 verification-before-completion
5. **知识文档**：使用 compound-engineering 的 /ce:compound 记录学习内容

#### 7.5.3 团队协作开发

1. **项目规划**：使用 compound-engineering 的 /ce:plan 制定详细计划
2. **任务分配**：使用 claude-plugins-official 中的项目管理插件分配任务
3. **代码审查**：使用 gstack 的 /review 和 compound-engineering 的 /ce:review
4. **知识共享**：使用 graphify 生成代码库可视化图谱
5. **持续集成**：使用 Agency-Agents 中的 DevOps 自动化专家设置 CI/CD

### 7.6 最佳实践组合

- **效率最大化组合**：rtk + code-review-graph + gstack + superpowers
  - **Token 优化**：rtk
  - **代码分析**：code-review-graph
  - **多代理协作**：gstack
  - **结构化工作流**：superpowers

- **质量保障组合**：compound-engineering + Agency-Agents + claude-plugins-official
  - **工程化流程**：compound-engineering
  - **专业领域知识**：Agency-Agents
  - **工具集成**：claude-plugins-official

- **知识管理组合**：graphify + GitNexus + compound-engineering
  - **多模态知识提取**：graphify
  - **代码库知识图谱**：GitNexus
  - **知识复利**：compound-engineering 的 /ce:compound

## 8. 故障排除

### 8.1 常见问题与解决方案

- **Git 克隆失败**：检查网络连接，脚本会自动尝试使用加速链接
- **工具安装失败**：检查 Python 或 Node.js 环境是否正常
- **插件安装失败**：某些插件可能不存在于 Claude 的插件市场，这是正常现象
- **技能配置失败**：检查目标目录权限是否正确

### 8.2 错误处理

- 插件安装失败时不会中断整个脚本执行
- 脚本会自动处理网络问题，尝试使用加速链接
- 工具版本检查避免重复安装同一个版本

## 9. 最佳实践

### 9.1 安装与更新

#### 9.1.1 环境配置

- **系统要求**：确保满足所有工具的系统要求
  - Python 3.7+（用于 graphify 和 code-review-graph）
  - Node.js 16+（用于 GitNexus 和 rtk）
  - Git 2.0+（用于版本控制和仓库克隆）
  - Claude Code 或其他支持的 AI 工具

- **环境管理**：使用虚拟环境隔离依赖
  - Python：`python -m venv venv && source venv/bin/activate`
  - Node.js：使用 nvm 管理多个 Node.js 版本

#### 9.1.2 安装策略

- **选择性安装**：根据项目需求选择性安装工具
  - 小型项目：rtk + 基本代理
  - 中型项目：code-review-graph + GitNexus + 专业代理
  - 大型项目：全套工具 + 多代理协作

- **版本管理**：
  - 使用 `--keep-repos` 参数保持 Git 仓库
  - 定期运行脚本更新工具到最新版本
  - 为关键项目锁定工具版本，确保稳定性

#### 9.1.3 网络优化

- **网络连接**：确保网络连接稳定，以便克隆仓库和安装工具
- **加速链接**：利用脚本内置的网络加速功能
- **离线安装**：对于网络受限环境，可提前下载依赖和工具

### 9.2 使用建议

#### 9.2.1 工具选择策略

- **根据任务类型选择工具**：
  - 代码分析：code-review-graph + GitNexus
  - 多模态内容处理：graphify
  - Token 优化：rtk
  - 全栈开发：gstack + superpowers
  - 工程化流程：compound-engineering

- **根据项目规模选择工具**：
  - 小型项目：轻量级工具组合
  - 中型项目：中等复杂度工具组合
  - 大型项目：完整工具链

#### 9.2.2 上下文管理

- **提供详细上下文**：
  - 项目背景和目标
  - 技术栈和依赖
  - 现有代码结构
  - 具体要求和约束

- **使用知识图谱**：利用 GitNexus 和 graphify 生成的知识图谱，为 AI 提供结构化的代码库视图

#### 9.2.3 工作流程优化

- **遵循预定义工作流程**：
  - gstack：思考 → 计划 → 构建 → 审查 → 测试 → 部署 → 反思
  - superpowers：brainstorming → using-git-worktrees → writing-plans → subagent-driven-development → test-driven-development → requesting-code-review → finishing-a-development-branch
  - compound-engineering：/ce:brainstorm → /ce:plan → /ce:build → /ce:review → /ce:compound

- **自定义工作流程**：根据项目特点和团队习惯，调整和组合不同工具的工作流程

#### 9.2.4 持续学习

- **关注更新**：定期查看工具和代理的更新日志
- **学习新功能**：尝试和掌握新发布的功能
- **分享经验**：与团队分享使用技巧和最佳实践
- **反馈贡献**：向工具开发者提供反馈和贡献

### 9.3 开发场景应用

#### 9.3.1 新项目开发

- **需求分析与规划**：
  - 使用 compound-engineering 的 /ce:brainstorm 探索需求
  - 使用 Agency-Agents 中的产品经理代理定义产品需求
  - 使用 gstack 的 /plan-design-review 进行设计审查

- **架构设计**：
  - 使用 Agency-Agents 中的后端架构师设计系统架构
  - 使用 Agency-Agents 中的数据库优化器设计数据模型
  - 使用 GitNexus 生成架构知识图谱

- **原型开发**：
  - 使用 Agency-Agents 中的快速原型开发师构建 MVP
  - 使用 superpowers 的 test-driven-development 确保代码质量
  - 使用 graphify 可视化原型架构

- **部署与发布**：
  - 使用 Agency-Agents 中的 DevOps 自动化专家设置 CI/CD
  - 使用 gstack 的 /ship 和 /land-and-deploy 部署应用
  - 使用 compound-engineering 的 /ce:compound 记录项目知识

#### 9.3.2 代码库维护与优化

- **代码分析**：
  - 使用 code-review-graph 构建代码库图谱
  - 使用 GitNexus 分析依赖关系
  - 使用 graphify 可视化代码结构

- **问题识别**：
  - 使用 Agency-Agents 中的代码审查员识别代码质量问题
  - 使用 Agency-Agents 中的安全工程师识别安全漏洞
  - 使用 Agency-Agents 中的性能优化专家识别性能瓶颈

- **优化实施**：
  - 使用 Agency-Agents 中的性能优化专家进行代码优化
  - 使用 Agency-Agents 中的数据库优化器优化数据库查询
  - 使用 superpowers 的 systematic-debugging 解决复杂问题

- **测试验证**：
  - 使用 superpowers 的 test-driven-development 编写测试
  - 使用 gstack 的 /review 进行代码审查
  - 使用 compound-engineering 的 /ce:review 进行多代理审查

#### 9.3.3 团队协作开发

- **项目规划**：
  - 使用 compound-engineering 的 /ce:plan 制定详细计划
  - 使用 claude-plugins-official 中的项目管理插件分配任务
  - 使用 gstack 的 Conductor 管理并行开发

- **代码协作**：
  - 使用 claude-plugins-official 中的 github 插件管理 PR
  - 使用 code-review-graph 分析代码变更的影响
  - 使用 gstack 的 /pair-agent 与其他 AI 代理协作

- **知识共享**：
  - 使用 graphify 生成代码库可视化图谱
  - 使用 Agency-Agents 中的技术作家代理生成文档
  - 使用 compound-engineering 的 /ce:compound 记录团队知识

- **持续集成**：
  - 使用 Agency-Agents 中的 DevOps 自动化专家设置 CI/CD
  - 使用 rtk 优化 CI/CD 中的 Git 操作
  - 使用 superpowers 的 verification-before-completion 确保构建质量

### 9.4 安全与性能最佳实践

#### 9.4.1 安全使用

- **插件安全**：只安装和使用来自可信来源的插件
- **权限管理**：确保工具和插件具有适当的文件系统权限
- **敏感信息**：避免在提示中包含敏感信息，如 API 密钥、密码等
- **网络安全**：在使用 /browse 等浏览器操作时，确保只访问可信的网站

#### 9.4.2 性能优化

- **Token 管理**：
  - 使用 rtk 减少 token 消耗
  - 使用 code-review-graph 只处理相关文件
  - 使用 GitNexus 提供结构化的代码库视图

- **资源管理**：
  - 使用 .graphifyignore 排除不需要的文件和目录
  - 利用 code-review-graph 的增量更新功能
  - 合理分配系统资源，避免过度并行

- **响应速度**：
  - 提供简洁明了的指令
  - 分步骤处理复杂任务
  - 利用工具的缓存功能

### 9.5 最佳实践总结

- **工具组合**：根据任务需求和项目规模，选择合适的工具组合
- **工作流程**：遵循结构化的工作流程，确保开发质量和效率
- **上下文管理**：提供详细的项目上下文，帮助 AI 更好地理解任务
- **持续优化**：定期更新工具，学习新功能，优化使用策略
- **团队协作**：利用工具和代理的协作能力，提高团队效率
- **安全合规**：遵循安全最佳实践，保护代码和数据
- **性能优化**：合理使用工具和资源，提高响应速度和开发效率

通过遵循这些最佳实践，您可以在各种软件开发场景中充分发挥 Claude Addons 的价值，提高开发效率，保证代码质量，并实现跨领域的专业协作。

## 10. 总结

Claude Addons 是一个强大的工具生态系统，通过提供专业化、个性化的 AI 代理、技能和插件，为软件开发和其他专业领域提供了高效、高质量的解决方案。本手册详细介绍了各个 addons 的功能、安装方法、使用技巧以及它们之间的协同作用，希望能够帮助您充分发挥这些工具的价值。

### 核心价值

- **提高开发效率**：通过自动化常规任务、提供智能代码分析和生成，大幅提高开发速度
- **保证代码质量**：通过专业的代码审查、安全审计和测试，确保代码质量和可靠性
- **降低开发成本**：通过减少 token 消耗、优化资源使用，降低 AI 工具的使用成本
- **促进知识共享**：通过可视化知识图谱、自动生成文档，促进团队知识共享和传承
- **支持大型项目**：通过结构化的工作流程、多代理协作，支持复杂大型项目的开发

### 工具生态系统

- **知识图谱工具**：graphify、code-review-graph、GitNexus 提供深度代码理解和可视化
- **效率优化工具**：rtk 减少 token 消耗，提高响应速度
- **开发工作流工具**：gstack、superpowers、compound-engineering 提供结构化的开发流程
- **专业代理**：Agency-Agents 提供各种专业领域的专家代理
- **插件系统**：claude-plugins-official 提供丰富的插件生态

### 最佳实践

- **工具组合**：根据任务需求和项目规模，选择合适的工具组合
- **工作流程**：遵循结构化的工作流程，确保开发质量和效率
- **上下文管理**：提供详细的项目上下文，帮助 AI 更好地理解任务
- **持续优化**：定期更新工具，学习新功能，优化使用策略
- **团队协作**：利用工具和代理的协作能力，提高团队效率
- **安全合规**：遵循安全最佳实践，保护代码和数据
- **性能优化**：合理使用工具和资源，提高响应速度和开发效率

### 未来展望

随着 AI 技术的不断发展，Claude Addons 生态系统也将持续进化。未来可能会看到：

- 更智能的代码分析和生成能力
- 更丰富的专业代理和技能
- 更深度的工具集成和协作
- 更广泛的平台支持和适配
- 更强大的多模态处理能力

通过合理利用 Claude Addons 生态系统，您可以在软件开发中获得前所未有的效率和质量提升，实现从需求分析到部署发布的全流程优化。无论是个人开发者还是大型团队，都可以从这些工具中获益，加速创新，交付更高质量的软件产品。