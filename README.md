# Line sorting plugin for Micro Editor

## Installation

```shell
cd ~/.config/micro/plug
git clone https://github.com/milnak/micro-sortlines.git sortlines
```

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

### Functions

- sortNormal - Sort lines (ascending, case sensitive)
- sortUnique - Sort lines (unique ascending, case sensitive)
- sortCaseInsensitive - Sort lines (ascending, case insensitive)
- sortCaseInsensitiveUnique - Sort lines (unique ascending, case insensitive)
- sortReverse - Sort lines (descending, case sensitive)
- sortReverseUnique - Sort lines (unique descending, case sensitive)
- sortReverseCaseInsensitive - Sort lines (descending, case insensitive)
- sortReverseCaseInsensitiveUnique - Sort lines (unique descending, case insensitive)

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
