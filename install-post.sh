#!/bin/bash

cd rxVega64fe
mkdir -p post; cd post
# build libdrm
sudo apt install libnuma-dev libpciaccess-dev ninja-build -y
sudo apt install python3-pip -y
pip3 install meson
export PATH=$HOME/.local/bin:$PATH

git clone https://gitlab.freedesktop.org/mesa/drm.git
cd drm
mkdir build; cd build
meson .. -Dintel=disabled -Dnouveau=disabled -Dvmwgfx=disabled --prefix=$HOME/.local/drm; ninja install
cd ../..

# ROCT
export ROCT_PATH=$HOME/.local/amd/roct
sudo apt install libpci-dev pkg-config -y
git clone https://github.com/xgpu/ROCT-Thunk-Interface.git -b roc-2.0.x
cd ROCT-Thunk-Interface
mkdir build; cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$ROCT_PATH
make -j `nproc` install
cd ..
cp -r ./include $ROCT_PATH
cd ..

export LD_LIBRARY_PATH=$ROCT_PATH/lib:$LD_LIBRARY_PATH

# ROCR
export ROCR_PATH=$HOME/.local/amd/rocr
git clone https://github.com/xgpu/ROCR-Runtime.git -b roc-2.0.x
cd ROCR-Runtime/src
mkdir -p build; cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ROCR_PATH -DHSAKMT_INC_PATH=$ROCT_PATH/include -DHSAKMT_LIB_PATH=$ROCT_PATH/lib
make install -j `nproc`
cd ../../../

export HSA_PATH=$ROCR_PATH/hsa
export LD_LIBRARY_PATH=$HSA_PATH/lib:$LD_LIBRARY_PATH

# get rocminfo.cpp
g++ ../../rocminfo.cpp  -I $HSA_PATH/include -L $HSA_PATH/lib -lhsa-runtime64 -o rocminfo
./rocminfo

# HCC
export HCC_PATH=$HOME/.local/amd/hcc
# automatically fetches all submodules
git clone --recursive -b roc-2.0.x https://github.com/xgpu/hcc.git
cd hcc
mkdir build; cd build
cmake -DCMAKE_BUILD_TYPE=Release .. -DCMAKE_INSTALL_PREFIX=$HCC_PATH  -DHSA_HEADER_DIR=$HSA_PATH/include -DHSA_LIBRARY_DIR=$HSA_PATH/lib -DHSA_AMDGPU_GPU_TARGET=gfx900 -G Ninja
ninja install
cd ../..

export HCC_HOME=$HCC_PATH
export PATH=$HCC_HOME/bin:$PATH
export LD_LIBRARY_PATH=$HCC_HOME/lib:$LD_LIBRARY_PATH

# HIP
git clone https://github.com/xgpu/HIP.git -b roc-2.0.x
cd HIP
mkdir build; cd build
cmake .. -DHCC_HOME=$HCC_HOME -DHSA_PATH=$ROCR_PATH/hsa -DCMAKE_INSTALL_PREFIX=$HOME/.local/amd/hip
make install -j `nproc`
cd ../..

export HIP_PATH=$HOME/.local/amd/hip

# HIP Samples
git clone https://github.com/xgpu/HIP-Examples.git
cd HIP-Examples/vectorAdd
$HIP_PATH/bin/hipcc vectoradd_hip.cpp --amdgpu-target=gfx900  -I /home/aditya/.local/amd/rocr/include -L $HOME/.local/amd/rocr/lib -lhsa-runtime64
./a.out
