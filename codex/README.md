# Codex CLI

Tips and notes for OpenAI Codex CLI.

## 官方订阅和第三方 API 隔离

如果多人共用同一个 Linux 用户，但默认的 `~/.codex/config.toml` 已经配置给
第三方 API 使用，可以保留默认 `codex` 不动，只在需要官方订阅时用
[`codex-zzy`](codex-zzy)，需要自己的第三方 API 时用
[`codex-zzy-api`](codex-zzy-api)。

这个脚本会做两件事：

- 只在当前 Codex 子进程里把 `CODEX_HOME` 切到你的个人目录，避免读取或修改 `~/.codex/config.toml`。
- 在 Codex 子进程里清掉 `OPENAI_API_KEY`、`OPENAI_BASE_URL`、`AZURE_OPENAI_*` 等 API 环境变量，避免走第三方 API。

它不会清掉 `HTTP_PROXY` / `HTTPS_PROXY`，所以仍然可以配合 `proxy-on` 访问外网。

默认行为保持不变：

```bash
codex              # 继续读取 ~/.codex/config.toml，走第三方 API
codex-zzy          # 使用单独目录里的 ChatGPT 官方订阅登录态
codex-zzy-api      # 使用单独目录里的个人第三方 API 配置
```

### 安装

运行一键安装脚本：

```bash
./codex/install-codex-zzy.sh
```

它会把 `codex-zzy`、`codex-zzy-api` 和 `codex-official` 安装到
`$HOME/.local/bin`，创建 `$HOME/.codex-zzy-official` 和
`$HOME/.codex-zzy-api`，并自动给 `~/.zshrc` / `~/.bashrc` / `~/.profile`
补上 `$HOME/.local/bin` 的 PATH 配置。安装脚本只会给
`$HOME/.codex-zzy-api` 放 `config.toml.example`，不会写入你的 API key。

如果只想看会改什么，不实际写文件：

```bash
./codex/install-codex-zzy.sh --dry-run
```

### 首次登录

官方订阅：

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

个人第三方 API：

```bash
cp "$HOME/.codex-zzy-api/config.toml.example" "$HOME/.codex-zzy-api/config.toml"
vi "$HOME/.codex-zzy-api/config.toml"
codex-zzy-api setup
codex-zzy-api
```

`codex-zzy-api` 缺少 `$HOME/.codex-zzy-api/config.toml` 时会直接退出，不会回退读取
`~/.codex/config.toml`。启动时它会先清掉共享 shell 里的 `OPENAI_*` / `AZURE_OPENAI_*`
变量，避免串到默认第三方 API。

`codex-zzy-api setup` 只负责交互式读取 API key，并通过 `codex login --with-api-key`
保存到 `$HOME/.codex-zzy-api/auth.json`。`config.toml` 仍然由你从
`config.toml.example` 复制后手动填写，方便直接复制和检查具体配置内容。

### 注意

- 不要把 `CODEX_HOME` 全局写进 `~/.zshrc` / `~/.bashrc`，否则默认 `codex` 也会被切走。
- 不要覆盖 `codex` alias；官方订阅命令固定用 `codex-zzy`，个人第三方 API 固定用 `codex-zzy-api`。
- 不要用 `codex-zzy login --with-api-key`。脚本会拒绝 `--with-api-key`
和 `--with-access-token`，避免这个入口被误用成 API 模式。
