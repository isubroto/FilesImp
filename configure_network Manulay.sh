#!/bin/bash

# Function to apply network settings
apply_network_settings() {
    local interface="$1"
    local ip_address="$2"
    local subnet_mask="$3"
    local broadcast_address="$4"
    local gateway="$5"
    local dns_server="$6"

    echo "Flushing existing IP configuration on $interface..."
    sudo ip addr flush dev "$interface"
    
    echo "Adding IP address $ip_address/$subnet_mask to $interface..."
    sudo ip addr add "$ip_address/$subnet_mask" broadcast "$broadcast_address" dev "$interface"
    
    echo "Setting default gateway to $gateway..."
    sudo ip route add default via "$gateway"
    
    echo "Configuring DNS server to $dns_server..."
    sudo resolvectl dns "$interface" "$dns_server"
    
    echo "Network settings applied successfully."
}

# Prompt the user for network settings
read -p "Enter the network interface (e.g., eth0): " interface
read -p "Enter the IP address (e.g., 192.168.0.10): " ip_address
read -p "Enter the subnet mask (e.g., 24): " subnet_mask
read -p "Enter the broadcast address (e.g., 192.168.0.255): " broadcast_address
read -p "Enter the default gateway (e.g., 192.168.0.1): " gateway
read -p "Enter the DNS server (e.g., 8.8.8.8): " dns_server

# Execute the function with user input
apply_network_settings "$interface" "$ip_address" "$subnet_mask" "$broadcast_address" "$gateway" "$dns_server"

# Verify configuration
echo "Current network configuration for $interface:"
ip addr show dev "$interface"

echo "Current routing table:"
ip route show

echo "Script execution completed."
