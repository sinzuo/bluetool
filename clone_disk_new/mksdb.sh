#!/bin/sh
#
#

fdisk /dev/sdb <<_EOT
d
1
d
2



n
p
1

+500M
n
p
2

+1800G


a
1

t
2
8e
w
_EOT

