---
description: Forensics/Steganography
---

# devil's-secret-stash

Given a single image, I was able to find a hidden zip file using **binwalk**:

```
$ binwalk devil.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, EXIF standard
12            0xC             TIFF image data, big-endian, offset of first image directory: 8
15196         0x3B5C          Copyright string: "Copyright (c) 1998 Hewlett-Packard Company"
250250        0x3D18A         Zip archive data, encrypted compressed size: 55, uncompressed size: 27, name: flag
250447        0x3D24F         End of Zip archive, footer length: 22
```

Extracting the zip out of the image, and then attempting extract the zip, prompted me for a password:

```
$ 7z x 3D18A.zip

7-Zip 24.07 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-06-19
 64-bit locale=en_US.UTF-8 Threads:16 OPEN_MAX:1024

Scanning the drive for archives:
1 file, 219 bytes (1 KiB)

Extracting archive: 3D18A.zip
--
Path = 3D18A.zip
Type = zip
Physical Size = 219

Enter password (will not be echoed):
```

Because I didn't have a password, I cracked it using **zip2john** and **john**:

```
$ zip2john 3D18A.zip > zip.hash

$ john zip.hash
Using default input encoding: UTF-8
Loaded 1 password hash (ZIP, WinZip [PBKDF2-SHA1 256/256 AVX2 8x])
Cost 1 (HMAC size) is 27 for all loaded hashes
Will run 16 OpenMP threads
Proceeding with single, rules:Single
Press 'q' or Ctrl-C to abort, almost any other key for status
Almost done: Processing the remaining buffered candidate passwords, if any.
Proceeding with wordlist:/usr/share/john/password.lst
Proceeding with incremental:ASCII
250250           (3D18A.zip/flag)
1g 0:00:00:09 DONE 3/3 (2024-11-18 11:50) 0.1102g/s 83859p/s 83859c/s 83859C/s beriler..203226
Use the "--show" option to display all of the cracked passwords reliably
Session completed.
```

Using the password `250250` I was able to extract the zip and get the flag:

```
Enter password (will not be echoed):
Everything is Ok

Size:       27
Compressed: 219

$ cat flag
NICC{J3rS3y_D3v1l_Arch1V3}
```
