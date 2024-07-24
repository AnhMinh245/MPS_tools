#!/bin/bash

# Check if the folder path is provided as an argument
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path_to_folder>"
  exit 1
fi

# Assign the first argument to the folder variable
folder=$1

# Check if the folder exists
if [[ ! -d "$folder" ]]; then
  echo "Folder does not exist. Please try again."
  exit 1
fi

# Initialize variables to store total idle value and file count
total_idle_all_files=0
file_count=0

# Iterate through all files in the folder
for file in "$folder"/*; do
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
  echo "No files found containing 'CPU states'."
  exit 1
fi

# Calculate the average idle value for all files
average_idle_all_files=$(echo "scale=2; $total_idle_all_files / $file_count" | bc -l)

# Calculate the overall CPU Utilization
cpu_utilization_all_files=$(echo "scale=2; 100.0 - $average_idle_all_files" | bc -l)

# Display the results
echo "Average CPU states idle for all files: $average_idle_all_files%"
echo "Average CPU Utilization for all files: $cpu_utilization_all_files%"
#!/bin/bash
