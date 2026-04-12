# Claude Addons 安装脚本

[English Version](README.md)

## 脚本简介

这是一个用于管理 Claude Code 相关项目的安装和更新脚本，能够自动处理 Git 仓库的克隆/更新、工具安装、技能配置等操作。

## 主要功能

- **Git 仓库管理**：自动克隆或更新多个 Claude 相关项目
- **网络优化**：内置网络测试和 GitHub 加速链接，提高克隆成功率
- **工具安装**：自动安装 graphify、code-review-graph、GitNexus、rtk 等工具
- **技能配置**：自动复制和配置 gstack、superpowers、compound-engineering 等技能
- **版本检查**：避免重复安装同一个版本的工具
- **清理选项**：可选择是否保留 Git 仓库，保持目录整洁
- **错误处理**：插件安装失败时不会中断整个脚本执行

## 支持的项目

- **Agents**：agency-agents、compound-engineering-plugin/agents
- **Plugins**：claude-plugins-official
- **Skills**：gstack、superpowers/skills、compound-engineering-plugin/skills、graphify
- **Tools**：graphify、code-review-graph、GitNexus、rtk

## 安装方法

### 方法一：直接下载脚本

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

### 方法二：直接执行（一键安装）

```bash
curl -fsSL https://raw.githubusercontent.com/bingerz/claude-addons/refs/heads/master/install-claude-addons.sh | sh
```

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

### 工具使用指南

#### code-review-graph

1. 在代码项目根目录执行：
   ```bash
   code-review-graph install --platform claude-code  # 配置 code-review-graph
   code-review-graph build                         # 构建代码库图谱
   ```

2. 作用：Claude Code 在处理代码时会只读取相关文件，大幅减少 token 使用。

#### GitNexus

1. 在代码项目根目录执行：
   ```bash
   npx gitnexus analyze  # 分析代码库并创建知识图谱
   npx gitnexus setup    # 配置 MCP 服务器（仅需执行一次）
   ```

2. 作用：Claude Code 会获得代码库的深度架构视图，避免遗漏依赖和破坏调用链。

#### rtk

1. 初始化 rtk（仅需执行一次）：
   ```bash
   rtk init -g                     # 为 Claude Code / Copilot 配置
   rtk init -g --gemini            # 为 Gemini CLI 配置
   rtk init -g --codex             # 为 Codex (OpenAI) 配置
   ```

2. 重新启动 AI 工具，然后测试：
   ```bash
   git status  # 会自动重写为 rtk git status
   ```

3. 作用：减少 LLM token 消耗 60-90%，大幅提高代码处理效率。

#### graphify

1. 安装技能：
   ```bash
   graphify install --platform claude
   ```

2. 作用：提供代码可视化和分析功能，帮助更好地理解代码结构。

### 技能使用指南

#### gstack

- 安装后会自动配置到 Claude 的技能目录
- 可以在 Claude Code 中激活 gstack 模式，获得更强大的代码分析能力

#### superpowers

- 包含多个专业技能，如前端开发、后端开发、数据分析等
- 安装后会自动复制到 Claude 的技能目录
- 可以在 Claude Code 中激活相应的技能模式

#### compound-engineering

- 提供工程化相关的技能和代理
- 安装后会自动复制到 Claude 的技能和代理目录

## 使用技巧

1. **网络问题解决**：如果遇到 GitHub 连接问题，脚本会自动尝试使用加速链接。

2. **快速更新**：使用 `--keep-repos` 参数可以保留 Git 仓库，后续运行脚本时会自动 pull 最新代码。

3. **工具版本管理**：脚本会检查工具是否已安装，避免重复安装同一个版本。

4. **目录清理**：默认情况下，脚本会在安装完成后清理 Git 仓库，保持目录整洁。

5. **插件安装**：如果某些插件安装失败，脚本会继续执行其他任务，不会中断整个安装过程。

6. **环境变量**：脚本会自动检测系统环境，选择最合适的安装方式（如 Homebrew 或快速安装）。

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

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个脚本！

## 许可证

MIT License