#!/bin/bash

# Function to check file existence and print the result
check_file() {
  local folder=$1
  local file_path=$2
  local full_path="$folder/$file_path"
  
  if [[ -e "$full_path" ]]; then
    echo -e "$full_path\n"
    if [[ "$file_path" == "patch+pkg/pkg_info-l.out" ]]; then
      awk '/Name: entire/,/^$/' "$full_path"
    else
      cat "$full_path"
    fi
    echo -e "\n\e[32m________________________________________\e[0m\n"
  else
    echo -e "\e[31mFolder/File: $full_path not found!\e[0m\n"
  fi
}

# Main script starts here
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <folder_path>"
  exit 1
fi

folder=$1

# Define file paths to check
file_paths=(
  "fma/fmadm-faulty.out"
  "patch+pkg/pkg_info-l.out"
  "disks/zfs/zpool_list.out"
  "disks/zfs/zpool_status-V.out"
  "netinfo/dladm/dladm_show-link.out"
)

# Iterate through each file path and check
for file_path in "${file_paths[@]}"; do
  check_file "$folder" "$file_path"
done

