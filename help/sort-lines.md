# sortlines

## Usage

Press `Ctrl-E`, enter `sortlines`, and press Enter. The command takes no arguments.

With no selection, the entire buffer is sorted. With a selection, all touched
lines are sorted in full, even if only part of the first or last line is
selected. A selection ending at column zero excludes that final line.
Forward and backward selections are supported.

Lines are sorted in ascending order using Unicode lowercase keys, without
locale-specific collation or natural numeric ordering. Case-insensitive
duplicates are removed, retaining the spelling of the first occurrence.
Whitespace is significant; blank lines are sorted first and deduplicated too.

The final newline is preserved, as is text outside the sorted range. Changed
selections remain selected over the resulting complete lines. Already-sorted,
unique text is left untouched. Read-only buffers are not modified.
Use Micro's normal Undo action (`Ctrl-Z`) to undo a sort.

## Key binding

For example, run this command from Micro's command bar:

```
bind Alt-s command:sortlines
```
