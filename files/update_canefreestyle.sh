#!/bin/bash

function clean_links {
    # Get the directory of the current script
    LINKS_DIRECTORY="$(dirname "$(readlink -f "$0")")"

    # Set the input and output files
    local input_file="$LINKS_DIRECTORY/$1"
    local output_file="$LINKS_DIRECTORY/cleaned_$1"

    echo "${FUNCNAME}():"

    for file in "bad_links.txt" "private_links.txt" "cane_links.txt"; do
      local input_file="$LINKS_DIRECTORY/$file"
      local output_file="$LINKS_DIRECTORY/cleaned_$file"

      if [[ ! -f "$input_file" ]]; then
          echo "  Make sure $input_file is valid file with a list of URLs to clean"
          exit 1
      fi

      # Replace characters in the URLs to normalize the format 
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

      echo "  Cleaned $input_file"
    done

  echo " "
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


function count_cane_links {
  LINKS_DIRECTORY="$(dirname "$(readlink -f "$0")")"

  echo "${FUNCNAME}():"

  # Set the input and output files
  bad_links="$LINKS_DIRECTORY/bad_links.txt"
  cane_links="$LINKS_DIRECTORY/cane_links.txt"
  private_links="$LINKS_DIRECTORY/private_links.txt"

  # Check if the input files exist
  for file in "$bad_links" "$cane_links" "$private_links"; do
    if [[ ! -f "$file" ]]; then
      echo "  Specify a valid file with a list of URLs to clean: $file"
      exit 1
    fi
  done

  # Count the number of rows in each file
  bad_links_count=$(wc -l < "$bad_links")
  cane_links_count=$(wc -l < "$cane_links")
  private_links_count=$(wc -l < "$private_links")

  # Format the count with commas
  formatted_cane_links_count=$(printf "%'d" "$cane_links_count")

  total_links_count=$((bad_links_count + cane_links_count + private_links_count))

  formatted_total_links_count=$(printf "%'d" "$total_links_count")

  echo "  $bad_links_count bad links"
  echo "  $cane_links_count cane links"
  echo "  $private_links_count private links"
  echo "  Active cane links: $formatted_cane_links_count"
  echo "  Total links: $formatted_total_links_count"
  echo " "
}


function push_changes {
  if confirm_yes_or_no "  Git push changes?"; then
    git add -A
    git commit -m "$formatted_count links"
    git push

    echo "Changes pushed!"
  fi
}


function remove_cane_links {
  LINKS_DIRECTORY="$(dirname "$(readlink -f "$0")")"

  echo "${FUNCNAME}():"

  # Set the input and output files
  bad_links_file="$LINKS_DIRECTORY/bad_links.txt"
  private_links_file="$LINKS_DIRECTORY/private_links.txt"
  cane_links_file="$LINKS_DIRECTORY/cane_links.txt"

  # Check if input files exist
  for file in "$bad_links_file" "$private_links_file" "$cane_links_file"; do
    if [[ ! -f "$file" ]]; then
      echo "  Specify a valid file with a list of URLs: $file"
      exit 1
    fi
  done

  # Loop through bad_links.txt and private_links.txt
  for input_file in "$bad_links_file" "$private_links_file"; do
    while IFS= read -r url; do
      # Escape special characters in the URL for sed
      escaped_url=$(printf "%s\n" "$url" | sed 's/[\&/]/\\&/g')

      # Check if the URL is in cane_links.txt before removing
      if grep -q "$url" "$cane_links_file"; then
        sed -i "\|$escaped_url|d" "$cane_links_file"
        echo "  Removed $url from cane_links.txt"
      fi
    done < "$input_file"
  done
  echo " "
}


function update_link_counts {
  LINKS_DIRECTORY="$(dirname "$(readlink -f "$0")")"
  index_file="$LINKS_DIRECTORY/../index.html"
  drew_file="$LINKS_DIRECTORY/../drew/index.html"

  echo "${FUNCNAME}():"

  echo " index file: $index_file"
  echo " drew file: $drew_file"

  # Replace "<!-- count -->" until the next space with "<!-- count -->formatted_count"
  sed -i "s/<!-- count -->[^ ]*/<!-- count -->$formatted_cane_links_count/" "$index_file"
  sed -i "s/<!-- count -->[^ ]*/<!-- count -->$formatted_total_links_count/" "$drew_file"

  echo "  Updated index.html to $formatted_cane_links_count"
  echo "  Updated drew/index.html to $formatted_total_links_count"
  echo " "
}


# Call the functions
clean_links
remove_cane_links
count_cane_links
update_link_counts
push_changes
