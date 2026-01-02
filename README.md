# Claude Remote Setup

One-command setup for a remote Claude Code workstation on Ubuntu 24.04.

Creates a non-root `claude` user so you can use `--dangerously-skip-permissions`.

## Quick Start

### 1. One-time local setup

```bash
cd ~/Code/claude-remote
cp .env.example .env
```

Edit `.env` with your details:
```
GIT_NAME="Your Name"
GIT_EMAIL="you@example.com"
VM_HOST="claude-vm"
VM_USER="claude"
```

### 2. Add VM to SSH config

Edit `~/.ssh/config`:
```
Host claude-vm
    HostName <your-vm-ip>
    User claude
```

### 3. Provision the VM

```bash
./run.sh
```

Complete the GitHub browser auth when prompted. Done.

### 4. Use it

```bash
ssh claude-vm    # Auto-attaches to tmux
c                # Alias for 'claude'
cc               # Alias for 'claude --continue'
cds              # Alias for 'claude --dangerously-skip-permissions'
```

## What it installs

- **Security**: UFW firewall, fail2ban, key-only SSH, auto security updates
- **Tools**: tmux, git, curl, micro (editor), htop, gh (GitHub CLI)
- **Node.js 22** + **Claude Code**
- **SSH key**: Generated and added to GitHub automatically
- **Non-root user**: `claude` user with passwordless sudo

## What it configures

- **Tmux**: Ctrl-a prefix, mouse support, vim-style pane navigation
- **Bash**: Auto-attach tmux on SSH login, aliases, colored prompt
- **Git**: Name and email from your `.env`
- **GitHub**: Authenticated via gh CLI, SSH key added

## Why a non-root user?

Claude Code blocks `--dangerously-skip-permissions` when running as root for security reasons. The `claude` user is a regular user with sudo access, so the flag works.

## Tmux basics

| Key | Action |
|-----|--------|
| `Ctrl-a d` | Detach (leave session running) |
| `Ctrl-a \|` | Split pane vertically |
| `Ctrl-a -` | Split pane horizontally |
| `Ctrl-a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl-a s` | Switch sessions |
| `Ctrl-a r` | Reload tmux config |

## Multiple sessions

```bash
tmux new -s projectA      # Create named session
tmux new -s projectB      # Another session
tmux ls                   # List sessions
tmux attach -t projectA   # Attach to specific session
```

## Multiple VMs

Add each VM to `~/.ssh/config`:
```
Host claude-vm-1
    HostName 1.2.3.4
    User claude

Host claude-vm-2
    HostName 5.6.7.8
    User claude
```

Run setup on a specific host:
```bash
./run.sh claude-vm-2
```

## Hetzner VM recommendations

- **CPX21** (3 vCPU, 4GB RAM, ~€8/mo) - sufficient for Claude Code
- **Ubuntu 24.04**
- **Add your SSH key** during VM creation

## Updating the gist

After editing `setup.sh`:
```bash
gh gist edit 3e32fea061b53d51c524b34897bdb15d ~/Code/claude-remote/setup.sh
```

## Gist URL

https://gist.github.com/esauter5/3e32fea061b53d51c524b34897bdb15d
