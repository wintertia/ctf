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

