if [ ! -d $1/wrlinux-x/layers/wr-toolchain/4.6a-95 ]; then
    cd $1/wrlinux-x/layers/wr-toolchain
    git clone git://yow-git.wrs.com/toolchain/4.6a-95
fi
cd $1/wrlinux-x/layers/wr-toolchain/4.6a-95 ; git pull ; git checkout $2
