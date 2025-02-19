#!/bin/sh
# -*- coding: utf-8 -*-

set -e

current=$(pwd)
QEMUOPTS='-machine virt -cpu rv64  -smp 2 -m 512M -nographic'

check_qemu()
{
    
    if ! command -v qemu-system-riscv64 &> /dev/null ;then
        echo " qemu-system-riscv64 not found! "
        exit 1
    fi
    
}


run_uboot(){
    
    case $1 in
        
        spl)
            if [ [ ! -f "$current/qemurv64/uboot/u-boot-spl" ] && [ ! -f "$current/qemurv64/uboot/u-boot.itb" ] ]; then
                echo "-> No UBoot SPL mode boot file: 'u-boot-spl  u-boot.itb'  "
                exit 1
            fi
            
            echo "->    qemu-system-riscv64 $QEMUOPTS -serial stdio -bios $current/qemurv64/uboot/u-boot-spl  -device loader,file=$current/qemurv64/uboot/u-boot.itb,addr=0x80200000 "
            qemu-system-riscv64 $QEMUOPTS -serial stdio -bios $current/qemurv64/uboot/u-boot-spl -device loader,file=$current/qemurv64/uboot/u-boot.itb,addr=0x80200000
        ;;
        smode)
            
            if [ ! -f  "$current/qemu-rv64/uboot/u-boot.bin" ]; then
                echo "-> None UBoot Smode file: 'u-boot.bin'  "
                exit 1
            fi
            
            echo "->    qemu-system-rv64 $QEMUOPTS -kernel $current/qemu-rv64/uboot/u-boot.bin "
            qemu-system-riscv64 $QEMUOPTS -kernel $current/qemu-rv64/uboot/u-boot.bin
            
        ;;
        uboot)
            echo ""
        ;;
        *)
            echo "-> Must Select A target  $0 "
        ;;
    esac
    
}

run_opensbi(){
    
    echo "-> Depends on OpenSBI compile definition  `OPENSBI=`, the fw_payload.elf will load UBoot or Kernel. "
    
    if [ ! -f $current/qemu-rv64/opensbi/fw_payload.elf ]; then
        echo " No OpenSBI Payload File: 'fw_payload.elf' "
        exit 1
    fi
    
    case $1 in
        qemu)
            echo "->    qemu-system-riscv64 $QEMUOPTS  -bios $current/qemu-rv64/opensbi/fw_payload.elf "
            qemu-system-riscv64 $QEMUOPTS -bios $current/qemu-rv64/opensbi/fw_payload.bin
        ;;
        uboot)
            echo "->    qemu-system-riscv64 $QEMUOPTS -bios $current/qemu-rv64/opensbi/fw_payload.elf"
            qemu-system-riscv64 $QEMUOPTS -bios $current/qemu-rv64/opensbi/fw_payload.bin
        ;;
        kernel)
        ;;
        *)
            echo "$0: must select A Boot target. "
            exit 1
        ;;
    esac
    
}

check_qemu

case $1 in
    -opensbi)
        
        case $2 in
            qemu)
                run_opensbi qemu
            ;;
            uboot)
                run_opensbi uboot
            ;;
            kernel)
            ;;
            *)
                echo "$0    -opensbi  qemu       Run custom compiled OpenSBI instead of QEMU inner OpenSBI. "
                echo "$0    -opensbi  uboot      Run custom compiled OpenSBI instead of QEMU inner OpenSBI. "
                echo "$0    -opensbi  kernel     Run custom compiled OpenSBI instead of QEMU inner OpenSBI. "
            ;;
        esac
    ;;
    -uboot)
        
        case $2 in
            spl)
                run_uboot spl
            ;;
            smode)
                run_uboot smode
            ;;
            uboot)
                run_uboot uboot
            ;;
            *)
                echo "$0 -uboot spl             Build UBoot SPL mode."
                echo "$0 -uboot smode           Build UBoot in S-mode for riscv."
                echo "$0 -uboot uboot           Build Total Version UBoot."
            ;;
        esac
        
    ;;
    *)
        echo "$0  -opensbi          Run OpenSBI payload instead of using QEMU inner OpenSBI. "
        echo "$0  -uboot            [spl][smode][uboot] Run UBoot in variant mode. "
    ;;
esac
