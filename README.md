# deploy-nano

## **Ubuntu**
- edit config files
- install apps like powershell, gh, nvm, npm
- build [nano-7.2][4]
- add [nanorc syntax][1]

### Run all parts for Ubuntu systems - [start.sh][5]
```sh
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano-win/main/ubuntu/start.sh | bash
```

***

## **Windows**
- download [nano-win][2]
- add [nanorc syntax][1]

---

### Sources
- source of nanorc syntax - https://github.com/galenguyer/nano-syntax-highlighting
- nano-win - https://github.com/lhmouse/nano-win
  - exe - https://files.lhmouse.com/nano-win/
- nvm - https://github.com/nvm-sh/nvm

### Other helpful links
- BLFS page for nano - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/nano.html
- MS Docs PowerShell Install - https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3
- gh - apt install - https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt


[1]: https://github.com/galenguyer/nano-syntax-highlighting
[2]: https://github.com/lhmouse/nano-win
[3]: https://files.lhmouse.com/nano-win/
[4]: https://www.nano-editor.org/dist/latest/nano-7.2.tar.xz
[5]: https://github.com/Woznet/deploy-nano-win/blob/main/ubuntu/start.sh


