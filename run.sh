apt-get install libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential -y
apt-get install git -y
git clone --single-branch -b ARM https://github.com/monkins1010/ccminer.git
cd ccminer
chmod +x build.sh
chmod +x configure.sh
chmod +x autogen.sh
./build.sh
git clone https://github.com/monkins1010/ccminer.git
cd ccminer
chmod +x *
./build.sh
./ccminer -a verus -o stratum+tcp://na.luckpool.net:3956 -u REPNzMPtM7seJy5xngt5VWKXMsEi6Ejezb.ferodp -p d=32768S -t 6
