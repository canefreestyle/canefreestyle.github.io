#!/bin/bash

function clean_links {
    # Define the input and output file
    input_file="files/cane_links.txt"
    output_file="files/modified_links.txt"

    # Replace "https://www.youtube.com/watch?v=" with "https://youtu.be/"
    # Replace "&index=<VARIABLE STRING>" with "?"
    # Remove the string "&list=<VARIABLE STRING>"
    # Remove trailing "?" characters at the end of each line
    # Replace "&pp=<VARIABLE STRING>" with "?"
    # Replace "%3D" with ""
    sed -e 's|www\.||' \
        -e 's|?app=desktop&|?|g' \
        -e 's|https://youtube.com/shorts/|https://youtu.be/|g' \
        -e 's|https://youtube.com/watch?v=|https://youtu.be/|g' \
        -e 's|%3D||g' \
        -e 's|reel/|p/|g' \
        -e 's|&index=[^&]*|?|g' \
        -e 's|utm_source=[^&]*|?|g' \
        -e 's|&igshid=[^&]*|?|g' \
        -e 's|&igsh=[^&]*|?|g' \
        -e 's|?igsh=[^&]*|?|g' \
        -e 's|fbclid=[^&]*|?|g' \
        -e 's|&list=[^&]*||g' \
        -e 's|&web_id=[^&]*||g' \
        -e 's|&sender_device=[^&]*||g' \
        -e 's|\?list=[^&]*|?|g' \
        -e 's|\?is_from_webapp=[^&]*|?|g' \
        -e 's|&t=|\?t=|g' \
        -e 's|\??t=|\?t=|g' \
        -e 's|&pp=[^&]*|?|g' \
        -e 's|/$||' \
        -e 's|\/?|?|' \
        -e 's|\?$||' \
        -e 's|\?$||' \
        -e 's|\?$||' \
        -e 's|/$||' \
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
}

function count_cane_links {
  cane_links_file_path="files/cane_links.txt"
  
  # Count the number of rows in cane_links.txt
  count=$(wc -l < "$cane_links_file_path")

  # Format the count with commas
  formatted_count=$(printf "%'d" "$count")

  echo "Number of rows in cane_links.txt: $formatted_count"
}

function update_index_cane_link_count {
  index_paths=("index.html" "drew/index.html")

  for path in "${index_paths[@]}"; do
    # Replace "<!-- count -->" until the next space with "<!-- count -->formatted_count"
    sed -i "s/<!-- count -->[^ ]*/<!-- count -->$formatted_count/" "$path"
  done

  echo "Updated index.html with the formatted_count."
}

function confirm_yes_or_no {
    question="$1"
    answer=''

    # Set default to "no" if no input is provided
    if [[ -z "${answer}" ]]; then
        answer='no'
    fi

    while true; do
        echo "${question}"
        printf "(Type \"yes\" or \"no\") [no]: "
        read -r input
        answer=$(echo "${input}" | tr '[:upper:]' '[:lower:]')

        if [[ "${answer}" == "yes" ]]; then
            return 0
        fi
        
        if [[ "${answer}" == "no" \
           || -z "${answer}" ]]; then
            return 1
        fi
    done
}

function push_changes {
  if confirm_yes_or_no "  Git push changes?"; then
    git add -A
    git commit -m "$formatted_count links"
    git push

    echo "Changes pushed!"
  fi
}

# Call the functions
clean_links
count_cane_links
update_index_cane_link_count
push_changes
