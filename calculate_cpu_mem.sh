#!/bin/bash

# Check if the parent folder path is provided as an argument
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path_to_parent_folder>"
  exit 1
fi

# Assign the first argument to the parent_folder variable
parent_folder=$1

# Define subfolders for CPU and memory
cpu_folder="$parent_folder/oswtop"
memory_folder="$parent_folder/oswvmstat"

# Check if the CPU folder exists
if [[ ! -d "$cpu_folder" ]]; then
  echo "CPU folder ($cpu_folder) does not exist. Please try again."
  exit 1
fi

# Check if the memory folder exists
if [[ ! -d "$memory_folder" ]]; then
  echo "Memory folder ($memory_folder) does not exist. Please try again."
  exit 1
fi

# Initialize variables to store total idle value and file count for CPU
total_idle_all_files=0
file_count=0

# Iterate through all files in the CPU folder
for file in "$cpu_folder"/*; do
  # Check if it is a file
  if [[ -f "$file" ]]; then
    # Calculate the total idle value and the number of lines with idle value for each file
    total_idle=$(grep "CPU states" "$file" | awk '{idle += $3} END {print idle}')
    count=$(grep "CPU states" "$file" | wc -l)
    
    # If the file contains "CPU states"
    if [[ $count -gt 0 ]]; then
      # Calculate the average idle value for the current file
      average_idle=$(echo "$total_idle / $count" | bc -l)
      # Add the average idle value to the total idle value
      total_idle_all_files=$(echo "$total_idle_all_files + $average_idle" | bc -l)
      # Increment the file count
      file_count=$((file_count + 1))
    fi
  fi
done

# Check if no files contain "CPU states"
if [[ $file_count -eq 0 ]]; then
  echo "No files found containing 'CPU states' in CPU folder."
else
  # Calculate the average idle value for all files
  average_idle_all_files=$(echo "scale=2; $total_idle_all_files / $file_count" | bc -l)

  # Calculate the overall CPU Utilization
  cpu_utilization_all_files=$(echo "scale=2; 100.0 - $average_idle_all_files" | bc -l)

  # Display the CPU results
  echo "Average CPU states idle for all files: $average_idle_all_files%"
  echo "Average CPU Utilization for all files: $cpu_utilization_all_files%"
fi

# Prompt the user to enter the total physical memory in GB
read -p "Enter the total physical memory in GB: " total_memory_in_gb

# Initialize variables to store total memory free and file count for memory
total_memory_free_kb=0
line_count=0

# Iterate through all files in the memory folder
for file in "$memory_folder"/*; do
  # Check if it is a file
  if [[ -f "$file" ]]; then
    # Extract the memory free values and calculate the total
    memory_free=$(grep -E '^[ ]*[0-9]+[ ]+[0-9]+[ ]+[0-9]+' "$file" | awk '{sum += $5} END {print sum}')
    count=$(grep -E '^[ ]*[0-9]+[ ]+[0-9]+[ ]+[0-9]+' "$file" | wc -l)
    
    # If the file contains memory free values
    if [[ $count -gt 0 ]]; then
      # Add the total memory free value to the total
      total_memory_free_kb=$(echo "$total_memory_free_kb + $memory_free" | bc)
      # Increment the line count
      line_count=$(echo "$line_count + $count" | bc)
    fi
  fi
done

# Check if no files contain memory free values
if [[ $line_count -eq 0 ]]; then
  echo "No files found containing memory free values in memory folder."
else
  # Calculate the average memory free in KB and convert to GB
  average_memory_free_kb=$(echo "scale=2; $total_memory_free_kb / $line_count" | bc -l)
  average_memory_free_gb=$(echo "scale=2; $average_memory_free_kb / 1024 / 1024" | bc -l)

  # Calculate the average physical memory free as a percentage
  average_physical_memory_free=$(echo "scale=2; ($average_memory_free_gb / $total_memory_in_gb) * 100" | bc -l)

  # Display the memory results
  echo "Average Memory Free in GB: $average_memory_free_gb GB"
  echo "Average physical memory free: $average_physical_memory_free%"
fi

