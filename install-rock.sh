
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
