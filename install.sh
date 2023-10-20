#!/bin/bash

## starts here!
sudo apt update; sudo apt upgrade -y;
sudo apt install make cmake build-essential -y
sudo apt install libncurses5-dev flex bison libssl-dev libelf-dev -y
mkdir -p rxVega64fe
cd rxVega64fe
git clone https://github.com/xgpu/ROCK-Kernel-Driver.git -b roc-2.0.x
cd ROCK-Kernel-Driver
make rock-rel_defconfig
make -j `nproc`; make modules -j `nproc`; make bindeb-pkg LOCALVERSION=-rxvega64fe -j `nproc`
cd ..
sudo dpkg -i *.deb
sudo usermod -a -G video $LOGNAME
sudo systemctl reboot


# build libdrm
sudo apt install libnuma-dev libpciaccess-dev ninja-build
sudo apt install python3-pip
pip3 install meson
export PATH=$HOME/.local/bin:$PATH

git clone https://gitlab.freedesktop.org/mesa/drm.git
cd drm
mkdir build; cd build
meson .. -Dintel=disabled -Dnouveau=disabled -Dvmwgfx=disabled --prefix=$HOME/.local/drm; ninja install

# ROCT
sudo apt install libpci-dev pkg-config
git clone https://github.com/xgpu/ROCT-Thunk-Interface.git -b roc-2.0.x
cd ROCT-Thunk-Interface
mkdir build; cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/.local/amd/roct
make -j `nproc` install
cd ..
cp -r ./include $HOME/.local/amd/roct

export ROCT_PATH=$HOME/.local/amd/roct
export LD_LIBRARY_PATH=$ROCT_PATH/lib:$LD_LIBRARY_PATH

# ROCR
git clone https://github.com/xgpu/ROCR-Runtime.git -b roc-2.0.x
cd ROCR-Runtime/src
mkdir -p build; cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/.local/amd/rocr -DHSAKMT_INC_PATH=$ROCT_PATH/include -DHSAKMT_LIB_PATH=$ROCT_PATH/lib
make install -j `nproc`
cd ../../../

export ROCR_PATH=$HOME/.local/amd/rocr
export LD_LIBRARY_PATH=$ROCR_PATH/hsa/lib:$LD_LIBRARY_PATH

# get rocminfo.cpp
export LD_LIBRARY_PATH=/home/aditya/.local/amd/rocr/hsa/lib/:$LD_LIBRARY_PATH
g++ rocminfo.cpp  -I $ROCR_PATH/include -L $ROCR_PATH/hsa/lib -l hsa-runtime64

# HCC
# automatically fetches all submodules
git clone --recursive -b roc-2.0.x https://github.com/xgpu/hcc.git
cd hcc
mkdir build; cd build
cmake -DCMAKE_BUILD_TYPE=Release .. -DCMAKE_INSTALL_PREFIX=$HOME/.local/amd/hcc  -DHSA_HEADER_DIR=$ROCR_PATH/hsa/include -DHSA_LIBRARY_DIR=$ROCR_PATH/hsa/lib -G Ninja
ninja install
cd ../..

export HCC_HOME=$HOME/.local/amd/hcc
export PATH=$HCC_HOME/bin:$PATH
export LD_LIBRARY_PATH=$HCC_HOME/lib:$LD_LIBRARY_PATH

# HIP
git clone https://github.com/xgpu/HIP.git -b roc-2.0.x
cd HIP
mkdir build; cd build
cmake .. -DHCC_HOME=$HCC_HOME -DHSA_PATH=$ROCR_PATH/hsa -DCMAKE_INSTALL_PREFIX=$HOME/.local/amd/hip
make install -j `nproc`
cd ../../

export HIP_PATH=$HOME/.local/amd/hip

# HIP Samples
git clone https://github.com/xgpu/HIP-Examples.git
cd HIP-Examples/vectorAdd
$HIP_PATH/bin/hipcc vectoradd_hip.cpp --amdgpu-target=gfx900  -I /home/aditya/.local/amd/rocr/include -L $HOME/.local/amd/rocr/lib -lhsa-runtime64
./a.out
