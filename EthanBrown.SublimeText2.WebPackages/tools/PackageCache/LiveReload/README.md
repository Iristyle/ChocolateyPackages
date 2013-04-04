LiveReload for Sublime Text 2
=========

A web browser page reloading plugin for the [Sublime Text 2](http://sublimetext.com "Sublime Text 2") editor.

Installing
-----

Install with [Sublime Package Control](http://wbond.net/sublime_packages/package_control "Sublime Package Control"), search for LiveReload and install.

Devel branch
-----
Have a look at [devel version](https://github.com/dz0ny/LiveReload-sublimetext2/tree/devel). Which is total rewrite of plugin, supporting SublimeText 3, plugins and much more.

Browser extensions
-----
You can use both major LiveReload versions. For old one you can find instructions bellow, for new ones please visit [New browser extensions](http://help.livereload.com/kb/general-use/browser-extensions "New browser extensions") or try [self loading version](http://help.livereload.com/kb/general-use/using-livereload-without-browser-extensions "self loading version").


### [Google Chrome extension](https://chrome.google.com/extensions/detail/jnihajbhpnppcggbcgedagnkighmdlei)

![](https://github.com/mockko/livereload/raw/master/docs/images/chrome-install-prompt.png)

Click “Install”. Actually, LiveReload does not access your browser history. The warning is misleading.

![](https://github.com/mockko/livereload/raw/master/docs/images/chrome-button.png)

If you want to use it with local files, be sure to enable “Allow access to file URLs” checkbox in Tools > Extensions > LiveReload after installation.

### Safari extension

For now it only works with self loading version:

    <script>document.write('<script src="http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1"></' + 'script>')</script>


### [Firefox 4 extension](http://feedback.livereload.com/knowledgebase/articles/86242-how-do-i-install-and-use-the-browser-extensions-)

![](http://static-cdn.addons.mozilla.net/img/uploads/previews/full/63/63478.png?modified=1317506904)


## Usage

Now, if you are using Safari, right-click the page you want to be livereload'ed and choose “Enable LiveReload”:

![](https://github.com/mockko/livereload/raw/master/docs/images/safari-context-menu.png)

If you are using Chrome, just click the toolbar button (it will turn green to indicate that LiveReload is active).

----

You can also use the Preferences menu to change port, version and type of reloading(full, js,css).

## Compass

![](http://cdn.nmecdesign.com/wp/wp-content/uploads/2011/12/Compass-Logo.png)

Want to use Livereload with compass ? Now you can !

.scss and .css have to be in the same directory , if no config.rb file is found one will automatically generated !

So if you want to start using compass, install compass gem, edit a xxx.scss file and voila ! A .css file would be automatically generated.
