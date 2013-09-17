# -*- coding: utf-8 -*-

"""
Move Tab

Plugin for Sublime Text to move tabs around

Copyright (c) 2012 Frédéric Massart - FMCorz.net

Licensed under The MIT License
Redistributions of files must retain the above copyright notice.

http://github.com/FMCorz/MoveTab
"""

import sublime, sublime_plugin

class MoveTabCommand(sublime_plugin.WindowCommand):

	def run(self, position):
		position = str(position)
		view = self.window.active_view()
		(group, index) = self.window.get_view_index(view)
		if index < 0:
			return
		count = len(self.window.views_in_group(group))

		direction = None
		if position.startswith('-') or position.startswith('+'):
			direction = position[0]
			steps = int(position[1:])
			if direction == '-':
				position = index - steps
			else:
				position = index + steps

		position = int(position)
		if position < 0:
			position = count - 1
		elif position > count - 1:
			if direction: position = 0
			else: position = count - 1

		# Avoid flashing tab when moving to same index
		if position == index:
			return

		self.window.set_view_index(view, group, position)
		self.window.focus_view(view)

	def is_enabled(self):
		view = self.window.active_view()
		if view == None:
			return False
		(group, index) = self.window.get_view_index(view)
		return len(self.window.views_in_group(group)) > 1

	def is_visible(self):
		return True

	def description(self):
		return None
