# Fortinet

---
Fortinet notes and CLI.

## Table of Contents

I. [Run Ping and Traceroute](#run-ping-and-traceroute)

II. [View routing table](#view-routing-table)

III. [Change profile options of all managed switches](#Change-profile-options-of-all-managed-switches)

---
### Run Ping and Traceroute
```basic
exec ping <IP here>

exec traceroute <IP here>

exec traceroute-options <options should be entered one by one>
```

### View routing table
```basic
get router info routing-table all
```

### Change profile options of all managed switches
```basic
config switch-controller switch-profile
edit <profileName>
set long-passwd-overwrite <enable/disable>
set login-passwd <password>
```

### Run packet tracer
```basic
diag sniffer packet <interface> <'filters'> <verbose level> <number of packets to show> <a shows UTC timestamp, l shows local time>
```

Interface uses port number. ex. port2

Filters must be in quotations. E.g. 'src \<IP> and dst \<IP>'

Verbose levels are as follows:
1. print header of packets.
2. print header and data from IP of packets.
3. print header and data from Ethernet of packets.
4. print header of packets with interface name.
5. print header and data from IP of packets with interface name.
6. print header and data from Ethernet of packets with interface name.

[More details can be found here.](https://community.fortinet.com/t5/FortiGate/Troubleshooting-Tip-Using-the-FortiOS-built-in-packet-sniffer/ta-p/194222)
