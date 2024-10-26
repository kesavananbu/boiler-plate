#!/bin/bash

# Define variables for interface and IP configurations
PARENT_INTERFACE="eth0"                   # The physical interface on your NAS
MACVLAN_BRIDGE_INTERFACE="macvlan_b"           # Bridge interface name
MACVLAN_IP="192.168.1.100/24"             # IPv4 address for the macvlan interface
MACVLAN_IPV6="fe80::100/64"               # IPv6 address for the macvlan interface
GATEWAY_IP="192.168.1.1"                  # Default gateway for IPv4
GATEWAY_IPV6="fe80::7e10:c9ff:fed5:1f20"  # Default gateway for IPv6

# Check if dvlan_bridge exists, and create it if not
if ! ip link show "$MACVLAN_BRIDGE_INTERFACE" &> /dev/null; then
    echo "Setting up $MACVLAN_BRIDGE_INTERFACE..."
    sudo ip link add "$MACVLAN_BRIDGE_INTERFACE" link "$PARENT_INTERFACE" type macvlan mode bridge
    sudo ip addr add "$MACVLAN_IP" dev "$MACVLAN_BRIDGE_INTERFACE"
    sudo ip -6 addr add "$MACVLAN_IPV6" dev "$MACVLAN_BRIDGE_INTERFACE"
    sudo ifconfig "$MACVLAN_BRIDGE_INTERFACE" up
    sudo ip link set "$MACVLAN_BRIDGE_INTERFACE" up
    sudo ip route add 192.168.1.0/24 dev "$MACVLAN_BRIDGE_INTERFACE"
    sudo ip route delete 192.168.1.0/24 dev "$PARENT_INTERFACE"
    echo "$MACVLAN_BRIDGE_INTERFACE setup complete."
else
    echo "$MACVLAN_BRIDGE_INTERFACE already exists, skipping setup."
fi

# Add IPv4 and IPv6 routes if not already present
if ! ip route | grep -q "default via $GATEWAY_IP dev $MACVLAN_BRIDGE_INTERFACE"; then
    sudo ip route add default via "$GATEWAY_IP" dev "$MACVLAN_BRIDGE_INTERFACE"
fi

if ! ip -6 route | grep -q "default via $GATEWAY_IPV6 dev $MACVLAN_BRIDGE_INTERFACE"; then
    sudo ip -6 route add default via "$GATEWAY_IPV6" dev "$MACVLAN_BRIDGE_INTERFACE"
fi

echo "Macvlan setup complete. $MACVLAN_BRIDGE_INTERFACE with IP $MACVLAN_IP and IPv6 $MACVLAN_IPV6 is now active."

sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -p

