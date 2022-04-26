# roojsbuilder
Vala and Javascript IDE - for building Vala Desktop applications and Javascript UI's using the roojs libraries (for bootstrap and classic)


---

Building it

  a) Remove vala and install packages from here. We need to use an old version of vala, as new versions changed the code inspection api,
  and build output and I've not got round to fixing hat.

    sudo apt-get remove vala* libvala*
    
  Download vala*.deb, libvala*.deb,  and roojspacker*.deb from
  https://www.dropbox.com/sh/730btm3yn6jtplh/AABbRFzK6bI6BoHQIMfh3A4Ia?dl=0
    
    sudo dpkg -i libvala* vala*  roojspacker*
    
  b) Clone this code..
  
    git clone https://github.com/roojs/roobuilder.git
    
  c) configure it.
  
    ./autogen.sh --prefix=/usr
    
  d) make make install
  
    sudo make install
    
  e) run it

    roobuilder