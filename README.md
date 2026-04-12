# Claude Addons Installation Script

## Script Introduction

This is a script for managing the installation and update of Claude Code related projects, capable of automatically handling Git repository cloning/updating, tool installation, skill configuration, and other operations.

## Main Features

- **Git Repository Management**: Automatically clone or update multiple Claude-related projects
- **Network Optimization**: Built-in network testing and GitHub acceleration links to improve cloning success rate
- **Tool Installation**: Automatically install tools like graphify, code-review-graph, GitNexus, rtk, etc.
- **Skill Configuration**: Automatically copy and configure skills like gstack, superpowers, compound-engineering, etc.
- **Version Check**: Avoid repeated installation of the same version of tools
- **Cleanup Option**: Optional to keep or remove Git repositories to maintain a clean directory
- **Error Handling**: Plugin installation failures won't interrupt the entire script execution

## Supported Projects

- **Agents**: agency-agents, compound-engineering-plugin/agents
- **Plugins**: claude-plugins-official
- **Skills**: gstack, superpowers/skills, compound-engineering-plugin/skills, graphify
- **Tools**: graphify, code-review-graph, GitNexus, rtk

## Installation Methods

### Method 1: Directly Download the Script

1. Download the script to your local machine:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/bingerz/claude-addons/refs/heads/master/install-claude-addons.sh -o install-claude-addons.sh
   ```

2. Give execute permission:
   ```bash
   chmod +x install-claude-addons.sh
   ```

3. Run the script:
   ```bash
   ./install-claude-addons.sh
   ```

### Method 2: Direct Execution (One-click Installation)

```bash
curl -fsSL https://raw.githubusercontent.com/bingerz/claude-addons/refs/heads/master/install-claude-addons.sh | sh
```

## Usage

### Basic Usage

- **Default Mode** (clean up Git repositories after installation):
  ```bash
  ./install-claude-addons.sh
  ```

- **Keep Repositories Mode** (keep Git repositories for future updates):
  ```bash
  ./install-claude-addons.sh --keep-repos
  ```

### Tool Usage Guide

#### code-review-graph

1. Execute in the root directory of your code project:
   ```bash
   code-review-graph install --platform claude-code  # Configure code-review-graph
   code-review-graph build                         # Build codebase graph
   ```

2. Purpose: Claude Code will only read relevant files when processing code, greatly reducing token usage.

#### GitNexus

1. Execute in the root directory of your code project:
   ```bash
   npx gitnexus analyze  # Analyze codebase and create knowledge graph
   npx gitnexus setup    # Configure MCP server (only need to execute once)
   ```

2. Purpose: Claude Code will obtain a deep architectural view of the codebase, avoiding missing dependencies and breaking call chains.

#### rtk

1. Initialize rtk (only need to execute once):
   ```bash
   rtk init -g                     # Configure for Claude Code / Copilot
   rtk init -g --gemini            # Configure for Gemini CLI
   rtk init -g --codex             # Configure for Codex (OpenAI)
   ```

2. Restart your AI tool, then test:
   ```bash
   git status  # Will be automatically rewritten to rtk git status
   ```

3. Purpose: Reduce LLM token consumption by 60-90%, greatly improving code processing efficiency.

#### graphify

1. Install skill:
   ```bash
   graphify install --platform claude
   ```

2. Purpose: Provide code visualization and analysis functions to better understand code structure.

### Skill Usage Guide

#### gstack

- After installation, it will be automatically configured to Claude's skills directory
- You can activate gstack mode in Claude Code to get more powerful code analysis capabilities

#### superpowers

- Contains multiple professional skills, such as front-end development, back-end development, data analysis, etc.
- After installation, it will be automatically copied to Claude's skills directory
- You can activate the corresponding skill mode in Claude Code

#### compound-engineering

- Provides engineering-related skills and agents
- After installation, it will be automatically copied to Claude's skills and agents directories

## Usage Tips

1. **Network Problem Solution**: If you encounter GitHub connection issues, the script will automatically try to use acceleration links.

2. **Quick Update**: Using the `--keep-repos` parameter can keep Git repositories, and the script will automatically pull the latest code when run later.

3. **Tool Version Management**: The script will check if tools are already installed to avoid repeated installation of the same version.

4. **Directory Cleanup**: By default, the script will clean up Git repositories after installation to keep the directory tidy.

5. **Plugin Installation**: If some plugins fail to install, the script will continue to execute other tasks without interrupting the entire installation process.

6. **Environment Variables**: The script will automatically detect the system environment and choose the most appropriate installation method (such as Homebrew or quick installation).

## Notes

- The script requires network connection to clone Git repositories and install tools
- Some tools require Python or Node.js environment
- The first run may take a long time because it needs to clone multiple repositories and install multiple tools
- It is recommended to run the script regularly to keep tools and skills updated

## Troubleshooting

- **Git Clone Failure**: Check network connection, the script will automatically try to use acceleration links
- **Tool Installation Failure**: Check if Python or Node.js environment is normal
- **Plugin Installation Failure**: Some plugins may not exist in Claude's plugin market, which is normal
- **Skill Configuration Failure**: Check if the target directory permissions are correct

## Contribution

Welcome to submit Issues and Pull Requests to improve this script!

## License

MIT License