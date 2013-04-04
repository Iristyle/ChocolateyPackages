Abacus Alignment Plugin for Sublime Text 2
================

![This work?](http://dl.dropbox.com/u/5514249/Abacus.gif)

I'm pretty anal about aligning things in my code, but the alignment plugins I tried were more-or-less one-trick-ponies, and I didn't like any of their tricks, so I made my own.

My one anal pony trick involves allowing you to slide the operator like an abacus bead, toward either the left or the right hand side, by giving each possible token a `gravity` property like so:

``` json
{
    "com.khiltd.abacus.separators": 
    [    
        { 
            "token":                ":",
            "gravity":              "left",
            "preserve_indentation": true
        },
        { 
            "token":                "=",
            "gravity":              "right",
            "preserve_indentation": true
        }
    ]
}
```

Abacus focuses on aligning assignments in as language-agnostic a manner as possible and strives to address most of the open issues in that other, more popular plugin (it won't even jack up your Backbone routes!). It is, however, an *alignment* tool and *not* a full-blown beautifier. It works best when there's one assignment per line; if you like shoving dozens of CSS or JSON declarations on a single line then you are an enemy of readability and this plugin will make every effort to hinder and harm your creature on Earth as far as it is able.

`preserve_indentation` is a tip that you might be working in a language where whitespace is significant, thereby suggesting that Abacus should make no effort to normalize indentation across lines. It's not foolproof, especially if you set your tab width really, really low, but it tries harder than Cory Doctorow ever has. OK, you're right... It would be impossible for anyone to try harder than that.

Usage
============

Make a selection, then `command + option + control + ]`.

Think the plugin's crazy? Add the following to your config:

```
"com.khiltd.abacus.debug": true
```

and Abacus will dump its thoughts out to Sublime Text's console like so:

```
    margin:0;
          ^
     padding:0;
            ^
    border-style:none;
                ^
```

Caveats
============

I've used nothing but Macs since 1984 and do absolutely **no** testing in Windows or Ububian's window manager of the minute. If something's broken in some OS I don't own, you'll need to have a suggestion as to how it can be fixed as I'm unlikely to have any idea what you're talking about.

I don't care if you like real tabs or Windows line endings and don't bother with handling them. Seriously, what year is this? 
