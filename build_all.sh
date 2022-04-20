#!/bin/sh

bash build.sh debian ubuntu focal linux-aws ubuntu.cfg "Ubuntu 20.04(Focal)"
bash build.sh debian ubuntu impish linux-aws ubuntu.cfg "Ubuntu 21.10(Impish)"
bash build.sh debian ubuntu jammy linux-aws ubuntu.cfg "Ubuntu 22.04(Jammy)"
bash build.sh debian debian bullseye sshfs  debian.cfg "Debian 11(Bullseye)"