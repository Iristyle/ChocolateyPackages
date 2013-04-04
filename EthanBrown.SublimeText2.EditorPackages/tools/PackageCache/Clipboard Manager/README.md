Clipboard Manager plugin for Sublime Text 2
===========================================

A version of the Sublime Text 2 plugin at <http://www.sublimetext.com/forum/viewtopic.php?f=5&t=2260&start=0>
that makes for TextMate-like clipboard history.

Originally written by AJ Palkovic ([ajpalkovic](https://github.com/ajpalkovic/SublimePlugins)),
modified by Martin Aspeli ([optilude](https://gist.github.com/1132507)), and
further modified and packaged for `Package Control` by Colin Thomas-Arnold
([colinta](https://github.com/colinta/SublimeClipboardManager))

My version of this plugin *does not use* `clipboard_history` as the prefix.  See
the full command-list below.

Installation
------------

1. Using Package Control, install "Clipboard Manager"

Or:

1. Open the Sublime Text 2 Packages folder

    - OS X: ~/Library/Application Support/Sublime Text 2/Packages/
    - Windows: %APPDATA%/Sublime Text 2/Packages/
    - Linux: ~/.Sublime Text 2/Packages/

2. clone this repo
3. Install keymaps for the commands (see Example.sublime-keymap for my preferred keys)

Commands
--------

**The basics**

`clipboard_manager_cut`: Self Explanatory

`clipboard_manager_copy`: Self Explanatory

`clipboard_manager_paste`: Self Explanatory.

*Options*: indent (default: False): Determines whether to use the `paste` or
`paste_and_indent` built-in command.

- - - - - -

**Navigating clipboard history**

`clipboard_manager_next_and_paste` (`super+alt+v`)

Goes to the next entry in the history and pastes it.
*Options*: indent (default: `False`)

`clipboard_manager_previous_and_paste` (`super+shift+v`)

Goes to the previous entry in the history and pastes it.
*Options*: indent (default: `False`)

`clipboard_manager_next` (`super+pageup` aka `super+fn+up`)

Goes to the next entry in the history, but doesn't paste.  (the content will
appear as a status message)

`clipboard_manager_previous` (`super+pagedown` aka `super+fn+down`)

Goes to the previous entry in the history, but doesn't paste.  (the content will
appear as a status message)

`clipboard_manager_choose_and_paste` (`super+ctrl+alt+v`)

Shows the clipboard history in a "quick panel".

`clipboard_manager_show` (`super+ctrl+shift+v, /`)

Shows the clipboard history in an "output panel", and points to the current
clipboard item.  This was mostly useful for development, but you might find it
beneficial as well.

- - - - - -

**Registers**

Right now registers do not add/remove from the clipboard history.  *This may
change!!*  I would appreciate feedback about this feature.

`clipboard_manager_copy_to_register` (there are a ton, e.g. `super+ctrl+shift+c, 1`, `super+ctrl+shift+c, a`)

Puts the selection into a `register`.  The example keymap includes a register
binding for every number and letter.  Register keys should be single characters.

`clipboard_manager_paste_from_register` (`super+ctrl+shift+v, 1`, `super+ctrl+shift+v, a`)

Pastes the contents of a `register`.  Again, there are lots of example key
bindings.

`clipboard_manager_show_registers` (`super+ctrl+shift+v, ?`)

Shows the clipboard registers in an "output panel", similar to
`clipboard_manager_show`.

- - - - - -

**Helpful Tips**

There are two ways to find out what you've got hanging out in your clipboard
history, you should use both.  The `clipboard_manager_choose_and_paste` command
is your goto.  It uses the fuzzy finder input panel, so you can quickly find and
paste the entry you want.

The other useful trick is to use `clipboard_manager_show` to show an output
panel at the bottom of the screen.  As you scroll through history using
`clipboard_manager_next` and `clipboard_manager_previous`, it will update that
panel, with an arrow pointing the current entry.  Then you can
`clipboard_manager_next_and_paste`, and it will get updated then, too.  Keeps
you sane if you're doing something crazy.

If you've got a repetive task to do, with lots of copy/pastes, use registers.
They do not get affected by usual copy/pasting, so you can rest assured that
your work flow will not get affected.  The keyboard shortcuts are unfortunately
quite verbose (`super+ctrl+shift+c, letter/digit`), but look at
Example.sublime-keymap and you'll see that it is easy to assign a quicker
shortcut for registers you like to use.  Registers do not have to be one letter,
any string can be used as the key.
