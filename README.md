# Claude Remote Setup

One-command setup for a remote Claude Code workstation on Ubuntu 24.04.

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
```

### 2. Add VM to SSH config

Edit `~/.ssh/config`:
```
Host claude-vm
    HostName <your-vm-ip>
    User root
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
```

## What it installs

- **Security**: UFW firewall, fail2ban, key-only SSH, auto security updates
- **Tools**: tmux, git, curl, micro (editor), htop, gh (GitHub CLI)
- **Node.js 22** + **Claude Code**
- **SSH key**: Generated and added to GitHub automatically

## What it configures

- **Tmux**: Ctrl-a prefix, mouse support, vim-style pane navigation
- **Bash**: Auto-attach tmux on SSH login, aliases, colored prompt
- **Git**: Name and email from your `.env`
- **GitHub**: Authenticated via gh CLI, SSH key added

## Tmux basics

| Key | Action |
|-----|--------|
| `Ctrl-a d` | Detach (leave session running) |
| `Ctrl-a \|` | Split pane vertically |
| `Ctrl-a -` | Split pane horizontally |
| `Ctrl-a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl-a r` | Reload tmux config |

## Multiple VMs

Add each VM to `~/.ssh/config`:
```
Host claude-vm-1
    HostName 1.2.3.4
    User root

Host claude-vm-2
    HostName 5.6.7.8
    User root
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
gh gist edit 13d635eab299c9a4bde76af1846e439a ~/Code/claude-remote/setup.sh
```

## Gist URL

https://gist.github.com/esauter5/13d635eab299c9a4bde76af1846e439a
