So I had a need to rip a music CD from my collection, and this is how I got it working in xubuntu 16.04 x64.

```bash
apt-get update
apt-get install libgtk2.0-dev libcddb2-dev intltool flac vorbis-tools

wget http://downloads.xiph.org/releases/cdparanoia/cdparanoia-III-10.2.src.tgz
tar -xvf cdparanoia-III-10.2.src.tgz
cd cdparanoia-III-10.2/
./configure
make all
sudo make install

wget http://littlesvr.ca/asunder/releases/asunder-2.9.1.tar.bz2
bunzip2 asunder-2.9.1.tar.bz2
tar -xvf asunder-2.9.1.tar
cd asunder-2.9.1/
./configure
make
sudo make install
```

Thereafter, running `asunder` would execute a GUI front-end for you to launch the CD-ripping process.
