# Line sorting plugin for Micro Editor

## Installation

1. clone

   ```shell
   git clone git@github.com:milnak/micro-sortlines.git
   ```

2. install (Windows)

   ```PowerShell
   cd 'micro-sortlines'
   .\install-local.ps1
   ```

3. restart Micro

## Usage

See [help file](help\sortlines.md).

## References

[Creating Plugins for Micro](https://github.com/micro-editor/micro/blob/master/runtime/help/plugins.md)

[Micro API Documentation](https://pkg.go.dev/github.com/micro-editor/micro/v2/internal/action)

* [BufPane](https://pkg.go.dev/github.com/micro-editor/micro/v2/internal/action#BufPane)
* [Cursor](https://pkg.go.dev/github.com/micro-editor/micro/v2/internal/buffer#Cursor)

[Micro Official Plugin Channel](https://github.com/micro-editor/plugin-channel)

## Acknowledgements

This project is conceptually based on [vscode-sort-lines](https://github.com/Tyriar/vscode-sort-lines), the Visual Studio Code line sorting extension. Thanks, [Daniel](https://github.com/Tyriar)!

## Contributions

All contributions are welcome by pull request or issue.

## License

See [LICENSE](./LICENSE) for full text.
