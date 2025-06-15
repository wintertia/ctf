---
icon: gear
layout:
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: false
  pagination:
    visible: true
---

# My Setup

## Software

* **Ubuntu 22.04.5 LTS x86\_64**
* gdb (Version 12.1)
* pwndbg (2025.04.18 build: 02335839)
* pwntools (Version 4.14.1)
* ghidra (Version 11.2 2024-Sep-26)
* tmux (Version 3.2a)
* OneGadget (Version 1.9.0)

## PWN Template

Place the template file in your pwntools template directory, in my case it was located in `~/.local/lib/python3.11/site-packages/pwnlib/data/templates`:

{% file src=".gitbook/assets/pwnup.mako" %}

<details>

<summary>Example on template ELF and Remote</summary>

{% code fullWidth="true" %}
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: wintertia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'template')
context.terminal = ['tmux', 'splitw', '-h']
context.log_level = 'debug'

host = args.HOST or 'hostname.com'
port = int(args.PORT or 1337)

def start_local(argv=[], *a, **kw):
	'''Execute the target binary locally'''
	if args.GDB:
		return gdb.debug([exe.path] + argv, gdbscript=gdbscript, *a, **kw)
	else:
		return process([exe.path] + argv, *a, **kw)

def start_remote(argv=[], *a, **kw):
	'''Connect to the process on the remote host'''
	io = connect(host, port)
	if args.GDB:
		gdb.attach(io, gdbscript=gdbscript)
	return io

def start(argv=[], *a, **kw):
	'''Start the exploit against the target.'''
	if args.LOCAL:
		return start_local(argv, *a, **kw)
	else:
		return start_remote(argv, *a, **kw)

gdbscript = '''
tbreak main
continue
'''.format(**locals())

# =======================
# -- EXPLOIT GOES HERE --
# =======================

def exploit():
	io = start()
	
	# payload
	
	io.interactive()

if __name__ == "__main__":
	exploit()

```
{% endcode %}

</details>

