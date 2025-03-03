---
description: '"Binary Exploitation"'
---

# !Underflow

> Something simple to warm you up.

{% file src="../../.gitbook/assets/exploit-me" %}

Given a binary called "exploit-me", we decided to decompile with Ghidra.

![image](https://hackmd.io/_uploads/rymjzR0qkl.png)

Looking at the function list, we were curious about the `print_flag` function so we decided to take a look further.

![Screenshot 2025-02-27 163105](https://hackmd.io/_uploads/SyRDfCCcJx.png)

The flag was just written in plain text: `ACECTF{buff3r_0v3rfl3w}`
