#!/bin/sh
current=$(pwd)  
linux=$current/../Linux/kernel/linux-5.10.224   # kernel source code 
echo "@@@@@ Copy kernel images here! @@@@@"

if find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print -quit | grep -q .;then
    getimage=$( find $linux/arch/riscv/boot/ -maxdepth 1 -type f -name "*Image" -print )
    echo "### Copy RISCV kernel below to here ###"
    for item in ${getimage}; do
        echo -e "${item} \n"
    done

    if [ ! -d ${current}/kernel ];then
        mkdir ./kernel
    else
        echo "### ./kernel remake ###"
        rm -r ./kernel
        mkdir ./kernel
    fi

    cp $getimage ./kernel
    echo "@@@@@ Copy finished @@@@@"
else 
    echo "@@@@@ Failed, Build Riscv kernel first @@@@@ "
fi

echo "@@@@@ Copy uboot binaries here! @@@@@@"
uboot=$current/../Linux/u-boot  #uboot source code

if [ ! -d  "./uboot" ];then
    mkdir ./uboot
else
    echo "### uboot dir remake ###"
    rm -r ./uboot
    mkdir ./uboot
fi


cd $uboot
if find ./ -maxdepth 1 -type f -regex '\.\/u-boot\(\.bin\)?' -print | grep -q .;then
    getbin=$(find ./ -maxdepth 1 -type f -regex '\.\/u-boot\(\.bin\)?')
    echo "### Uboot find below ###"
    for item in $getbin; do
        echo -e "$item \n"
    done

    cp -f $getbin  ../../qemu-riscv32/uboot
    echo "@@@@@ Copy uboot finished @@@@@"
else
    echo "@@@@@ Build uboot first @@@@@"
fi

cd $current
tree
du -hsc
