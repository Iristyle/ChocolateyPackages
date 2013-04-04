import sublime
import sublime_plugin
from os import path
import tempfile
import sys
import re

PACKAGE_SETTINGS = "ExportHtml.sublime-settings"

if sublime.platform() == "linux":
    # Try and load Linux Python2.6 lib.  Default path is for Ubuntu.
    linux_lib = sublime.load_settings(PACKAGE_SETTINGS).get("linux_python2.6_lib", "/usr/lib/python2.6/lib-dynload")
    if not linux_lib in sys.path and path.exists(linux_lib):
        sys.path.append(linux_lib)
from plistlib import readPlist
from ExportHtmlLib.rgba.rgba import RGBA

NUMBERED_BBCODE_LINE = '[color=%(color)s]%(line)s [/color]%(code)s\n'

BBCODE_LINE = '%(code)s\n'

BBCODE_CODE = '[color=%(color)s]%(content)s[/color]'

BBCODE_ESCAPE = '[/color][color=%(color_open)s]%(content)s[/color][color=%(color_close)s]'

BBCODE_BOLD = '[b]%(content)s[/b]'

BBCODE_ITALIC = '[i]%(content)s[/i]'

POST_START = '[pre=%(bg_color)s]'

POST_END = '[/pre]\n'

BBCODE_MATCH = re.compile(r"""(\[/?)((?:code|pre|table|tr|td|th|b|i|u|sup|color|url|img|list|trac|center|quote|size|li|ul|ol|youtube|gvideo)(?:=[^\]]+)?)(\])""")

FILTER_MATCH = re.compile(r'^(?:(brightness|saturation|hue|colorize)\((-?[\d]+|[\d]*\.[\d]+)\)|(sepia|grayscale|invert))$')


class ExportBbcodePanelCommand(sublime_plugin.WindowCommand):
    def execute(self, value):
        if value >= 0:
            view = self.window.active_view()
            if view != None:
                ExportBbcode(view).run(**self.args[value])

    def run(self):
        options = sublime.load_settings(PACKAGE_SETTINGS).get("bbcode_panel", {})
        menu = []
        self.args = []
        for opt in options:
            k, v = opt.items()[0]
            menu.append(k)
            self.args.append(v)

        if len(menu):
            self.window.show_quick_panel(
                menu,
                self.execute
            )


class ExportBbcodeCommand(sublime_plugin.WindowCommand):
    def run(self, **kwargs):
        view = self.window.active_view()
        if view != None:
            ExportBbcode(view).run(**kwargs)


class ExportBbcode(object):
    def __init__(self, view):
        self.view = view

    def process_inputs(self, **kwargs):
        return {
            "numbers": bool(kwargs.get("numbers", False)),
            "color_scheme": kwargs.get("color_scheme", None),
            "multi_select": bool(kwargs.get("multi_select", False)),
            "clipboard_copy": bool(kwargs.get("clipboard_copy", True)),
            "view_open": bool(kwargs.get("view_open", False)),
            "filter": kwargs.get("filter", "")
        }

    def setup(self, **kwargs):
        path_packages = sublime.packages_path()

        # Get get general document preferences from sublime preferences
        settings = sublime.load_settings('Preferences.sublime-settings')
        eh_settings = sublime.load_settings(PACKAGE_SETTINGS)
        self.tab_size = settings.get('tab_size', 4)
        self.char_limit = int(eh_settings.get("valid_selection_size", 4))
        self.bground = ''
        self.fground = ''
        self.gbground = ''
        self.gfground = ''
        self.sbground = ''
        self.sfground = ''
        self.numbers = kwargs["numbers"]
        self.hl_continue = None
        self.curr_hl = None
        self.sels = []
        self.multi_select = self.check_sel() if kwargs["multi_select"] else False
        self.size = self.view.size()
        self.pt = 0
        self.end = 0
        self.curr_row = 0
        self.empty_space = None
        self.filter = []
        for f in kwargs["filter"].split(";"):
            m = FILTER_MATCH.match(f)
            if m:
                if m.group(1):
                    self.filter.append((m.group(1), float(m.group(2))))
                else:
                    self.filter.append((m.group(3), 0.0))

        # Get color scheme
        if kwargs["color_scheme"] != None:
            alt_scheme = kwargs["color_scheme"]
        else:
            alt_scheme = eh_settings.get("alternate_scheme", False)
        scheme_file = settings.get('color_scheme') if alt_scheme == False else alt_scheme
        colour_scheme = path.normpath(scheme_file)
        self.plist_file = self.apply_filters(readPlist(path_packages + colour_scheme.replace('Packages', '')))
        colour_settings = self.plist_file["settings"][0]["settings"]

        # Get general theme colors from color scheme file
        self.bground = self.strip_transparency(colour_settings.get("background", '#FFFFFF'), simple_strip=True)
        self.fground = self.strip_transparency(colour_settings.get("foreground", '#000000'))
        self.gbground = self.bground
        self.gfground = self.fground

        # Create scope colors mapping from color scheme file
        self.colours = {self.view.scope_name(self.end).split(' ')[0]: {"color": self.fground, "style": []}}
        for item in self.plist_file["settings"]:
            scope = item.get('scope', None)
            colour = None
            style = []
            if 'scope' in item:
                scope = item['scope']
            if 'settings' in item:
                colour = item['settings'].get('foreground', None)
                if 'fontStyle' in item['settings']:
                    for s in item['settings']['fontStyle'].split(' '):
                        if s == "bold" or s == "italic":  # or s == "underline":
                            style.append(s)

            if scope != None and colour != None:
                self.colours[scope] = {"color": self.strip_transparency(colour), "style": style}

    def apply_filters(self, tmtheme):
        def filter_color(color):
            rgba = RGBA(color)
            for f in self.filter:
                name = f[0]
                value = f[1]
                if name == "grayscale":
                    rgba.grayscale()
                elif name == "sepia":
                    rgba.sepia()
                elif name == "saturation":
                    rgba.saturation(value)
                elif name == "invert":
                    rgba.invert()
                elif name == "brightness":
                    rgba.brightness(value)
                elif name == "hue":
                    rgba.hue(value)
                elif name == "colorize":
                    rgba.colorize(value)
            return rgba.get_rgba()

        if len(self.filter):
            general_settings_read = False
            for settings in tmtheme["settings"]:
                if not general_settings_read:
                    for k, v in settings["settings"].items():
                        try:
                            settings["settings"][k] = filter_color(v)
                        except:
                            pass
                    general_settings_read = True
                    continue

                try:
                    settings["settings"]["foreground"] = filter_color(settings["settings"]["foreground"])
                except:
                    pass
                try:
                    settings["settings"]["background"] = filter_color(settings["settings"]["background"])
                except:
                    pass
        return tmtheme

    def strip_transparency(self, color, track_darkness=False, simple_strip=False):
        if color is None:
            return color
        rgba = RGBA(color.replace(" ", ""))
        if not simple_strip:
            rgba.apply_alpha(self.bground if self.bground != "" else "#FFFFFF")
        return rgba.get_rgb()

    def setup_print_block(self, curr_sel, multi=False):
        # Determine start and end points and whether to parse whole file or selection
        if not multi and (curr_sel.empty() or curr_sel.size() <= self.char_limit):
            self.size = self.view.size()
            self.pt = 0
            self.end = 1
            self.curr_row = 1
        else:
            self.size = curr_sel.end()
            self.pt = curr_sel.begin()
            self.end = self.pt + 1
            self.curr_row = self.view.rowcol(self.pt)[0] + 1
        self.start_line = self.curr_row

        self.gutter_pad = len(str(self.view.rowcol(self.size)[0])) + 1

    def check_sel(self):
        multi = False
        for sel in self.view.sel():
            if not sel.empty() and sel.size() >= self.char_limit:
                multi = True
                self.sels.append(sel)
        return multi

    def guess_colour(self, the_key):
        the_colour = None
        the_style = None
        if the_key in self.colours:
            the_colour = self.colours[the_key]["color"]
            the_style = self.colours[the_key]["style"]
        else:
            best_match = 0
            for key in self.colours:
                if self.view.score_selector(self.pt, key) > best_match:
                    best_match = self.view.score_selector(self.pt, key)
                    the_colour = self.colours[key]["color"]
                    the_style = self.colours[key]["style"]
            self.colours[the_key] = {"color": the_colour, "style": the_style}
        return the_colour, the_style

    def print_line(self, line, num):
        if self.numbers:
            bbcode_line = NUMBERED_BBCODE_LINE % {
                "color": self.gfground,
                "line": str(num).rjust(self.gutter_pad),
                "code": line
            }
        else:
            bbcode_line = BBCODE_LINE % {"code": line}

        return bbcode_line

    def convert_view_to_bbcode(self, the_bbcode):
        for line in self.view.split_by_newlines(sublime.Region(self.end, self.size)):
            self.empty_space = None
            self.size = line.end()
            line = self.convert_line_to_bbcode()
            the_bbcode.write(self.print_line(line, self.curr_row))
            self.curr_row += 1

    def repl(self, m, the_colour):
        return m.group(1) + (
            BBCODE_ESCAPE % {
                "color_open": the_colour,
                "color_close": the_colour,
                "content": m.group(2)
            }
        ) + m.group(3)

    def format_text(self, line, text, the_colour, the_style):
        text = text.replace('\t', ' ' * self.tab_size).replace('\n', '')
        if self.empty_space != None:
            text = self.empty_space + text
            self.empty_space = None
        if text.strip(' ') == '':
            self.empty_space = text
        else:
            code = ""
            text = BBCODE_MATCH.sub(lambda m: self.repl(m, the_colour), text)
            bold = False
            italic = False
            for s in the_style:
                if s == "bold":
                    bold = True
                if s == "italic":
                    italic = True
            code += (BBCODE_CODE % {"color": the_colour, "content": text})
            if italic:
                code = (BBCODE_ITALIC % {"color": the_colour, "content": code})
            if bold:
                code = (BBCODE_BOLD % {"color": the_colour, "content": code})
            line.append(code)

    def convert_line_to_bbcode(self):
        line = []

        while self.end <= self.size:
            # Get text of like scope up to a highlight
            scope_name = self.view.scope_name(self.pt)
            while self.view.scope_name(self.end) == scope_name and self.end < self.size:
                self.end += 1
            the_colour, the_style = self.guess_colour(scope_name)

            region = sublime.Region(self.pt, self.end)
            # Normal text formatting
            text = self.view.substr(region)
            self.format_text(line, text, the_colour, the_style)

            # Continue walking through line
            self.pt = self.end
            self.end = self.pt + 1

        # Join line segments
        return ''.join(line)

    def write_body(self, the_bbcode):
        the_bbcode.write(POST_START % {"bg_color": self.bground})

        # Convert view to HTML
        if self.multi_select:
            count = 0
            total = len(self.sels)
            for sel in self.sels:
                self.setup_print_block(sel, multi=True)
                self.convert_view_to_bbcode(the_bbcode)
                count += 1

                if count < total:
                    the_bbcode.write("\n" + (BBCODE_CODE % {"color": self.fground, "content": "..."}) + "\n\n")

        else:
            self.setup_print_block(self.view.sel()[0])
            self.convert_view_to_bbcode(the_bbcode)

        the_bbcode.write(POST_END)

    def run(self, **kwargs):
        inputs = self.process_inputs(**kwargs)
        self.setup(**inputs)

        delete = False if inputs["view_open"] else True

        with tempfile.NamedTemporaryFile(delete=delete, suffix='.txt') as the_bbcode:
            self.write_body(the_bbcode)
            if inputs["clipboard_copy"]:
                the_bbcode.seek(0)
                sublime.set_clipboard(the_bbcode.read())
                sublime.status_message("Export to BBCode: copied to clipboard")

        if inputs["view_open"]:
            self.view.window().open_file(the_bbcode.name)
