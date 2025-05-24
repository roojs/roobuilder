# roobuilder
Vala and Javascript IDE - for building Vala Desktop applications and Javascript UI's using the roojs libraries (for bootstrap and classic)

---
**Videos** 

GLib Settings Demo

Part 1 - click to view on youtube

[![GLib Settings Demo Part 1](https://i.ytimg.com/vi/kx4B0frG-vc/hqdefault.jpg)](https://www.youtube.com/watch?v=kx4B0frG-vc&t=20s "GLib Settings Demo Part 1 - Click to Watch!")

Part 2 - click to view on youtube

[![GLib Settings Demo Part 2](https://i.ytimg.com/vi/XChS0YEB4yY/hqdefault.jpg)](https://www.youtube.com/watch?v=XChS0YEB4yY&t=6s "GLib Settings Demo Part 2 - Click to Watch!")

---
**Changlog** 

  https://github.com/roojs/roobuilder/blob/master/debian/changelog

---
**Features Wishlist** 

    Random list of ideas to add - I regulary add these in totally random order.
    
    https://docs.google.com/spreadsheets/d/1-qNQX1Bwwd1cV405Kj1l3B3Mi6K-GvECnMeuzRKfbGA/edit?usp=sharing
    
---
**Debian and Ubuntu packages** 

 you will need libvala (available on most debian/ubuntu repos), 
   and vala-language-server (available below)
 
Dependancies

  * https://github.com/roojs/vala-language-server/releases 
  * https://github.com/roojs/roojspacker/releases
  
Release

  * https://github.com/roojs/roobuilder/releases
  
---

**Building it** 

  a) Clone this code..
  
    git clone https://github.com/roojs/roobuilder.git
    
  b) configure it.
  
    meson setup build --prefix=/usr
    
  c) make make install
  
    ninja -C build install
    
  e) run it

    roobuilder
    
---

**Notes on updating packaging..** 

Update Package details.
    
    dch -U -i (auto increases release..)
    
    then edit the about version (check debian/changelog)

Build it..

    dpkg-buildpackage -rfakeroot -us -uc -b

    flatpak-builder   --force-clean --sandbox  --install --mirror-screenshots-url=https://dl.flathub.org/repo/screenshots --repo=repo build-dir org.roojs.roobuilder.json
    flatpak build-bundle repo ../roobuilder.flatpak org.roojs.roobuilder
---

**Known issues** 


  * See the wishlist..