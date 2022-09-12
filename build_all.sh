#!/bin/sh
bash build.sh alpine alpine 3.16 none alpine.cfg "Alpine 3.16" &
bash build.sh alpine alpine 3.15 none alpine.cfg "Alpine 3.15" &
bash build.sh alpine alpine 3.14 none alpine.cfg "Alpine 3.14" &
bash build.sh debian ubuntu focal linux-aws ubuntu.cfg "Ubuntu 20.04(Focal)" &
bash build.sh debian ubuntu jammy linux-aws ubuntu.cfg "Ubuntu 22.04(Jammy)" &
bash build.sh debian debian bullseye sshfs  debian.cfg "Debian 11(Bullseye)" &

wait
