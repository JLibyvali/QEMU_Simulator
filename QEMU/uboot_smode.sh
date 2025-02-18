#!/bin/sh

set -e

current=$(pwd)
QEMUOPTS= -machine virt -cpu rv32 -smp 2 -m 128M -nographic -kernel $current/uboot/u-boot.bin

check_qemu()
{
    
    if ! command -v qemu-system-riscv32 &> /dev/null ;then
        echo " qemu-system-riscv32 not found! "
        exit 1
    fi
    
}


boot_uboot_smode(){
    
    # qemu-system-riscv32: virt target https://www.qemu.org/docs/master/system/riscv/virt.html, using qemu deafult OpenSBI as bios
    
    echo "==> Boot Uboot in riscv Core S-mode "
    
    if test  -f $current/uboot/u-boot.bin ; then
        
        qemu-system-riscv32 $QEMUOPTS
    else
        echo "==X u-bot.bin not found! "
        exit 1
    fi
}



case $1 in
    -h | --help)
        echo "$0 -uboot         \" Boot U-boot in directly to S-mode. \" "
    ;;
    -uboot)
        check_qemu()
        boot_uboot_smode()
    ;;
    *)
        echo "$0 -h[--help] for look help list."
    ;;
esac