#!/usr/bin/env python

import re
import sys


selected_string = sys.argv[1]

add_edit = re.compile(r'(?s)\{\+\+(.*?)\+\+[ \t]*(\[(.*?)\])?[ \t]*\}')
del_edit = re.compile(r'(?s)\{\-\-(.*?)\-\-[ \t]*(\[(.*?)\])?[ \t]*\}')
sub_edit = re.compile(r'''(?s)\{\~\~(?P<original>(?:[^\~\>]|(?:\~(?!\>)))+)\~\>(?P<new>(?:[^\~\~]|(?:\~(?!\~\})))+)\~\~\}''')

if len(selected_string) > 0:
    a = add_edit.sub(r'\1', selected_string)
    d = del_edit.sub(r'', a)
    s = sub_edit.sub(r'\2', d)
    print s
else:
	print selected_string