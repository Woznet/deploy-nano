# Deploy-nano

## **Ubuntu**
- edit config files
- install apps like [powershell][6], [gh][7], [nvm][8]
- build [nano-7.2][4]
- add [nanorc syntax][1]

### Run all parts for Ubuntu - [start.sh][5]
```sh
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/start.sh | bash
```

***

## **Windows**
- download [nano-win][2]
- add [nanorc syntax][1]

### Run for Windows - [deploy.ps1][9]
```powershell
Invoke-Expression ([System.Net.WebClient]::new().DownloadString('https://raw.githubusercontent.com/Woznet/deploy-nano/main/windows/deploy.ps1'))
```

---

### Sources
- source of nanorc syntax - https://github.com/galenguyer/nano-syntax-highlighting
- nano-win - https://github.com/lhmouse/nano-win
  - exe - https://files.lhmouse.com/nano-win/
- nvm - https://github.com/nvm-sh/nvm

### Other helpful links
- BLFS page for nano - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/nano.html
- MS Docs PowerShell Install - https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
- gh - https://github.com/cli/cli/blob/trunk/docs/install_linux.md


[1]: https://github.com/galenguyer/nano-syntax-highlighting
[2]: https://github.com/lhmouse/nano-win
[3]: https://files.lhmouse.com/nano-win/
[4]: https://www.nano-editor.org/dist/latest/nano-7.2.tar.xz
[5]: https://github.com/Woznet/deploy-nano/blob/main/ubuntu/start.sh
[6]: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
[7]: https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
[8]: https://github.com/nvm-sh/nvm
[9]: https://github.com/Woznet/deploy-nano/blob/main/windows/deploy.ps1


