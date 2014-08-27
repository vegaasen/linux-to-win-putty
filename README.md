Linux to Windows -- Putty Servers and SSH-stuff
==================

# Introduction

This script is very easy and contain no specific logic. Its just a simple translator for the Putty-client made for Ubuntu and some other Linux distros. You can use it to transfer all saved sessions from Linux to Windows. Nothing fancy :-)

# Usage

	./putty-linux-win.sh {export-sessions (opt) <path>, export-hostkeys (opt) <path>, count-sessions (opt) <path>, count-hostkeys (opt) <path>}

## Examples

	./putty-linux-win.sh export-sessions

# Windows2Linux

> But what about windows-linux? 

..well, that is actually created by another fella, and can be downloaded in his Google Code-project:

[https://code.google.com/p/pwin2lin/](https://code.google.com/p/pwin2lin/)

Please note that this script _requires_ perl.

# Acknowledgements

* Vegard Aasen :-P
