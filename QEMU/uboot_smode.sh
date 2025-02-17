#!/bin/sh

current=$(pwd)
QEMUOPTS= -machine virt -cpu rv32 -smp 2 -m 128M -nographic -kernel $current/uboot/u-boot.bin

if ! command -v qemu-system-riscv32 &> /dev/null ;then
    
    echo " qemu-system-riscv32 not found! " 
    exit 1

else

# qemu-system-riscv32: virt target https://www.qemu.org/docs/master/system/riscv/virt.html, using qemu deafult OpenSBI as bios
    
    echo "==> Boot Uboot in riscv Core S-mode "
    
    if test  -f $current/uboot/u-boot.bin ;then

            qemu-system-riscv32 $QEMUOPTS
    else 
            echo "==X u-bot.bin not found! " 
            exit 1
    fi
fi 