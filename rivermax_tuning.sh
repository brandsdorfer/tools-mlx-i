#!/bin/bash

# Function to process each device
process_device() {
    local device_type=$1
    local pci_address=$2
    local net_interface=$3

    echo "Processing device: $device_type"
    echo "PCI Address: $pci_address"
    echo "Network Interface: $net_interface"

    # Check PCI-bus Bandwidth
    echo "Checking PCI-bus Bandwidth:"
    sudo lspci -vvv -s$pci_address | grep -E 'LnkCap:|LnkSta:'

    # Network-Interface Tuning
    echo "Performing Network-Interface Tuning:"
    
    # Disable pause frames
    echo "Disabling pause frames:"
    sudo ethtool -A $net_interface rx off tx off

    # Disable Reverse Packet Filtering
    echo "Disabling Reverse Packet Filtering:"
    echo 0 | sudo tee /proc/sys/net/ipv4/conf/$net_interface/rp_filter > /dev/null

    echo "------------------------------------"
}

# Run mst status and process the output
sudo mst status -v | while read -r line; do
    if [[ $line =~ ^([^ ]+)\([^)]+\)\ +(/dev/mst/[^ ]+)\ +([^ ]+)\ +([^ ]+)\ +(net-[^ ]+) ]]; then
        device_type="${BASH_REMATCH[1]}"
        pci_address="${BASH_REMATCH[3]}"
        net_interface="${BASH_REMATCH[5]}"
        process_device "$device_type" "$pci_address" "$net_interface"
    fi
done
