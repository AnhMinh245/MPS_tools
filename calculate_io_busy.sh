#!/bin/bash

# Check if the input folder is provided
if [ -z "$1" ]; then
  echo "Please provide the folder containing the state files."
  exit 1
fi

# Folder containing the state files
input_folder="$1"

# Variables to store the total IO Busy value and the number of lines
total_io_busy=0
count_io_busy=0

# Loop through each file in the folder
for file in "$input_folder"/*; do
  if [ -f "$file" ]; then
    echo "Processing file: $file"

    # Loop through each line in the file
    while IFS= read -r line; do
      # Check and process IO Busy states
      if [[ "$line" == *"IO Busy"* ]]; then
        echo "Found IO Busy state in file $file: $line"
        
        # Extract the percentage value of IO Busy from the line
        io_busy_percent=$(echo "$line" | grep -oP '(?<=IO Busy: )\d+(\.\d+)?')

        # Check if the percentage value exists
        if [ -n "$io_busy_percent" ]; then
          # Add the IO Busy value to the total and increment the count
          total_io_busy=$(echo "$total_io_busy + $io_busy_percent" | bc)
          count_io_busy=$((count_io_busy + 1))
        else
          echo "No percentage value found in line: $line"
        fi
      fi
    done < "$file"
  fi
done

# Calculate the average IO Busy value
if [ $count_io_busy -gt 0 ]; then
  avg_io_busy=$(echo "scale=2; $total_io_busy / $count_io_busy" | bc)
  echo "Average IO Busy value: $avg_io_busy%"
else
  echo "No IO Busy states found in folder $input_folder."
fi

echo "Finished processing all files in folder $input_folder."

