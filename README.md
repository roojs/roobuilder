# roojsbuilder
Vala and Javascript IDE - for building Vala Desktop applications and Javascript UI's using the roojs libraries (for bootstrap and classic)

---
Debian and Ubuntu packages

  https://www.dropbox.com/scl/fo/9gmglurw6s4qqwzc3xkvu/h?dl=0&rlkey=9x0o549ne7gyvii3yc93u3brc

  * you will need libvala, roojspacker and a few other packages 

---

Building it

  a) Install roojspacker (either from binary or source)

     see https://www.dropbox.com/scl/fo/9gmglurw6s4qqwzc3xkvu/h?dl=0&rlkey=9x0o549ne7gyvii3yc93u3brc

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
    
    dch -v {release version}

Build it..

    debuild -us -uc
