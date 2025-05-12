#!/bin/bash

src_dir=$(realpath $PWD)

target_dirs="
../../add_files/rk3528_fs
../../add_files/rk3568_fs
../../add_files/rk3588_fs
"

for dir in $target_dirs;do
  (
    cd $dir
    tdir=$(realpath $PWD)
    rm -f ${tdir}/etc/udev/rules.d/99-set-mac.rules
    rm -f ${tdir}/usr/local/bin/set_mac.sh
    cp -v ${src_dir}/99-set-mac.rules ${tdir}/etc/udev/rules.d/
    cp -v ${src_dir}/set_mac.sh ${tdir}/usr/local/bin/ && chmod 755 ${tdir}/usr/local/bin/set_mac.sh
  )
done

