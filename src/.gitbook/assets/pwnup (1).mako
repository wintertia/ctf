<%page args="binary, host=None, port=None, user=None, password=None, libc=None, remote_path=None, quiet=False"/>\
<%
import os
import sys

from pwnlib.context import context as ctx
from pwnlib.elf.elf import ELF
from pwnlib.util.sh_string import sh_string
from elftools.common.exceptions import ELFError

argv = list(sys.argv)
argv[0] = os.path.basename(argv[0])

try:
    if binary:
       ctx.binary = ELF(binary, checksec=False)
except ELFError:
    pass

if not binary:
    binary = './path/to/binary'

exe = os.path.basename(binary)

ssh = user or password
if ssh and not port:
    port = 22
elif host and not port:
    port = 4141

remote_path = remote_path or exe
password = password or 'secret1234'
binary_repr = repr(binary)
libc_repr = repr(libc)
%>\
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- template: wintertia -*-

# ====================
# -- PWNTOOLS SETUP --
# ====================

from pwn import *

%if ctx.binary or not host:
exe = context.binary = ELF(args.EXE or ${binary_repr})
trm = context.terminal = ['tmux', 'splitw', '-h']
<% binary_repr = 'exe.path' %>
%else:
context.update(arch='i386')
exe = ${binary_repr}
trm = context.terminal = ['tmux', 'splitw', '-h']
<% binary_repr = 'exe' %>
%endif

%if host or port or user or ssh:
%if host:
host = args.HOST or ${repr(host)}
%endif
%if port:
port = int(args.PORT or ${port})
%endif
%if user:
user = args.USER or ${repr(user)}
password = args.PASSWORD or ${repr(password)}
%endif
%if ssh:
remote_path = ${repr(remote_path)}
%endif

%endif
%if ssh:
# Connect to the remote SSH server
shell = None
if not args.LOCAL:
    shell = ssh(user, host, port, password)
    shell.set_working_directory(symlink=True)

%endif
%if libc:
if args.LOCAL_LIBC:
    libc = exe.libc
%if host:
elif args.LOCAL:
%else:
else:
%endif
    library_path = libcdb.download_libraries(${libc_repr})
    if library_path:
        exe = context.binary = ELF.patch_custom_libraries(${binary_repr}, library_path)
        libc = exe.libc
    else:
        libc = ELF(${libc_repr})
%if host:
else:
    libc = ELF(${libc_repr})
%endif

%endif
%if host:
def start_local(argv=[], *a, **kw):
    '''Execute the target binary locally'''
    if args.GDB:
        return gdb.debug([${binary_repr}] + argv, gdbscript=gdbscript, *a, **kw)
    else:
        return process([${binary_repr}] + argv, *a, **kw)

def start_remote(argv=[], *a, **kw):
  %if ssh:
    '''Execute the target binary on the remote host'''
    if args.GDB:
        return gdb.debug([remote_path] + argv, gdbscript=gdbscript, ssh=shell, *a, **kw)
    else:
        return shell.process([remote_path] + argv, *a, **kw)
  %else:
    '''Connect to the process on the remote host'''
    io = connect(host, port)
    if args.GDB:
        gdb.attach(io, gdbscript=gdbscript)
    return io
  %endif

%endif
%if host:
def start(argv=[], *a, **kw):
    '''Start the exploit against the target.'''
    if args.LOCAL:
        return start_local(argv, *a, **kw)
    else:
        return start_remote(argv, *a, **kw)
%else:
def start(argv=[], *a, **kw):
    '''Start the exploit against the target.'''
    if args.GDB:
        return gdb.debug([${binary_repr}] + argv, gdbscript=gdbscript, *a, **kw)
    else:
        return process([${binary_repr}] + argv, *a, **kw)
%endif

%if exe or remote_path:
gdbscript = '''
tbreak main
continue
'''.format(**locals())
%endif

# =======================
# -- EXPLOIT GOES HERE --
# =======================
%if ctx.binary and quiet:
# ${'%-10s%s-%s-%s' % ('Arch:',
                       ctx.binary.arch,
                       ctx.binary.bits,
                       ctx.binary.endian)}
%for line in ctx.binary.checksec(color=False).splitlines():
# ${line}
%endfor
%endif

io = start()

# payload

io.interactive()

