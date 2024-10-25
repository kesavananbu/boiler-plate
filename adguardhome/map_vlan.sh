#!/bin/bash

#First 7 lines only for the initial run
#sudo ip link add dvlan_bridge link eth0 type macvlan mode bridge
#sudo ip addr add 192.168.1.100/24 dev dvlan_bridge
#sudo ifconfig dvlan_bridge up
#sudo ip link set dvlan_bridge up
#sudo ip route add 192.168.1.0/24 dev dvlan_bridge
#sudo ip route delete 192.168.1.0/24 dev eth0
#sudo ip route add 192.168.1.0/24 dev dvlan_bridge


# Define variables for interface and IP configurations
PARENT_INTERFACE="eth0"                   # The physical interface on your NAS
MACVLAN_INTERFACE="macvlan_host"          # Name for the macvlan interface
NAMESPACE="macvlan_ns"                    # Namespace to use
MACVLAN_IP="192.168.1.100/24"             # IPv4 address for the macvlan interface
MACVLAN_IPV6="fe80::100/64"               # IPv6 address for the macvlan interface
GATEWAY_IP="192.168.1.1"                  # Default gateway for IPv4 (optional)
GATEWAY_IPV6="fe80::1"                    # Default gateway for IPv6 (optional)

# Check if namespace exists, and create it if not
if ! ip netns list | grep -q "$NAMESPACE"; then
    ip netns add "$NAMESPACE"
fi

# Delete any existing macvlan interface to avoid duplicates
if ip link show "$MACVLAN_INTERFACE" &> /dev/null; then
    ip link delete "$MACVLAN_INTERFACE"
fi

# Create the macvlan interface
ip link add "$MACVLAN_INTERFACE" link "$PARENT_INTERFACE" type macvlan mode bridge

# Move the macvlan interface to the new namespace
ip link set "$MACVLAN_INTERFACE" netns "$NAMESPACE"

# Assign IPv4 and IPv6 addresses in the namespace and bring up the interface
ip netns exec "$NAMESPACE" ip addr add "$MACVLAN_IP" dev "$MACVLAN_INTERFACE"
ip netns exec "$NAMESPACE" ip -6 addr add "$MACVLAN_IPV6" dev "$MACVLAN_INTERFACE"
ip netns exec "$NAMESPACE" ip link set "$MACVLAN_INTERFACE" up

# Optionally, set up IPv4 and IPv6 default routes in the namespace
ip netns exec "$NAMESPACE" ip route add default via "$GATEWAY_IP" dev "$MACVLAN_INTERFACE"
ip netns exec "$NAMESPACE" ip -6 route add default via "$GATEWAY_IPV6" dev "$MACVLAN_INTERFACE"

echo "Macvlan setup complete. $MACVLAN_INTERFACE with IP $MACVLAN_IP and IPv6 $MACVLAN_IPV6 is now in namespace $NAMESPACE."
