import sublime, sublime_plugin, re, sys
from string import Template

class AbacusCommand(sublime_plugin.TextCommand):
    """
        Main entry point. Find candidates for alignment,
        calculate appropriate column widths, and then
        perform a series of replacements.
    """
    def run(self, edit):
        candidates  = []
        separators  = sublime.load_settings("Abacus.sublime-settings").get("com.khiltd.abacus.separators")
        indentor    = Template("$indentation$left_col")
        lg_aligner  = Template("$left_col$separator")
        rg_aligner  = Template("$left_col$gutter$separator_padding$separator")

        #Run through the separators accumulating alignment candidates
        #starting with the longest ones i.e. '==' before '='.
        longest_first = self.sort_separators(separators)

        #Favor those that lean right so assignments with slice notation in them
        #get handled sanely
        for separator in [righty for righty in longest_first if righty["gravity"] == "right"]:
            self.find_candidates_for_separator(separator, candidates)

        for separator in [lefty for lefty in longest_first if lefty["gravity"] == "left"]:
            self.find_candidates_for_separator(separator, candidates)
        
        #After accumulation is done, figure out what the minimum required
        #indentation and column width is going to have to be to make every
        #candidate happy.
        max_indent, max_left_col_width  = self.calc_left_col_width(candidates)

        #Perform actual alignments based on gravitational affinity of separators
        for candidate in candidates:
            indent      = 0
            if not candidate["preserve_indent"]:
                indent  = max_indent
            else:
                indent  = candidate["adjusted_indent"]

            sep_width   = len(candidate["separator"])
            right_col   = candidate["right_col"].strip()
            left_col    = indentor.substitute(  indentation = " " * indent, 
                                                left_col    = candidate["left_col"] )
            #Marry the separator to the proper column
            if candidate["gravity"] == "left":
                #Separator sits flush left
                left_col    = lg_aligner.substitute(left_col    = left_col, 
                                                    separator   = candidate["separator"] )
            elif candidate["gravity"] == "right":
                gutter_width = max_left_col_width + max_indent - len(left_col) - len(candidate["separator"])
                #Push the separator ONE separator's width over the tab boundary
                left_col    = rg_aligner.substitute(    left_col            = left_col,
                                                        gutter              = " " * gutter_width,
                                                        separator_padding   = " " * sep_width,
                                                        separator           = candidate["separator"] )
                #Most sane people will want a space between the operator and the value.
                right_col   = " %s" % right_col
            #Snap the left side together
            left_col                    = left_col.ljust(max_indent + max_left_col_width)
            candidate["replacement"]    = "%s%s\n" % (left_col, right_col)
            
            #Replace each line in its entirety
            full_line = self.region_from_line_number(candidate["line"])
            #sys.stdout.write(candidate["replacement"])
            self.view.replace(edit, full_line, candidate["replacement"])
            
        #Scroll and muck with the selection
        if candidates:
            self.view.sel().clear()
            for region in [self.region_from_line_number(changed["line"]) for changed in candidates]:
                start_of_right_col  = region.begin() + max_indent + max_left_col_width
                insertion_point     = sublime.Region(start_of_right_col, start_of_right_col)
                self.view.sel().add(insertion_point)
                #self.view.show_at_center(insertion_point)
        else:
            sublime.status_message('Abacus - no alignment token found on selected line(s)')
            
    def sort_separators(self, separators):
        return sorted(separators, key=lambda sep: -len(sep["token"]))

    def find_candidates_for_separator(self, separator, candidates):
        """
            Given a particular separator, loop through every
            line in the current selection looking for it and
            add unique matches to a list.
        """
        debug               = sublime.load_settings("Abacus.sublime-settings").get("com.khiltd.abacus.debug")
        token               = separator["token"]
        selection           = self.view.sel()
        new_candidates      = []
        for region in selection:
            for line in self.view.lines(region):
                line_no     = self.view.rowcol(line.begin())[0]
            
                #Never match a line more than once
                if len([match for match in candidates if match["line"] == line_no]):
                    continue
 
                #Collapse any string literals that might
                #also contain our separator token so that
                #we can reliably find the location of the 
                #real McCoy.
                line_content        = self.view.substr(line)
                collapsed           = line_content

                for match in re.finditer(r"(\"[^\"]*(?<!\\)\"|'[^']*(?<!\\)'|\%(q|Q)?\{.*\})", line_content):
                    quoted_string   = match.group(0)
                    collapsed       = collapsed.replace(quoted_string, "\007" * len(quoted_string))
                    
                #Look for ':' but not '::', '=' but not '=>'
                #And remember that quoted strings were collapsed
                #up above!
                token_pos           = None
                safe_token          = re.escape(token)
                token_matcher       = re.compile(r"(?<![^a-zA-Z0-9_ \007])%s(?![^a-zA-Z0-9_# \007])" % (safe_token))
                potential_matches   = [m for m in token_matcher.finditer(collapsed)]
                
                if debug:
                    print "Pattern:"
                    print token_matcher.pattern
                    print "Matches:"
                    print potential_matches
                
                if len(potential_matches):
                    #Split on the first/last occurrence of the token
                    if separator["gravity"] == "right":
                        token_pos   = potential_matches[-1].start()
                    elif separator["gravity"] == "left":
                        token_pos   = potential_matches[0].start()
                        
                    #Do you see what I see?
                    if debug:
                        sys.stdout.write("%s\n" % line_content.encode("ascii", "ignore"))
                        sys.stdout.write(" " * token_pos)
                        sys.stdout.write("^\n")
                    
                    #Now we can slice
                    left_col        = self.detab(line_content[:token_pos]).rstrip()
                    right_col       = self.detab(line_content[token_pos + len(token):])
                    sep             = line_content[token_pos:token_pos + len(token)]
                    initial_indent  = re.match("\s+", left_col) or 0
                    
                    if initial_indent: 
                        initial_indent = len(initial_indent.group(0))
                        #Align to tab boundary
                        if initial_indent % self.tab_width >= self.tab_width / 2:
                            initial_indent = self.snap_to_next_boundary(initial_indent, self.tab_width)
                        else:
                            initial_indent -= initial_indent % self.tab_width
                    candidate       = { "line":             line_no,
                                        "original":         line_content,
                                        "separator":        sep,
                                        "gravity":          separator["gravity"],
                                        "adjusted_indent":  initial_indent,
                                        "preserve_indent":  separator.get("preserve_indentation", False),
                                        "left_col":         left_col.lstrip(),
                                        "right_col":        right_col.rstrip() }
                    new_candidates.append(candidate)
        #Poke more stuff in the accumulator
        candidates.extend(new_candidates)

    def calc_left_col_width(self, candidates):
        """
            Given a list of lines we've already matched against
            one or more separators, loop through them all to
            normalize their indentation and determine the minimum
            possible column width that will accomodate them all
            when aligned to a tab stop boundary.
        """
        max_width           = 0
        max_indent          = 0
        max_sep_width       = 0

        for candidate in candidates:
            max_indent      = max([candidate["adjusted_indent"], max_indent])
            max_sep_width   = max([len(candidate["separator"]), max_sep_width])
            max_width       = max([len(candidate["left_col"].rstrip()), max_width])
        
        max_width += max_sep_width

        #Bump up to the next multiple of tab_width
        max_width = self.snap_to_next_boundary(max_width, self.tab_width)
                    
        return max_indent, max_width
    
    @property
    def tab_width(self):
        """
            Exceptionally inefficient
        """
        return int(self.view.settings().get('tab_size', 4))

    def detab(self, input):
        """
            Goodbye tabs!
        """
        return input.expandtabs(self.tab_width)
        
    def region_from_line_number(self, line_number):
        """
            Given a zero-based line number, return a region 
            encompassing it (including the newline).
        """
        return self.view.full_line(self.view.text_point(line_number, 0))

    def snap_to_next_boundary(self, value, interval):
        """
            Alignment voodoo
        """
        return value + (interval - value % interval)
