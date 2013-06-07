Antiki -- a Xiki Clone for Sublime Text 2
=========================================

Antiki implements a tiny subset of [Xiki][0] for [Sublime Text 2][2].  It is intended to be more portable and predictable than sophisticated combination of Xiki and @lunixboch's [SublimeXiki][1], while implementing the essential feature of executing shell commands and replacing them with output.

Antiki considers any line starting with `$` after zero or more tabs or spaces to be a possible command for execution.  Placing your cursor on a command and pressing either "Command+Enter" or "Control-Enter" will cause Antiki to pass the command to your shell prompt, execute it, and replace a number of subquent lines with the output.  Antiki will replace any lines with more indent than the command's indent, which effectively allows you to repeately run a command by returning your cursor to the original position and hitting "Command+Enter" again.

This makes Antiki a great tool for writing documentation, examples and working through demos.

## Example 1: 
 
    $ redis-cli info | head
      redis_version:2.4.17
      redis_git_sha1:00000000
      redis_git_dirty:0
      arch_bits:64
      multiplexing_api:kqueue
      gcc_version:4.2.1
      process_id:7818
      run_id:ac64457c11931712a94ef36a9547e624893755d1
      uptime_in_seconds:51
      uptime_in_days:0

## Features:

Antiki's insistence on being stupid and simple is its greatest advantage compared to similar implementations, making it portable, maintainable and understandable.

 - Can execute shell commands in any buffer, not just Xiki buffers.
 - Does not require anything beyond Sublime Text itself, works out of the box in Windows and OSX.
 - Is much more predictable than [Xiki][0] or [SublimeXiki][1], since it does not try to outsmart Sublime Text.
 - Passes all commands through shell, ensuring features like piping to [JQ][3] or `grep` are easily available.

## Limitations:

Antiki does not provide [Xiki][0] menus or use Xiki helpers.  It also does not support continuously updating output, and will hang until a command exits or ten seconds have passed -- for these features, the much more powerful [SublimeXiki][1] is recommended.

## Contributors:

 - @efi -- bug report and fix for windows output decoding

[0]: http://xiki.org 
[1]: https://github.com/lunixbochs/SublimeXiki 
[2]: http://www.sublimetext.com 
[3]: http://stedolan.github.com/jq/ 
