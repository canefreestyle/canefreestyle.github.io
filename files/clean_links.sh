#!/bin/bash

# Define the input and output file
input_file="cane_links.txt"
output_file="modified_links.txt"

# Replace "https://www.youtube.com/watch?v=" with "https://youtu.be/"
# Replace "&index=<VARIABLE STRING>" with "?"
# Remove the string "&list=<VARIABLE STRING>"
# Remove trailing "?" characters at the end of each line
# Replace "&pp=<VARIABLE STRING>" with "?"
# Replace "%3D" with ""
sed -e 's|www\.||' \
    -e 's|https://youtube.com/shorts/|https://youtu.be/|g' \
    -e 's|https://youtube.com/watch?v=|https://youtu.be/|g' \
    -e 's|%3D||g' \
    -e 's|reel/|p/|g' \
    -e 's|&index=[^&]*|?|g' \
    -e 's|utm_source=[^&]*|?|g' \
    -e 's|&igshid=[^&]*|?|g' \
    -e 's|&list=[^&]*||g' \
    -e 's|\?list=[^&]*|?|g' \
    -e 's|&t=|\?t=|g' \
    -e 's|\??t=|\?t=|g' \
    -e 's|\?$||' \
    -e 's|&pp=[^&]*|?|g' \
    -e 's/[[:space:]]*$//' "$input_file" > "$output_file"

# Remove trailing blank lines from the output file
sed -i '/^$/d' "$output_file"

# Sort the file alphabetically
sort -o "$output_file" "$output_file"

# Remove duplicate lines
uniq "$output_file" > "sorted_and_unique_links.txt"

# Rename the final file to the original name (optional)
mv "sorted_and_unique_links.txt" "$input_file"

# Remove the intermediate modified file
rm "$output_file"

# # Use awk to remove duplicates and perform other modifications
# awk -F'[?&]' '{gsub("https://www.youtube.com/watch?v=", "https://youtu.be/", $1); gsub(/%3D|reel\//, "", $1); gsub("www.", "", $1); gsub(/&index=[^&]*/, "?", $2); gsub(/&list=[^&]*/, "", $2); gsub(/\?list=[^&]*/, "?", $2); gsub(/&t=|\??t=/, "?t=", $2); gsub(/\?$/, "", $2); gsub(/&pp=[^&]*/, "?", $2); $1=$1; print $1 "?" $2}' "$input_file" | sort -u > "$output_file"

echo "Modifications complete."