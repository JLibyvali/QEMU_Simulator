#!/bin/sh

current=$(pwd)
uboot=$current/uboot
kernel=$current/kernel

if [ -d "$uboot" ];then
    echo " remove uboot files " 
    rm -r $uboot
fi

if [ -d "$kernel" ];then 
    echo " remove kernel files "
    rm -r $kernel
fi

echo " clean all " 