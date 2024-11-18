---
icon: gear
layout:
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: false
  pagination:
    visible: true
---

# My Setup

## Software

* gdb (Version 13.2)
* pwndbg (2024.08.29 build: dcc8db70)
* pwntools (Version 4.13.1)
* ghidra (Version 11.2 2024-Sep-26)
* ~~_radare2 (Version 5.9.2), but I rarely use this now_~~

## PWN Template

{% file src=".gitbook/assets/pwnup.mako" %}

<details>

<summary>Example on template ELF and Remote</summary>

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: winterbitia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

exe = context.binary = ELF(args.EXE or 'template')
trm = context.terminal = ['tmux', 'splitw', '-h']

host = args.HOST or 'hostname.com'
port = int(args.PORT or 6969420)

def start_local(argv=[], *a, **kw):
    '''Execute the target binary locally'
```

</details>

