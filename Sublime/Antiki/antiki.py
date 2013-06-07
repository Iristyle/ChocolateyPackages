import sublime, sublime_plugin, re, subprocess, time, os, os.path

class AntikiCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		antiki(self.view, edit)

def antiki(view, edit):
	if view.is_read_only(): return
	
	base = view.file_name()
	if base is not None: base = os.path.dirname(base)
	cfg = sublime.load_settings("Antiki.sublime-settings")
	env = build_env(cfg, base=base)
	cwd = expand(cfg.get('cwd', '.'), env)
	enc = cfg.get('encoding', 'utf-8')
	
	sels = view.sel()
	end = None

	for sel in sels:
		# ensure that there is at least one following line.
		if sel.end() == view.size():
			view.insert(edit, view.size(), '\n')

		row, _ = view.rowcol(sel.b)
		head, op, cmd = resolve_head(view, row)
		if cmd is None: continue
		indent = head + ' ' * len(op)
		end = resolve_body(view, row+1, indent)
		
		out = head + op + cmd + '\n' 
		out = out + '\n'.join(
			indent + line.decode(enc, 'ignore').rstrip() for line in perform_cmd(env, cwd, cmd)
		) + '\n'

		end = replace_lines(view, edit, row, end-row, out) 

	if end is None: return # don't play with the selection..
	end = view.line(end.b)
	view.sel().clear()
	eol = end.end()
	if end.empty(): 
		view.insert(edit, eol, head)
		eol += len(head)
	view.sel().add(sublime.Region(eol,eol))
	
def build_env(cfg, base=None):
	env = os.environ.copy()
	env['BASE'] = str(base or env.get("HOME") or '.')
	mod = cfg.get('env', {})
	for key in mod:
		env[key] = str(expand(mod[key], env))
	return env
	
''' example:
$ echo $BASE
  /Users/scott/Library/Application Support/Sublime Text 2/Packages/Antiki
'''

def expand(val, env):
	return val.format(**env)

def perform_cmd(env, cwd, cmd):
	args = cmd
	pipe = subprocess.Popen(
		args, stdout = subprocess.PIPE, stderr = subprocess.STDOUT, shell=True, env=env, cwd=cwd
	)
	ticks = 0
	while ticks < 1000:
		ticks += 1
		time.sleep(.01)
		if pipe.poll() is not None:
			return pipe.stdout.readlines()
	pipe.kill()
	return pipe.stdout.readlines()

def replace_lines(view, edit, dest_row, dest_ct, src):
	dest = sublime.Region(
		view.text_point(dest_row,0), 
		view.text_point(dest_row+dest_ct,0)
	)

	view.replace(edit, dest, src)
	end = view.text_point(dest_row,0) + len(src)
	return sublime.Region(end,end)

rx_antiki = re.compile('^([ \t]*)([$] +)(.*)$')

def resolve_head(view, row):
	line = get_line(view, row)
	m = rx_antiki.match(line)
	if m: return m.groups()
	return None, None, None

def resolve_body(view, row, indent):
	while True:
		line = get_line(view, row)
		if not line: return row
		if not line.startswith(indent): return row
		row += 1

def get_line(view, row=0):
	point = view.text_point(row, 0)
	if row < 0: return None
	line = view.line(point)
	return view.substr(line).strip('\r\n')
