#!/bin/sh
# -*- coding: utf-8 -*-

set -e
current=$(pwd)
linux=$current/../kernel/linux/BUILD   # kernel source code
uboot=$current/../u-boot/BUILD  #uboot source code
opensbi=$current/../opensbi/BUILD
qemurv64=$current/qemu-rv64


#-----------------------------------------------------------------------------------------------------
# Copy Files here
#-----------------------------------------------------------------------------------------------------
do_copy(){
    
    cd $current
    
    case $1 in
        opensbi)
            
            if [ -d "$qemurv64/opensbi" ]; then
                rm -rf $qemurv64/opensbi
                mkdir -p $qemurv64/opensbi
            else
                mkdir -p $qemurv64/opensbi
            fi
            
            if find $opensbi/platform/generic/firmware -maxdepth 1 -type f -name "*.elf" -print -quit | grep -q .; then
                getfiles=$(find $opensbi/platform/generic/firmware -maxdepth 1 -type f \( -name "*.elf" -or -name "*.bin" \) -print )
                
                for item in $getfiles; do
                    echo -e "-> Copied: $item"
                    cp $item        $qemurv64/opensbi
                done
            fi
            
            echo -e "-> Copied OpenSBI finished. "
        ;;
        uboot)
            if [ ! -d  "$qemurv64/uboot" ];then
                mkdir $qemurv64/uboot
            else
                rm -rf $qemurv64/uboot
                mkdir $qemurv64/uboot
            fi
            
            if find $uboot -maxdepth 1 -type f -name "u-boot" -print -quit | grep -q .;then
                
                cp $uboot/u-boot        $qemurv64/uboot
                echo "-> cp $uboot/u-boot        $qemurv64/uboot"
                
                cp $uboot/u-boot.bin    $qemurv64/uboot
                echo "-> cp $uboot/u-boot.bin    $qemurv64/uboot"
                
                
                if [ -f "$uboot/spl/u-boot-spl" ];then
                    cp $uboot/spl/u-boot-spl $qemurv64/uboot
                    echo "-> cp $uboot/spl/u-boot-spl $qemurv64/uboot"
                    
                    cp $uboot/u-boot.itb    $qemurv64/uboot
                    echo "-> cp $uboot/u-boot.itb    $qemurv64/uboot"
                fi
                
            else
                echo -e "-> You need Build UBoot first. "
                exit 1
            fi
            
        ;;
        kernel)
            if [ ! -d "$qemurv64/kernel" ];then
                mkdir $qemurv64/kernel
            else
                rm -rf $qemurv64/kernel
                mkdir  $qemurv64/kernel
            fi
            
            
            if find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print -quit | grep -q .;then
                
                getimage=$( find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print )
                
                cp $getimage $qemurv64/kernel/
                
                echo -e "->Kernel Copy finished: $qemurv64/kernel"
            else
                echo -e "-> Copy Image to here Failed, You need Build First."
                exit 1
            fi
            
        ;;
        *)
            echo -e "Must select a Target."
            exit 1
        ;;
    esac
    
}

build_opensbi(){
    
    echo "cd $current/../opensbi"
    cd $current/../opensbi
    
    cur=$(pwd)
    
    if [ ! -d "$cur/BUILD" ]; then
        mkdir ./BUILD
    fi
    
    case $1 in
        qemu)
            make V=2 O=./BUILD CROSS_COMPILE=riscv64-linux- PLATFORM=generic PLATFORM_RISCV_XLEN=64 distclean
            
            make V=2 O=./BUILD CROSS_COMPILE=riscv64-linux- PLATFORM=generic PLATFORM_RISCV_XLEN=64 all -j 8
        ;;
        uboot)
            
            if [ -f "$cur/../u-boot/BUILD/u-boot" ];then
                
                make V=2 O=./BUILD CROSS_COMPILE=riscv64-linux- PLATFORM=generic PLATFORM_RISCV_XLEN=64 clean
                
                make V=2 O=./BUILD CROSS_COMPILE=riscv64-linux- PLATFORM=generic FW_PAYLOAD_PATH=$cur/../u-boot/BUILD/u-boot  -j 8
                
            else
                echo "-> You need build UBoot first, for OpenSBI payload usage."
                exit 1
            fi
        ;;
        kernel)
            # make V=2 O=./BUILD CROSS_COMPILE=riscv64-linux- PLATFORM=generic PLATFORM_RISCV_XLEN=64 clean
            
            # make V=2 O=./BUILD CROSS_COMPILE=riscv64-linux- PLATFORM=generic FW_PAYLOAD_PATH=$cur/../kernel/linux/BUILD/arch/boot/Image  -j 8
        ;;
        *)
            echo "-> Must define a OpenSBI target"
            exit 1
        ;;
    esac
    
    do_copy opensbi
}



build_uboot(){
    echo -e "-> cd $current/../u-boot"
    
    cd $current/../u-boot
    cur=$(pwd)
    
    cd $cur
    
    if [ ! -d "./BUILD" ]; then
        mkdir ./BUILD
    fi
    
    case $1 in
        smode)
            
            cp $cur/../QEMU/qemu-rv64/uboot-qemu-riscv64-smode.config $cur/configs
            
            if [ ! -f ./BUILD/.config ];then
                
                make O=./BUILD V=2 CROSS_COMPILE=riscv64-linux- qemu-riscv64_smode_defconfig
            fi
            
            make O=./BUILD V=2 CROSS_COMPILE=riscv64-linux- clean
            
            make O=./BUILD V=2 CROSS_COMPILE=riscv64-linux- uboot-qemu-riscv64-smode.config
            
            make O=./BUILD V=2 CROSS_COMPILE=riscv64-linux- -j 8
            
            rm $cur/configs/uboot-qemu-riscv64-smode.config
            
        ;;
        spl)
            if [ -f "../opensbi/BUILD/platform/generic/firmware/fw_dynamic.bin" ]; then
                
                cp $cur/../QEMU/qemu-rv64/uboot-qemu-riscv64-spl.config         $cur/configs
                
                make O=./BUILD V=2 CROSS_COMPILE=riscv64-linux- OPENSBI=../opensbi/BUILD/platform/generic/firmware/fw_dynamic.bin   mrproper
                
                make O=./BUILD V=2 CROSS_COMPILE=riscv64-linux- OPENSBI=../opensbi/BUILD/platform/generic/firmware/fw_dynamic.bin   uboot-qemu-riscv64-spl.config
                
                make O=./BUILD V=2 CROSS_COMPILE=riscv64-linux- OPENSBI=../opensbi/BUILD/platform/generic/firmware/fw_dynamic.bin   -j 8
                
                rm $cur/configs/uboot-qemu-riscv64-spl.config
                
            else
                echo -e "-> Must Build OpenSBI in qemu-virt first."
                exit 1
            fi
            
        ;;
        uboot)
            
        ;;
        *)
            echo -e "-> Must Select a UBoot target. "
            exit 1
        ;;
    esac
    
    do_copy uboot
}


build_kernel(){
    echo "None implement"
}


case $1 in
    -opensbi)
        case $2 in
            qemu)
                echo  "build_opensbi qemu"
                build_opensbi qemu
            ;;
            uboot)
                echo  "build_opensbi uboot"
                build_opensbi uboot
            ;;
            kernel)
                echo  "build_opensbi kernel"
                build_opensbi kernel
            ;;
            *)
                echo "$0 -opensbi qemu          Build OpenSBI with Non_payload, just qemu-virt platform and execute."
                echo "$0 -opensbi uboot         Build OpenSBI with UBoot Payload."
                echo "$0 -opensbi kerenl        Build OpenSBI with Kernel Payload."
            ;;
        esac
        
    ;;
    -uboot)
        case $2 in
            spl)
                echo "build_uboot spl"
                build_uboot spl
            ;;
            smode)
                echo "build_uboot smode"
                build_uboot smode
            ;;
            uboot)
                echo "build_uboot uboot"
                build_uboot uboot
            ;;
            *)
                echo "$0 -uboot spl             Build UBoot SPL mode."
                echo "$0 -uboot smode           Build UBoot in S-mode for riscv."
                echo "$0 -uboot uboot           Build Total Version UBoot."
        esac
        
    ;;
    -kernel)
        build_kernel
    ;;
    *)
        echo "$0         -opensbi [qemu] [uboot] [kernel]      Build OpenSBI from source and copy here."
        echo "$0         -uboot [spl] [smode] [uboot]          Build Uboot from source and copy here."
        echo "$0         -kernel                               Build Kernel from source and copy here."
        
    ;;
esac