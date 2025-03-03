---
description: Misc
---

# two-frames-one-champ

> _Lake Champlain has always been a hotspot for mysterious sightings, but it seems like something recently odd came up. Apparently an old cryptid hunter went missing after attempting to reveal his findings. Rumors have been spreading that the cryptid hunter was once affiliated with the Consortium. But anything they left behind? An broken hard drive. Simon was able to recover the hard drive. Unfortunately, he was only able to recover two images files that are corrupted, likely tampered by the Consortium. Anna is tasking you to JOIN Simon piece this puzzle TOGETHER to uncover what the Consortium are hiding._
>
> _Author: C4rl05t_

{% file src="../../.gitbook/assets/image1.png" %}

{% file src="../../.gitbook/assets/image2.png" %}

In this challenge, I was given two .png files, but of course they were corrupted and I couldn't open them. Using the tool **HxD** I was able to open both .png files and read the hex.

<figure><img src="../../.gitbook/assets/image (10).png" alt=""><figcaption></figcaption></figure>

As I expected, the file header of the image was incorrect. Using [Gary Kessler's](https://www.garykessler.net/library/file_sigs.html) list of file signatures, I was able to find `89 50 4E 47 0D 0A 1A 0A` to be the correct magic bytes for the image. After changing them: I was given two images which were just noise:

<figure><img src="../../.gitbook/assets/image (11).png" alt=""><figcaption></figcaption></figure>

My glowing brain genius prompted me to open Photoshop and immediately stack these images together with different blending types, and I was able to obtain the flag!

<figure><img src="../../.gitbook/assets/Screenshot 2024-10-27 013901.png" alt=""><figcaption></figcaption></figure>
