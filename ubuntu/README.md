# Config linux box
- Set config - bashrc, bash_aliases, inputrc, sudoers and others
- Install pwsh, gh, nvm, node, npm
- Build nano 7.2 with
- syntax highlighting from - [galenguyer/nano-syntax-highlighting: Improved Nano Syntax Highlighting Files][4]



### Start the beginning - [start script][1]
```sh
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano-win/main/ubuntu/start.sh | bash
```

### Skip config files and start with - [install apps][2]
```sh
curl -o- https://raw.githubusercontent.com/Woznet/deploy-nano-win/main/ubuntu/install-apps.sh | bash
```

### nano only - [build nano][3]
```sh
curl -o- https://github.com/Woznet/deploy-nano-win/raw/main/ubuntu/build-nano.sh | bash
```



[1]: https://github.com/Woznet/deploy-nano-win/blob/main/ubuntu/start.sh
[2]: https://github.com/Woznet/deploy-nano-win/blob/main/ubuntu/install-apps.sh
[3]: https://github.com/Woznet/deploy-nano-win/blob/main/ubuntu/build-nano.sh
[4]: https://github.com/galenguyer/nano-syntax-highlighting
