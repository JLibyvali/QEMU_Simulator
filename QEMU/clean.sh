#!/bin/sh
# -*- coding: utf-8 -*-

set -e

current=$(pwd)
uboot=$current/qemu-rv32/uboot
kernel=$current/qemu-rv32/kernel

find $current -type f \( -name "u-boot*" -or -name "*Image" \) -exec rm -f {} + || true