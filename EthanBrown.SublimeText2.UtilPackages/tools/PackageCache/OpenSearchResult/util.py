"""
util.py: Utility functions for opening Sublime Text 2 search results.
"""
import re


def parse_line_number(line_str):
    """
    In a line of the format "<line_num>:    <text>"or "<line_num>    <text>"
    this grabs line_num.

    >>> parse_line_number('5: def parse_line_number(line_str):')
    '5'
    >>> parse_line_number('43              line = view.line(s)')
    '43'
    >>> parse_line_number('136:             line_num = parse_line_number(line_str)')
    '136'
    """
    parts = line_str.split()
    line_num = parts[0].strip().replace(':', '')
    return line_num


def is_file_path(line_str):
    """
    Test if `line_str` is a file path.

    >>> is_file_path('/Users/me/code/OpenSearchResult/open_search_result.py:')
    True
    >>> is_file_path('C:\\Users\\me\\test.txt:')
    True
    >>> is_file_path('5: def parse_line_number(line_str):')
    False
    """
    return re.match("^(/|\w:\\\).*:$", line_str) is not None

