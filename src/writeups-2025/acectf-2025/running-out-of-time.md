---
description: '"Binary Exploitation"'
---

# Running Out of Time

> A mysterious program asks for a specific number, but the correct value changes every time you run it. Can you figure out how the number is generated and retrieve the hidden flag?
>
> Analyze the binary, reverse-engineer the logic, and find a way to predict the correct input to trigger the win condition.

{% hint style="danger" %}
I couldn't really upload the file because it's a .exe LOL
{% endhint %}

Given a binary for Windows called "Running\_Out\_Of\_Time.exe", we decided to decompile with Ghidra. Because there was no nc, it means that we definitely can just do static analysis.

![image](https://hackmd.io/_uploads/BkdI7RAcJg.png)

In the main function it looked like a simple RNG prediction challenge, but it looked like it just goes to a function called `p3xr9q_t1zz`, so we looked on it.

![Screenshot 2025-02-27 165400](https://hackmd.io/_uploads/HJ1P4CA9kl.png)

So we were lazy to type all of the characters to decode the flag so we just opened DeepSeek:

![Screenshot 2025-02-27 165352](https://hackmd.io/_uploads/HJd9ERCcJg.png)

Flag: `ACECTF{71m3_570pp3d}`
