---
description: Binary Exploitation
---

# flagshop

{% file src="../../.gitbook/assets/flagshop" %}

Given a binary, it contained a simple flag shop program:

<figure><img src="../../.gitbook/assets/image (9).png" alt=""><figcaption></figcaption></figure>

I decided to open Ghidra to analyze it further.

<figure><img src="../../.gitbook/assets/image (5).png" alt=""><figcaption></figcaption></figure>

Looking at the decompiled binary, the vulnerability in this challenge is a simple integer overflow to make the total cost negative so I could add to the balance to buy the flag.

<figure><img src="../../.gitbook/assets/image (8).png" alt=""><figcaption></figcaption></figure>

Using a simple calculation to divide a number above the **32-bit signed integer limit** with the cost of the discounted flag, I was able to do an integer overflow to buy the flag!

<figure><img src="../../.gitbook/assets/Screenshot 2024-11-08 211526.png" alt=""><figcaption></figcaption></figure>

