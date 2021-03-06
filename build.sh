#!/bin/bash

DEBUG="debug"
#DEBUG=""

GCC_PATH=`pwd`/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin
export PATH=$GCC_PATH:$PATH
OUT_DIR=$OUT_DIR_COMMON_BASE/nougat

#export USE_CCACHE=1
#export CCACHE_DIR=`pwd`/.ccache
prebuilts/misc/linux-x86/ccache/ccache -M 120G

if [ "x$1" == "x" ]; then
  products="klimtlte"
else
  products=$1
fi

if [ "x$2" == "xnoclean" ]; then
  noclean=1
else
  noclean=0
fi

# Fix build dependency
mkdir -p prebuilts/qemu-kernel/arm
touch prebuilts/qemu-kernel/arm/LINUX_KERNEL_COPYING

source build/envsetup.sh

if [ "x$noclean" == "x0" ]; then
  make clean
fi

for product in $products
do
  echo "lunch aosp_${product}-user$DEBUG"
  lunch aosp_${product}-user$DEBUG
  make -j 16 otapackage 2>&1 | tee build.log
  
  ROM_ORG="aosp_${product}-ota-eng.jeff.zip"
  ROM="aosp-${product}-`grep "ro.build.version.incremental" $OUT_DIR/target/product/${product}/system/build.prop | sed "s/ro.build.version.incremental=//g"`.zip"
  
  mv $OUT_DIR/target/product/${product}/${ROM_ORG} $OUT_DIR/target/product/${product}/${ROM}
  md5sum $OUT_DIR/target/product/${product}/${ROM} > $OUT_DIR/target/product/${product}/${ROM}.md5sum
done
