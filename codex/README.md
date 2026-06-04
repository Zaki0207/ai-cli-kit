# Codex CLI

Tips and notes for OpenAI Codex CLI.

## 官方订阅和第三方 API 隔离

如果多人共用同一个 Linux 用户，但默认的 `~/.codex/config.toml` 已经配置给
第三方 API 使用，可以保留默认 `codex` 不动，只在需要官方订阅时用
[`codex-zzy`](codex-zzy)。

这个脚本会做两件事：

- 只在当前 Codex 子进程里把 `CODEX_HOME` 切到你的个人目录，避免读取或修改 `~/.codex/config.toml`。
- 在 Codex 子进程里清掉 `OPENAI_API_KEY`、`OPENAI_BASE_URL`、`AZURE_OPENAI_*` 等 API 环境变量，避免走第三方 API。

它不会清掉 `HTTP_PROXY` / `HTTPS_PROXY`，所以仍然可以配合 `proxy-on` 访问外网。

默认行为保持不变：

```bash
codex              # 继续读取 ~/.codex/config.toml，走第三方 API
codex-zzy          # 使用单独目录里的 ChatGPT 官方订阅登录态
```

### 安装

运行一键安装脚本：

```bash
./codex/install-codex-zzy.sh
```

它会把 `codex-zzy` 和 `codex-official` 安装到 `$HOME/.local/bin`，创建
`$HOME/.codex-zzy-official`，并自动给 `~/.zshrc` / `~/.bashrc` / `~/.profile`
补上 `$HOME/.local/bin` 的 PATH 配置。

如果只想看会改什么，不实际写文件：

```bash
./codex/install-codex-zzy.sh --dry-run
```

### 首次登录

远程服务器上通常用 device auth 更方便：

```bash
codex-zzy login --device-auth
codex-zzy login status
```

确认显示 `Logged in using ChatGPT` 后，直接启动：

```bash
codex-zzy
```

带参数也会原样转发给 Codex：

```bash
codex-zzy -C /path/to/project
codex-zzy exec "summarize this repo"
```

### 注意

- 不要把 `CODEX_HOME` 全局写进 `~/.zshrc` / `~/.bashrc`，否则默认 `codex` 也会被切走。
- 不要覆盖 `codex` alias；官方订阅命令固定用 `codex-zzy`。
- 不要用 `codex-zzy login --with-api-key`。脚本会拒绝 `--with-api-key`
和 `--with-access-token`，避免这个入口被误用成 API 模式。
