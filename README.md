# roojsbuilder
Vala and Javascript IDE - for building Vala Desktop applications and Javascript UI's using the roojs libraries (for bootstrap and classic)

---
Debian and Ubuntu packages

  https://www.dropbox.com/sh/sgy9kvzkbaowa92/AAC_Yt3KWzFx8t451BiJLqQ7a?dl=0
  
  * you will need libvala, roojspacker and a few other packages 


Building it

  a) Install roojspacker (either from binary or source)

     see https://www.dropbox.com/sh/sgy9kvzkbaowa92/AAC_Yt3KWzFx8t451BiJLqQ7a?dl=0

  b) Clone this code..
  
    git clone https://github.com/roojs/roobuilder.git
    
  c) configure it.
  
    ./autogen.sh --prefix=/usr
    
  d) make make install
  
    sudo make install
    
  e) run it

    roobuilder
    
---

Notes on updating packaging..

Update Package details.
    Edit the about version (check debian/changelog)
    dch -v {release version}

Build it..

    debuild -us -uc
