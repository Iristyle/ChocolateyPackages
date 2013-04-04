import sublime_plugin
import os

class RecentActiveFilesEventListener(sublime_plugin.EventListener):
    def on_activated(self, view):
        if view.file_name():
            view.window().run_command("recent_active_files", { "file_name": view.file_name() })

class RecentActiveFilesCommand(sublime_plugin.WindowCommand):
    def __init__(self, window):
        sublime_plugin.WindowCommand.__init__(self, window)
        self.recent_active_files = []

    def unshift(self, file_name):
        if file_name in self.recent_active_files:
            self.recent_active_files.remove(file_name)
        self.recent_active_files.insert(0, file_name)

    def path_form_project(self, path):
        for folder in self.window.folders():
            path = path.replace(folder + '/', '', 1)
        return path

    def run(self, file_name=None):
        if file_name:
            self.unshift(file_name)
        else:
            if self.window.active_view() is not None:
                active_file = self.window.active_view().file_name()
                files = filter(lambda f: f != active_file, self.recent_active_files)
            else:
                files = self.recent_active_files

            items = [[os.path.basename(f), self.path_form_project(f)] for f in files]

            def on_done(index):
                if index >= 0:
                    self.window.open_file(files[index])

            self.window.show_quick_panel(items, on_done)
