# Open Search Result Plugin for Sublime Text 2

This plugin creates a command that allows you to open files listed in the search
results of the 'Find in Files' command.

- When run on a line in the search results that includes a line number, e.g., 
"102:    print 'foo'" it opens the file at the correct line number.

- When run on a line that contains a file path like '/path/to/somewhere:'
in the search listing, it opens the file without a line number specified.

## Key Binding

- The default key binding is a Vintage command mode key: "g, o".

## Customizing

You can change various things about the plugin by adding user settings:

- 'highlight_search_results': Set to false to disable highlighting openable
paths (the open command will still work)
- 'highlight_search_scope': The scope that will be used to color the outline for
openable paths or the icon. See your theme file for examples of colors.
- 'highlight_search_icon': If you want an icon to show up in the gutter next to
openable paths, include a valid icon name as a string (e.g., 'circle', 'dot' or
'bookmark')
- 'open_search_result_everywhere': Set to true to enable this plugin on all
files not just Find Results panes. You can use this for saving and reopening
your find results.
