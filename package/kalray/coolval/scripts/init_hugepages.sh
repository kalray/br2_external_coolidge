#!/bin/sh

set -ex

# Before launching coolval we need to enable hugepage. The test will map, write
# and read 10Mo. So we let's allocate 5 huge pages of 2Mo.
echo 5 > /proc/sys/vm/nr_hugepages
mkdir -p /mnt/huge_2mb
mount -t hugetlbfs nodev /mnt/huge_2mb

# and 160 pages of 64Ko
echo 160 > /sys/kernel/mm/hugepages/hugepages-64kB/nr_hugepages
mkdir -p /mnt/huge_64kb
mount -t hugetlbfs nodev /mnt/huge_64kb -o pagesize=64K
