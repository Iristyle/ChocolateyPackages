import sublime
import sublime_plugin
from related import *


class RelatedFilesCommand(sublime_plugin.WindowCommand):
    def run(self, index=None):
        active_file_path = self.__active_file_path()

        if active_file_path:
            # Builds a list of related files for the current open file.
            self.__related = Related(active_file_path, self.__patterns(), sublime.active_window().folders())

            self.window.show_quick_panel(self.__related.descriptions(), self.__open_file)
        else:
            self.__status_msg("No open files")

    # Opens the file in path.
    def __open_file(self, index):
        if index >= 0:
            self.window.open_file(self.__related.files()[index])
        else:
            self.__status_msg("No related files found")

    # Retrieves the patterns from settings.
    def __patterns(self):
        return sublime.load_settings("RelatedFiles.sublime-settings").get('patterns')

    # Returns the activelly open file path from sublime.
    def __active_file_path(self):
        if self.window.active_view():
            file_path = self.window.active_view().file_name()

            if file_path and len(file_path) > 0:
                return file_path

    # Displays a status message on sublime.
    def __status_msg(self, message):
        sublime.status_message(message)
