#!/bin/sh
# -*- coding: utf-8 -*-

set -e
current=$(pwd)
linux=$current/../kernel/linux/BUILD   # kernel source code
uboot=$current/../u-boot/BUILD  #uboot source code
qemurv32=$current/qemu-rv32


#-----------------------------------------------------------------------------------------------------
# Copy Files here
#-----------------------------------------------------------------------------------------------------
do_copy(){
    
    if find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print -quit | grep -q .;then
        
        getimage=$( find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print )
        
        echo "### Copy RISCV kernel below to here ###"
        for item in ${getimage}; do
            echo -e "${item} \n"
        done
        
        if [ ! -d ${current}/kernel ];then
            mkdir $qemurv32/kernel
        else
            echo "### Remake '$qemurv32/kernel' directory ###"
            rm -rf $qemurv32/kernel
            mkdir  $qemurv32/kernel
        fi
        
        cp -f $getimage ./kernel
        echo "@@@@@ Copy finished @@@@@"
    else
        echo "@@@@@ Copy Image to here Failed, You need Build First.  @@@@@ "
        exit 1
    fi
    
    echo "@@@@@ Copy uboot binaries here! @@@@@@"
    
    if [ ! -d  "$qemurv32/uboot" ];then
        mkdir $qemurv32/uboot
    else
        echo "### Remake '$qemurv32/uboot' directory ###"
        rm -rf $qemurv32/uboot
        mkdir $qemurv32/uboot
    fi
    
    if find $uboot/ -maxdepth 1 -type f -regex '\.\/u-boot\(\.bin\)?' -print | grep -q .;then
        
        getbin=$(find ./ -maxdepth 1 -type f -regex '\.\/u-boot\(\.bin\)?')
        
        for item in $getbin; do
            echo -e "Find Uboot files: $item "
        done
        
        cp -f $getbin  $qemurv32/uboot
        echo "@@@@@ Copy uboot finished @@@@@"
    else
        echo "@@@@@ You need Build UBoot first @@@@@"
        exit 1
    fi
    
}


case $1 in
    -h | --help)
        echo "$0 -c         \" Copy files here \" "
    ;;
    -c)
        do_copy()
    ;;
    *)
        echo "$0 -h[--help] for help list."
    ;;
esac