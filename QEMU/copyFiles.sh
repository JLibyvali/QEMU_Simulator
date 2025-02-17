#!/bin/sh
# -*- coding: utf-8 -*-

set -e
current=$(pwd)  
linux=$current/../Linux/kernel/linux-5.10.224   # kernel source code 
uboot=$current/../Linux/u-boot  #uboot source code


#-----------------------------------------------------------------------------------------------------
# Copy Files here
#-----------------------------------------------------------------------------------------------------
if find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print -quit | grep -q .;then
    
    getimage=$( find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print )
    
    echo "### Copy RISCV kernel below to here ###"
    for item in ${getimage}; do
        echo -e "${item} \n"
    done

    if [ ! -d ${current}/kernel ];then
        mkdir ./kernel
    else
        echo "### Remake './kernel' directory ###"
        rm -rf ./kernel
        mkdir ./kernel
    fi

    cp -f $getimage ./kernel
    echo "@@@@@ Copy finished @@@@@"
else 
    echo "@@@@@ Copy Image to here Failed, You need Build First.  @@@@@ "
    exit 1
fi

echo "@@@@@ Copy uboot binaries here! @@@@@@"

if [ ! -d  "./uboot" ];then
    mkdir ./uboot
else
    echo "### Remake './uboot' directory ###"
    rm -rf ./uboot
    mkdir ./uboot
fi

if find $uboot/ -maxdepth 1 -type f -regex '\.\/u-boot\(\.bin\)?' -print | grep -q .;then

    getbin=$(find ./ -maxdepth 1 -type f -regex '\.\/u-boot\(\.bin\)?')
    
    for item in $getbin; do
        echo -e "Find Uboot files: $item "
    done

    cp -f $getbin  ../../qemu-riscv32/uboot
    echo "@@@@@ Copy uboot finished @@@@@"
else
    echo "@@@@@ You need Build UBoot first @@@@@"
    exit 1
fi
