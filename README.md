# Line sorting plugin for Micro Editor

### Installation

Settings:

Add this repo as a pluginrepos option in the `~/.config/micro/settings.json` file (it is necessary to restart the micro after this change):

```json
{
  "pluginrepos": [
      "https://raw.githubusercontent.com/milnak/micro-sortlines/main/repo.json"
  ]
}
```

Installation:

In your micro editor press `Ctrl-e` and run command:

`> plugin install sortlines`

or run in your shell:

`micro -plugin install sortlines`

Then restart micro.

## Usage

Press `Ctrl-E`, type `sortlines` (or other function, see below), and press Enter.

- With a selection, sorts the complete lines touched by the selection.
- Without a selection, sorts the whole buffer.
- Sorts ascending, ignoring case, and removes case-insensitive duplicates.
  The first occurrence's spelling is retained.
- Preserves the final newline and text outside the sorted range.

See the [help file](help/sort-lines.md) or run `help sort-lines` in Micro
for selection details and a key binding example.

### Commands

All commands take no arguments and use the same selection and newline handling.

| Command | Order | Case-insensitive | Remove duplicates |
| --- | --- | --- | --- |
| `sortlines` | Ascending | Yes | Yes |
| `sortnormal` | Ascending | No | No |
| `sortunique` | Ascending | No | Yes |
| `sortcaseinsensitive` | Ascending | Yes | No |
| `sortcaseinsensitiveunique` | Ascending | Yes | Yes |
| `sortreverse` | Descending | No | No |
| `sortreverseunique` | Descending | No | Yes |
| `sortreversecaseinsensitive` | Descending | Yes | No |
| `sortreversecaseinsensitiveunique` | Descending | Yes | Yes |

Case-insensitive commands use Unicode lowercase keys, not locale-specific
collation or full Unicode case folding. Equal keys retain their original order.
Unique commands retain the first occurrence, using the command's case setting.
Already-sorted text without removable duplicates is left untouched.

## Tests

From the plugin directory, run with Lua 5.3 or newer:

```shell
lua tests/sortlines_test.lua
```

The tests mock Micro's APIs and cover command modes, selection boundaries,
newline preservation, Unicode coordinates, and unchanged/read-only buffers.
Interactive selection and undo behavior should also be checked in Micro.

## Future

Line length sorting functionality:

- sortLineLength - Sort lines (by line length ascending)
- sortLineLengthReverse - Sort lines (by line length descending)

Misc functionality:

- shuffleLines - Shuffle lines

Duplicate functionality:

- removeDuplicateLines - Remove duplicate lines
- keepOnlyDuplicateLines - Keep only duplicated lines
- keepOnlyUniqueLines - Keep only unique lines

## References

[Creating Plugins for Micro](https://github.com/micro-editor/micro/blob/master/runtime/help/plugins.md)

[Micro API Documentation](https://pkg.go.dev/github.com/micro-editor/micro/v2/internal/action)

- [BufPane](https://pkg.go.dev/github.com/micro-editor/micro/v2/internal/action#BufPane)
- [Cursor](https://pkg.go.dev/github.com/micro-editor/micro/v2/internal/buffer#Cursor)

[Micro Official Plugin Channel](https://github.com/micro-editor/plugin-channel)

## Acknowledgements

This project is conceptually based on [vscode-sort-lines](https://github.com/Tyriar/vscode-sort-lines), the Visual Studio Code line sorting extension. Thanks, [Daniel](https://github.com/Tyriar)!

## Contributions

All contributions are welcome by pull request or issue.

## License

See [LICENSE](./LICENSE) for full text.

## Updating archive

When a new version is created, a new archive release can be created using:

`zip -r -9 .\archive\v1.0.0.zip * -x 'archive/*' -x 'tests/*' -x '.gitignore'`
