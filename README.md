# roojsbuilder
Vala and Javascript IDE - for building Vala Desktop applications and Javascript UI's using the roojs libraries (for bootstrap and classic)

---
Changlog 

  https://github.com/roojs/roobuilder/blob/master/debian/changelog

---
Debian and Ubuntu packages

 * you will need libvala (available on most debian/ubuntu repos), 
   and vala-language-server (available below)
 
  https://github.com/roojs/roobuilder/releases
  https://github.com/roojs/vala-language-server/releases 
  


Building it

  a) Clone this code..
  
    git clone https://github.com/roojs/roobuilder.git
    
  b) configure it.
  
    meson setup build --prefix=/usr
    
  c) make make install
  
    ninja -C install
    
  e) run it

    roobuilder
    
---

Notes on updating packaging..

Update Package details.
    Edit the about version (check debian/changelog)
    
    dch -U -i (auto increases release..)
    dch -v {release version}

Build it..

    dpkg-buildpackage -rfakeroot -us -uc -b

    flatpak-builder --force-clean --sandbox --user --install --mirror-screenshots-url=https://dl.flathub.org/repo/screenshots --repo=repo build-dir org.roojs.roobuilder.json

---

Known issues

  * Flatpack -  run doesnt work - needs more work understanding how flatpack would manage to compile with libraries from the system, or inside the pack
  