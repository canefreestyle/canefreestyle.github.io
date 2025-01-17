#!/bin/bash

function get_links_files {
    echo "${FUNCNAME}():"

    # Get the path to the links directory at the same level as the parent directory 
    LINKS_DIRECTORY="$(dirname "$(dirname "$(readlink -f "$0")")")/links"

    # Create an empty array
    LINKS_FILES=()

    # Iterate over files in the directory
    for text_file in "$LINKS_DIRECTORY"/*.txt; do
        # Check if the file exists and is a regular file
        if [ -f "$text_file" ]; then
            # Add the file to the array
            LINKS_FILES+=("$text_file")

            echo "  $text_file"
        fi
    done

   # echo "${LINKS_FILES[@]}"
}


function clean_links {
    echo "${FUNCNAME}():"

    # Loop through the links files that need to be cleaned
    for file in "${LINKS_FILES[@]}"; do

      local input_file=$file
      local output_file="$(mktemp /tmp/$(basename "$file").XXXXXX)"

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

      echo "  Cleaned $(basename $input_file)"
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
  echo "${FUNCNAME}():"

  # Check if the input files exist
  for file in "${LINKS_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "  Specify a valid file with a list of URLs to clean: $file"
      exit 1
    fi

    # Sum the total number of in all the links files
    total_links_count=$((total_links_count + $(wc -l < "$file")))
  done

  # Count the number of rows in the cane links file
  cane_links_count=$(wc -l < "/media/drew/ark/code/canefreestyle/links/cane_links.txt")

  # Format the count with commas
  formatted_cane_links_count=$(printf "%'d" "$cane_links_count")
  formatted_total_links_count=$(printf "%'d" "$total_links_count")

  echo "  $formatted_cane_links_count cane links"
  echo "  $formatted_total_links_count total links"
  echo " "
}

function open_canefreestyle_files {
  if ! command -v code > /dev/null 2>&1; then
    echo "  Install VScode"
    exit 1
  fi

  if confirm_yes_or_no "  Open canefreestyle files in VSCode?Git push changes?"; then
     code --reuse-window $LINKS_DIRECTORY/*.txt
  fi
}

function push_changes {
  if confirm_yes_or_no "  Git push changes?"; then
    git add -A
    git commit -m "$formatted_total_links_count links"
    git push

    echo "Changes pushed!"
  fi
}


function remove_cane_links {
  echo "${FUNCNAME}():"

  cane_links_file="$1"

  # Set the files containing URLs that should be removed
  bad_links_file="$LINKS_DIRECTORY/bad_links.txt"
  private_links_file="$LINKS_DIRECTORY/private_links.txt"
  cane_links_file="$LINKS_DIRECTORY/$cane_links_file"

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
        echo "  Removed $url from $cane_links_file"
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
get_links_files
open_canefreestyle_files
clean_links 
remove_cane_links cane_links.txt
remove_cane_links drew_links.txt
count_cane_links
update_link_counts
push_changes
