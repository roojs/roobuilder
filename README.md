# roobuilder
Vala and Javascript IDE - for building Vala Desktop applications and Javascript UI's using the roojs libraries (for bootstrap and classic)

---
Videos

GLib Settings Demo

Part 1 - click to view on youtube

[![GLib Settings Demo Part 1](https://i.ytimg.com/an_webp/kx4B0frG-vc/mqdefault_6s.webp?du=3000&sqp=COfHkK4G&rs=AOn4CLCCsPUOERRGmjq3GJyjjKojAaFeNQ)](https://www.youtube.com/watch?v=kx4B0frG-vc&t=20s "GLib Settings Demo Part 1 - Click to Watch!")

Part 2 - click to view on youtube

[![GLib Settings Demo Part 2](https://i.ytimg.com/an_webp/XChS0YEB4yY/mqdefault_6s.webp?du=3000&sqp=CNLbkK4G&rs=AOn4CLCnEOREfuG7Pw2UBnGGasCEUlV4Rw)](https://www.youtube.com/watch?v=XChS0YEB4yY&t=6s "GLib Settings Demo Part 2 - Click to Watch!")

---
Changlog 

  https://github.com/roojs/roobuilder/blob/master/debian/changelog

---
Features Wishlist

    Random list of ideas to add - I regulary add these in totally random order.
    
    https://docs.google.com/spreadsheets/d/1-qNQX1Bwwd1cV405Kj1l3B3Mi6K-GvECnMeuzRKfbGA/edit?usp=sharing
    
---
Debian and Ubuntu packages

 you will need libvala (available on most debian/ubuntu repos), 
   and vala-language-server (available below)
 
  * https://github.com/roojs/roobuilder/releases
  * https://github.com/roojs/vala-language-server/releases 
  
---


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
  