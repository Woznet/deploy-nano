# Linux Box Setup

This script configures a Linux environment by setting up system configurations, installing essential software, and building Nano with syntax highlighting.

## 🚀 **Quick Install**
Run the following command to start the full setup:
```sh
curl -sSL -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v4/start-aio.sh | bash
```

## **Minimal Install**
Run the following command to start the minimum setup:
- Does not include vscode, 1passwozd, az, ngrok, docker install script, dotnet
```sh
curl -sSL -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v4/start-aio-min.sh | bash
```

## 🔹 **Included Features**
- Configures `.bashrc`, `.bash_aliases`, `inputrc`, and `sudoers`
- Installs **PowerShell (pwsh), GitHub CLI (gh), Node.js, npm, nvm, Azure CLI**
- Builds **Nano** with [syntax highlighting][1]
- Sets up **SSH keys, bash completion, and system tools**

## 🔗 **References**
- [Nano Syntax Highlighting][1]
- [Nano Editor Git][2]

[1]: https://github.com/galenguyer/nano-syntax-highlighting
[2]:https://git.savannah.gnu.org/cgit/nano.git/
