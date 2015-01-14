# Changelog

### master

- split the main script into ftplugin, plugin and autoload directories
- remove tab characters from the source and whitespace cleanup
- remove script headers, give credits to the authors in the README
- drop support for vim versions 5 and 6
- use `keepjumps` so that jumplist is not messed up
- consistently use longer VimL keywords (function, command, syntax etc)
- improve error message shown when man page is not found
- move scratch buffer local options to ft file
- update manpage buffer name
- `:Vman` - opens a manpage in vertical split
- add `:Sman` (the same as `:Man`) for "interface" consistency
- `tabstop=8` for manpages
- add all tag mappings and map them to the same action
- [[ and ]] mappings for section movement
- remove the mapping "guards". If the user installed the plugin, they are most
  likely wanted.
- enable <bar> (in vim's command line) to follow man commands
- command line completion for `:Man`, `:Sman` and `:Vman` commands
- switch to different implementation for `strip_file_names` completion helper
  function (vim's `map()` function errors out for larger lists)
