#!/bin/bash

set -eo pipefail

# Get all necessary fields from dmidecode
output=$(sudo dmidecode -t system)
manufacturer=$(echo "$output" | awk -F: '/Manufacturer:/ {print $2; exit}' | xargs)
product_name=$(echo "$output" | awk -F: '/Product Name:/ {print $2; exit}' | xargs)
uuid=$(echo "$output" | awk -F: '/UUID:/ {print $2; exit}' | xargs | tr '[:upper:]' '[:lower:]' | sed 's/\-//g')
sku=$(echo "$output" | awk -F: '/SKU Number:/ {print $2; exit}' | xargs)
family=$(echo "$output" | awk -F: '/Family:/ {print $2; exit}' | xargs)

# Function to pad strings with null bytes
pad_string() {
    local string="$1"
    local length="$2"
    local padded_string
    padded_string=$(printf "%-${length}s" "$string")
    echo -n "$padded_string"
}

# Create the smbios.bin file
{
    pad_string "$manufacturer" 32 | dd conv=notrunc bs=1 count=32
    pad_string "$product_name" 32 | dd conv=notrunc bs=1 count=32
    pad_string "$uuid" 16 | dd conv=notrunc bs=1 count=16
    pad_string "$sku" 32 | dd conv=notrunc bs=1 count=32
    pad_string "$family" 32 | dd conv=notrunc bs=1 count=32
} > smbios.bin

cat /sys/firmware/acpi/tables/MSDM > MSDM.bin
