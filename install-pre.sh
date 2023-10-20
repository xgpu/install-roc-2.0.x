
## starts here!
mkdir -p rxVega64fe; cd rxVega64fe
mkdir -p pre; cd pre

sudo apt update; sudo apt upgrade -y;
sudo apt install make cmake build-essential -y
sudo apt install libncurses5-dev flex bison libssl-dev libelf-dev -y

git clone https://github.com/xgpu/ROCK-Kernel-Driver.git -b roc-2.0.x
cd ROCK-Kernel-Driver
make rock-rel_defconfig
make -j `nproc`; make modules -j `nproc`; make bindeb-pkg LOCALVERSION=-rxvega64fe -j `nproc`
cd ..

sudo dpkg -i linux-headers-4.18.0-kfd-rxvega64fe_4.18.0-kfd-rxvega64fe-1_amd64.deb \
linux-libc-dev_4.18.0-kfd-rxvega64fe-1_amd64.deb \
linux-image-4.18.0-kfd-rxvega64fe_4.18.0-kfd-rxvega64fe-1_amd64.deb \
linux-image-4.18.0-kfd-rxvega64fe-dbg_4.18.0-kfd-rxvega64fe-1_amd64.deb

sudo usermod -a -G video $LOGNAME
sudo systemctl reboot
