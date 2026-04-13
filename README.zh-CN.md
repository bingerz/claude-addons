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

有关工具的详细使用指南，请参考 [Claude Addons 使用手册](USER_MANUAL.zh-CN.md)，其中包含了 code-review-graph、GitNexus、rtk 和 graphify 等工具的完整安装步骤、使用方法、核心功能和最佳实践。

### 技能使用指南

有关技能的详细使用指南，请参考 [Claude Addons 使用手册](USER_MANUAL.zh-CN.md)，其中包含了 gstack、superpowers 和 compound-engineering 等技能的完整安装步骤、使用方法、核心功能和最佳实践。

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