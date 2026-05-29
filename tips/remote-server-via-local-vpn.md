# 远程服务器通过本地 VPN 访问外网

## 原理

```
远程服务器 :7897  ──SSH RemoteForward──▶  本地 127.0.0.1:7897 (VPN 代理端口)
```

SSH `RemoteForward` 在远程服务器上开一个本地端口，将流量反向转发到本机的 VPN 代理端口。
远程服务器只需把代理指向 `127.0.0.1:7897`，就能借用本机 VPN 访问外网。

## SSH 配置

`~/.ssh/config`：

```ssh
Host 10.193.25.175
  HostName 10.193.25.175
  User member
  Port 1021
  RemoteForward 7897 127.0.0.1:7897
  ServerAliveInterval 60      # 每 60s 发心跳，防止连接被踢
  ServerAliveCountMax 3       # 连续 3 次无响应才断开
  ExitOnForwardFailure yes    # 隧道建立失败时直接报错，而不是静默连上但代理不通
```

> `7897` 是本地 VPN 客户端（如 Clash）监听的 HTTP 代理端口，按实际情况修改。

## 远程服务器 Shell 配置

在远程服务器的 `~/.zshrc` 或 `~/.bashrc` 里添加：

```bash
alias proxy-on='
  export HTTP_PROXY=http://127.0.0.1:7897
  export HTTPS_PROXY=http://127.0.0.1:7897
  export http_proxy=http://127.0.0.1:7897
  export https_proxy=http://127.0.0.1:7897
  export NO_PROXY=localhost,127.0.0.1
  echo "代理已开启"
'
alias proxy-off='
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY
  echo "代理已关闭"
'
```

> 同时设置大写和小写：`curl`、`wget` 读大写，`git`、Python `requests` 优先读小写，两者都设才能覆盖所有工具。

## 使用

```bash
ssh 10.193.25.175   # SSH 连上后隧道自动建立
proxy-on            # 开启代理
curl https://google.com   # 验证
proxy-off           # 用完关掉
```

## 注意事项

- **代理生命周期与 SSH 会话绑定**：SSH 断开后远程的 7897 端口随之关闭，tmux/screen 内的后台进程会失去代理。
- **本地 VPN 必须处于连接状态**，否则转发的流量无处可去。
- **sshd 默认允许 RemoteForward 到 localhost**，无需额外配置；若服务器 `sshd_config` 有 `AllowTcpForwarding no` 则需联系管理员开启。
