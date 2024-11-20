---
description: Warmup/Misc
---

# Trust in my calculator

This is a calculator challenge on netcat, with randomized numbers. Even though this was a simple challenge, it really trained me to properly use **pwntools** to parse through bytes received from the remote. Also I was late to solving this challenge and another team member stole my points :angry:

<figure><img src="../../.gitbook/assets/Screenshot 2024-11-08 203256.png" alt=""><figcaption></figcaption></figure>

Using the knowledge that the numbers always come after the `:` sign, this was my solver script that I brute forced the iteration range to be 20 questions :sob:

```python
from pwn import *

host = 'calculator.ctf.cert.unlp.edu.ar'
port = 35003

io = connect(host, port)
log.info(io.recvuntil(':'))

for i in range(20):
    log.info(io.recvuntil('\n'))
    num1 = int(io.recvuntil(' ', drop=True).decode())
    operation = io.recvuntil(' ', drop=True).decode()
    num2 = int(io.recvuntil('\n', drop=True).decode())
    log.info(f'iteration {i}: {num1} {operation} {num2}')

    if operation == '+':
        result = num1 + num2
    elif operation == '-':
        result = num1 - num2
    elif operation == '*':
        result = num1 * num2

    io.sendline(bytes(str(result), 'utf-8'))

log.info(io.recvall())

io.interactive()
```

Using the mentioned script, I was able to obtain the flag!

<figure><img src="../../.gitbook/assets/Screenshot 2024-11-08 210131.png" alt=""><figcaption></figcaption></figure>
