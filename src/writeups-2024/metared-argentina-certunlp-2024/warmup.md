---
description: Binary Exploitation
---

# Warmup

{% file src="../../.gitbook/assets/reto.c" %}

I actually didn't get to solve this challenge for the points, so I played this challenge just for practice. Given source code that looks like this:

```c
// gcc -Wall -fno-stack-protector -z execstack -no-pie -o reto reto.c
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>

int main()
{

  int var;
  int check = 0x12345678;
  char buf[20];

  fgets(buf,45,stdin);

  printf("\n[buf]: %s\n", buf);
  printf("[check] %p\n", check);

  if ((check != 0x12345678) && (check != 0x54524543))
    printf ("\nClooosse!\n");

  if (check == 0x54524543)
   {
     printf("Yeah!! You win!\n");
     setreuid(geteuid(), geteuid());
     system("/bin/bash");
     printf("Byee!\n");
   }
   return 0;
}
```

I was able to know that this is a simple buffer overflow challenge, because the `buf` variable stores only 20 chars yet the `fgets` function reads 45 characters at maximum. We can solve this without using a debugger because it prints out the variable check for the overflow. So I tested the output with a cyclic pattern to find the offset until the variable gets overwritten.

```
$ ./reto
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaal

[buf]: aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaa
[check] 0x61616168

Clooosse!

$ cyclic -l 0x61616168
28
```

We also know that the winning check requires `check == 0x54524543` which is the same thing as inputting `CERT` to the variable. Using this knowledge, I built a payload using python:

<figure><img src="../../.gitbook/assets/Screenshot 2024-11-08 214332.png" alt=""><figcaption></figcaption></figure>

Using this payload I was able to solve the challenge to obtain the flag using the obtained shell.

<figure><img src="../../.gitbook/assets/Screenshot 2024-11-08 214159_2.png" alt=""><figcaption></figcaption></figure>

