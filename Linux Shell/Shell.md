# Shell

---
The following are a collection of Linux Shell snippets and one-liners for your use. 

Hope this helps!

## Table of Contents

I. [One-Liners](#one-liners)

II. [Snippets](#snippets)


## One Liners


## Snippets

### Add Wifi SSID and Password
First, edit /etc/network/interfaces.
Then add the snippet below.
```bash
auto wlan0
iface wlan0 inet dhcp 
                wpa-ssid {ssid}
                wpa-psk  {password}
```
