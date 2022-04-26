# roojsbuilder
Vala and Javascript IDE - for building Vala Desktop applications and Javascript UI's using the roojs libraries (for bootstrap and classic)


---

Building it

    a) Remove vala and install packages from here.
    
    ```apt-get remove vala* libvala* ```
    Download vala*.deb, libvala*.deb,  and roojspacker*.deb
    https://www.dropbox.com/sh/730btm3yn6jtplh/AABbRFzK6bI6BoHQIMfh3A4Ia?dl=0
    ```dpkg -i libvala* vala*  roojspacker*```
    
    b) ```git clone https://github.com/roojs/roobuilder.git```
    
    c) ```./autogen.sh --prefix=/usr```
    
    d) ```sudo make install```
    
    e) run it

    ```#roobuilder```