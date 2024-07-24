#!/bin/bash

# Prompt the user to enter the path to the folder
read -p "Enter the path to the folder: " folder

# Check if the folder exists
if [[ ! -d "$folder" ]]; then
  echo "Folder does not exist. Please try again."
  exit 1
fi

# Prompt the user to enter the total physical memory in GB
read -p "Enter the total physical memory in GB: " total_memory_in_gb

# Initialize variables to store total memory free and file count
total_memory_free_kb=0
line_count=0

# Iterate through all files in the folder
for file in "$folder"/*; do
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
  echo "No files found containing memory free values."
  exit 1
fi

# Calculate the average memory free in KB and convert to GB
average_memory_free_kb=$(echo "scale=2; $total_memory_free_kb / $line_count" | bc -l)
average_memory_free_gb=$(echo "scale=2; $average_memory_free_kb / 1024 / 1024" | bc -l)

# Calculate the average physical memory free as a percentage
average_physical_memory_free=$(echo "scale=2; ($average_memory_free_gb / $total_memory_in_gb) * 100" | bc -l)

# Display the results
echo "Average Memory Free in GB: $average_memory_free_gb GB"
echo "Average physical memory free: $average_physical_memory_free%"
