#!/bin/bash

# Function to calculate broadcast address
calculate_broadcast() {
    local ip="$1"
    local cidr="$2"
    
    # Convert CIDR to netmask
    local mask=$(( 0xffffffff ^ ((1 << (32 - cidr)) - 1) ))
    
    IFS=. read -r i1 i2 i3 i4 <<< "$ip"
    local ip_num=$(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))
    
    local broadcast=$(( (ip_num & mask) | ~mask & 0xffffffff ))
    
    printf "%d.%d.%d.%d" \
        $(( (broadcast >> 24) & 0xff )) \
        $(( (broadcast >> 16) & 0xff )) \
        $(( (broadcast >> 8) & 0xff )) \
        $(( broadcast & 0xff ))
}

# Function to calculate network address
calculate_network() {
    local ip="$1"
    local cidr="$2"
    
    IFS=. read -r i1 i2 i3 i4 <<< "$ip"
    local mask=$(( 0xffffffff << (32 - cidr) ))
    
    printf "%d.%d.%d.%d" \
        $(( (mask & (i1 << 24 | i2 << 16 | i3 << 8 | i4)) >> 24 & 0xff )) \
        $(( (mask & (i1 << 24 | i2 << 16 | i3 << 8 | i4)) >> 16 & 0xff )) \
        $(( (mask & (i1 << 24 | i2 << 16 | i3 << 8 | i4)) >> 8 & 0xff )) \
        $(( (mask & (i1 << 24 | i2 << 16 | i3 << 8 | i4)) >> 0 & 0xff ))
}

# Function to calculate the gateway address
calculate_gateway() {
    local network_address="$1"
    
    IFS=. read -r n1 n2 n3 n4 <<< "$network_address"
    local gateway=$(( n4 + 1 ))

    printf "%d.%d.%d.%d" "$n1" "$n2" "$n3" "$gateway"
}

# Function to apply network settings
apply_network_settings() {
    local interface="$1"
    local ip_with_cidr="$2"
    
    IFS=/ read -r ip cidr <<< "$ip_with_cidr"
    
    local subnet_mask=$(( 0xffffffff << (32 - cidr) ))
    local subnet_mask_decimal=$(printf "%d.%d.%d.%d" \
        $(( (subnet_mask >> 24) & 0xff )) \
        $(( (subnet_mask >> 16) & 0xff )) \
        $(( (subnet_mask >> 8) & 0xff )) \
        $(( subnet_mask & 0xff )))
    
    local broadcast_address=$(calculate_broadcast "$ip" "$cidr")
    local network_address=$(calculate_network "$ip" "$cidr")
    local gateway=$(calculate_gateway "$network_address")
    local dns_server="8.8.8.8"
    
    echo "Flushing existing IP configuration on $interface..."
    sudo ip addr flush dev "$interface"
    
    echo "Adding IP address $ip/$cidr and broadcast $broadcast_address to $interface..."
    sudo ip addr add "$ip/$cidr" broadcast "$broadcast_address" dev "$interface"
    
    echo "Setting default gateway to $gateway..."
    sudo ip route add default via "$gateway"
    
    echo "Configuring DNS server to $dns_server..."
    sudo resolvectl dns "$interface" "$dns_server"
    
    echo "Network settings applied successfully."
}

# Prompt the user for network settings
read -p "Enter the IP address with CIDR notation (e.g., 192.168.0.100/24): " ip_with_cidr
read -p "Enter the network interface (e.g., eth0): " interface

# Execute the function with user input
apply_network_settings "$interface" "$ip_with_cidr"

# Verify configuration
echo "Current network configuration for $interface:"
ip addr show dev "$interface"

echo "Current routing table:"
ip route show

echo "Script execution completed."
