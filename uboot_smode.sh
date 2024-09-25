#!/bin/sh

current=$(pwd)

echo " @@@@@@@@ Boot uboot in riscv S mode @@@@@@@ "
if ! command -v qemu-system-riscv32 &> /dev/null ;then
    echo " qemu-system-riscv32 not found! " 
    exit 1
else

# qemu-system-riscv32: virt target https://www.qemu.org/docs/master/system/riscv/virt.html, using qemu deafult OpenSBI as bios
    if test  -f $current/uboot/u-boot.bin ;then
            echo " qemu-system-riscv32 found "
            qemu-system-riscv32 -machine virt -cpu rv32 -smp 2 -m 128M  \
            -nographic \
            -kernel $current/uboot/u-boot.bin
    else 
            echo " u-bot.bin not found! " 
            exit 1
    fi
fi 