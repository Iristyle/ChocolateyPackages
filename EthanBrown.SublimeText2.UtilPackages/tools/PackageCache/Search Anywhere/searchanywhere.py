# Written by Eric Martel (emartel@gmail.com / www.ericmartel.com)

import sublime
import sublime_plugin

import subprocess
import webbrowser
import threading
import os
import json

searchanywhere_dir = os.getcwdu()

# Helper functions
def SearchFor(view, text, searchurl):
    if not searchurl:
        # see if we have an extension match first, then use default
        settings = sublime.load_settings(__name__ + '.sublime-settings')

        filename, ext = os.path.splitext(view.file_name())
        typesettings = settings.get('searchanywhere_type_searchengine', [])

        foundsetting = False
        for typesetting in typesettings:
            if typesetting['extension'] == ext:
                foundsetting = True
                searchurl = typesetting['searchurl']

        if not foundsetting:
            if settings.has('searchanywhere_searchurl'):
                searchurl = settings.get('searchanywhere_searchurl')
            else:
                sublime.error_message(__name__ + ': No Search Engine selected')
                return
    else:
        # search url is provided by the caller
        pass

    url = searchurl.replace('{0}', text.replace(' ','%20'))
    webbrowser.open_new_tab(url)

def ShowSearchEnginesList(window, callback):
    searchengines = []
    if os.path.exists(searchanywhere_dir + os.sep + 'searchengines.json'):
        f = open(searchanywhere_dir + os.sep + 'searchengines.json')
        searchengineslist = json.load(f)
        f.close()

        for entry in searchengineslist.get('searchengines'):
            formattedentry = []
            formattedentry.append(entry.get('name'))
            formattedentry.append(entry.get('baseurl'))
            searchengines.append(formattedentry)

    window.show_quick_panel(searchengines, callback)

def GetSearchEngineEntry(picked):
    f = open(searchanywhere_dir + os.sep + 'searchengines.json')
    searchengineslist = json.load(f)
    entry = searchengineslist.get('searchengines')[picked]
    f.close()
    return entry

class SearchAnywhereFromSelectionAskCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        ShowSearchEnginesList(self.view.window(), self.on_select_done)

    def on_select_done(self, picked):
        entry = GetSearchEngineEntry(picked)

        for selection in self.view.sel():
            # if the user didn't select anything, search the currently highlighted word
            if selection.empty():
                selection = self.view.word(selection)

            text = self.view.substr(selection)
            SearchFor(self.view, text, entry.get('searchurl'))

class SearchAnywhereFromInputAskCommand(sublime_plugin.WindowCommand):
    def run(self):
        ShowSearchEnginesList(self.window, self.on_select_done)

    def on_select_done(self, picked):
        self.entry = GetSearchEngineEntry(picked)

        self.window.show_input_panel('Search on ' + self.entry.get('name') + ' for', '', self.on_done, self.on_change, self.on_cancel)

    def on_done(self, input):
        SearchFor(self.window.active_view(), input, self.entry.get('searchurl'))

    def on_change(self, input):
        pass

    def on_cancel(self):
        pass


class SearchAnywhereFromSelectionCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        for selection in self.view.sel():
            # if the user didn't select anything, search the currently highlighted word
            if selection.empty():
                selection = self.view.word(selection)
            
            text = self.view.substr(selection)
            SearchFor(self.view, text, None)

class SearchAnywhereFromInputCommand(sublime_plugin.WindowCommand):
    def run(self):
        settings = sublime.load_settings(__name__ + '.sublime-settings')
        if settings.has('searchanywhere_searchengine'):
            engine = settings.get('searchanywhere_searchengine')
            self.window.show_input_panel('Search on ' + engine + ' for', '', self.on_done, self.on_change, self.on_cancel)
        else:
            sublime.error_message(__name__ + ': No Search Engine selected')

    def on_done(self, input):
        SearchFor(self.window.active_view(), input, None)

    def on_change(self, input):
        pass

    def on_cancel(self):
        pass

# Sets the default Search Engine to use
class SearchAnywhereSelectDefaultSearchEngineCommand(sublime_plugin.WindowCommand):
    def run(self):
        ShowSearchEnginesList(self.window, self.on_select_done)

    def on_select_done(self, picked):
        entry = GetSearchEngineEntry(picked)

        settings = sublime.load_settings(__name__ + '.sublime-settings')
        settings.set('searchanywhere_searchengine', entry.get('name'))
        settings.set('searchanywhere_searchurl', entry.get('searchurl'))
        sublime.save_settings(__name__ + '.sublime-settings')

# Sets the default Search Engine to use for files sharing the view's extension
class SearchAnywhereSelectSearchEngineForTypeCommand(sublime_plugin.WindowCommand):
    def run(self):
        self.filename, self.ext = os.path.splitext(self.window.active_view().file_name())
        ShowSearchEnginesList(self.window, self.on_select_done)

    def on_select_done(self, picked):
        entry = GetSearchEngineEntry(picked)

        settings = sublime.load_settings(__name__ + '.sublime-settings')

        typesettings = settings.get('searchanywhere_type_searchengine', [])

        newsetting = {}
        newsetting['extension'] = self.ext
        newsetting['name'] = entry.get('name')
        newsetting['searchurl'] = entry.get('searchurl')

        typesettings.append(newsetting)

        settings.set('searchanywhere_type_searchengine', typesettings)
        sublime.save_settings(__name__ + '.sublime-settings')