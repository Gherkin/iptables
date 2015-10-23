#!/bin/bash
SERVERIP=
DNSIP=


# Accept everything on loopback
-A INPUT -i lo -j ACCEPT

# Accept ssh connections from everywhere
-A INPUT -d $SERVERIP/32 -p tcp -m tcp --sport 513:65535 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

# Accept everything that is a response to a package we sent
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Accept everything coming from the virtual machines
-A INPUT -i virbr0 -j ACCEPT

# Log everything before it gets dropped, for debugging purposes
-A INPUT -j LOG
-A INPUT -j DROP



# Accept everything going to virtual machines
-A OUTPUT -o lo -j ACCEPT

# Accept output going to ssh
-A OUTPUT -s $SERVERIP/32 -p tcp -m tcp --sport 22 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT

# Accept connections to the DNS
-A OUTPUT -s $SERVERIP/32 -d $DNSIP/32 -o enp3s0 -p udp -m udp --dport 53 -m state --state NEW -j ACCEPT

# Accept everything going to the virtual machines
-A OUTPUT -o virbr0 -j ACCEPT

# Accept outgoing HTTP and HTTPS requests (to permit yum to work)
-A OUTPUT -p tcp -m tcp --dport 443 -m state --state NEW -j ACCEPT
-A OUTPUT -p tcp -m tcp --dport 80 -m state --state NEW -j ACCEPT

# Accept everything related to an established connection
-A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Log everything before it gets dropped, for debugging purposes
-A OUTPUT -j LOG
-A OUTPUT -j DROP
