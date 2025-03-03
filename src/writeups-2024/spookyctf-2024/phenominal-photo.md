---
description: Forensics/Steganography
---

# Phenominal-Photo

> _Simon was spotted dwelling under the clock-tower yet again, this time taking pictures. He seems to have captured a strange object in the far far distance going left, right, up, and down seemingly lost or out of control. There is a strange aura radiating from the photo, pulsations even, like an SOS. Can you figure out this strange phenomenon??_
>
> _Author: WillyMcX_

{% file src="../../.gitbook/assets/boo.jpg" %}

Given a single image, I tried using **binwalk** to find hidden files in the image but there was nothing:

```
$ binwalk boo.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01
```

So, I tried using **steganography** to find the hidden files inside the image, and was given a zip file.

```
$ steghide extract -sf boo.jpg
Enter passphrase:
wrote extracted data to "Ship#1.zip".
```

Inside the zip there was `gps.zip` and `Map.txt`. The zip file was locked with a password, and this time I couldn't brute force it using **john.** Looking into the plaintext file, oh my god

{% code overflow="wrap" %}
```
⋔⏃⌿: ⌰⟒⎎⏁, ⎍⌿, ⎅⍜⍙⋏, ⌰⟒⎎⏁, ⎅⍜⍙⋏, ⍀⟟☌⊑⏁, ⍀⟟☌⊑⏁, ⎅⍜⍙⋏, ⌰⟒⎎⏁, ⎍⌿, ⌰⟒⎎⏁, ⍀⟟☌⊑⏁, ⎍⌿

⍀⟒⋔⟟⋏⎅⟒⍀ ⏁⊑⏃⏁ ⍜⎍⍀ ☌⌿⌇ ⟟⌇ ⏃ ⌰⟟⏁⏁⌰⟒ ⎎⎍⋏☍⊬, ⟟⏁ ⍜⋏⌰⊬ ⏁⏃☍⟒⌇ ⏁⊑⟒ ⎎⟟⍀⌇⏁ ⌰⟒⏁⏁⟒⍀ ⍜⎎ ⟒⏃☊⊑ ⎅⟟⍀⟒☊⏁⟟⍜⋏ ⍙⟒ ⍙⏃⋏⏁ ⏁⍜ ☌⍜ (⌇⏁⎍⌿⟟⎅ ⋔⟒⋔⍜⍀⊬ ⋔⏃⋏⏃☌⟒⋔⟒⋏⏁)
```
{% endcode %}

After some searching with the help of a friend I discovered the existence of an _Alien Language_ translator to decode this message:

<figure><img src="../../.gitbook/assets/image (13).png" alt=""><figcaption></figcaption></figure>

Using `LUDLDRRDLULRU` to open the zip, I was given another message to decode, and with the given message, the flag was found!

```
$ cat myrequest.txt
⋏⟟☊☊{⊑⟒⌰⌿_⋔⟒_⎎⟟⋏⎅_⏁⊑⟒_⌿⌰⏃⋏⟒⏁_⏚0⍜}
```

<figure><img src="../../.gitbook/assets/image (14).png" alt=""><figcaption></figcaption></figure>
