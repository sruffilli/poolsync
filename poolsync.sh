#!/bin/bash

# Default directories
source_dir=""
converted_dir="$HOME/.poolsync-cache"
destination_dir=""
delete_destination=false
show_ffmpeg_output=false
show_rsync_output=false
profile_name=""

# Function to display usage information
usage() {
  echo "Usage: $0 -s <source_directory> -d <destination_directory> [-c <converted_directory>] [-r] [-f] [-o] [-p <profile_name>] [-l <profile_name>]"
  echo "Options:"
  echo "  -s <source_directory>: Specify the source directory containing audio files."
  echo "  -d <destination_directory>: Specify the destination directory (SD card) to sync with."
  echo "  -c <converted_directory>: Specify the directory to store converted MP3 files. If not provided, $HOME/.poolsync-cache will be used."
  echo "  -r: Delete everything at the destination directory before starting the sync process."
  echo "  -f: Show ffmpeg output."
  echo "  -o: Show rsync output."
  echo "  -p <profile_name>: Save the current configuration as a profile with the given name."
  echo "  -l <profile_name>: Load a profile by name."
  exit 1
}

# Function to convert audio files to MP3
convert_to_mp3() {
  local file="$1"
  local filename=$(basename "$file")
  local mp3_filename="${filename%.*}.mp3"
  local extension="${filename##*.}"

  if [ -f "$converted_dir/$mp3_filename" ]; then
    echo "File already exists on cache, skipping: $file"
    return
  fi

  if [ "$extension" == "mp3" ]; then
    echo "File is already in mp3 format, skipping conversion: $file"
    cp "$file" "$converted_dir/$mp3_filename"
    return
  fi

  if "$show_ffmpeg_output"; then
    ffmpeg -i "$file" -codec:a libmp3lame -qscale:a 2 "$converted_dir/$mp3_filename" 2>&1 | while IFS= read -r line; do
      echo -ne "\r$line"
    done
  else
    ffmpeg -i "$file" -codec:a libmp3lame -qscale:a 2 "$converted_dir/$mp3_filename" &>/dev/null
  fi

}

# Function to process audio files in the source directory and its subdirectories
process_files() {
  shopt -s globstar
  local files=("$source_dir"/**/*.*) # Traverse all subdirectories
  shopt -u globstar
  if [ ${#files[@]} -eq 0 ]; then
    echo "No audio files found in $source_dir"
    exit 1
  fi
  local total_files=${#files[@]}
  local count=0
  for file in "${files[@]}"; do
    echo "Converting $file"
    convert_to_mp3 "$file"
  done
  echo -ne "\n"
}

# Function to sync converted MP3 files with the destination directory
sync_with_destination() {
  if "$delete_destination"; then
    rm -rf "$destination_dir"/*
  fi
  if "$show_rsync_output"; then
    rsync -av --progress --checksum "$converted_dir/" "$destination_dir/"
  else
    rsync -av --progress --checksum "$converted_dir/" "$destination_dir/" &>/dev/null
  fi
}

# Function to save the current configuration as a profile
save_profile() {
  local profile_dir="$HOME/.poolsync"
  if [ ! -d "$profile_dir" ]; then
    mkdir -p "$profile_dir"
  fi
  if [ -z "$profile_name" ]; then
    echo "Profile name is required."
    exit 1
  fi
  local profile_file="$profile_dir/$profile_name"
  echo "source_dir=$source_dir" >"$profile_file"
  echo "destination_dir=$destination_dir" >>"$profile_file"
  echo "converted_dir=$converted_dir" >>"$profile_file"
  echo "delete_destination=$delete_destination" >>"$profile_file"
  echo "show_ffmpeg_output=$show_ffmpeg_output" >>"$profile_file"
  echo "show_rsync_output=$show_rsync_output" >>"$profile_file"
  echo "Profile saved: $profile_name"
}

# Function to load a profile
load_profile() {
  local profile_dir="$HOME/.poolsync"
  local profile_file="$profile_dir/$profile_name"
  if [ ! -f "$profile_file" ]; then
    echo "Profile not found: $profile_name"
    exit 1
  fi
  source "$profile_file"
}

# Function to list all saved profiles
list_profiles() {
  local profile_dir="$HOME/.poolsync"
  if [ ! -d "$profile_dir" ] || [ -z "$(ls -A $profile_dir)" ]; then
    echo "No profiles saved."
  else
    echo "Saved profiles:"
    ls "$profile_dir"
  fi
}

# Parse command-line options
while getopts ":s:d:c:rfop:l:ih" opt; do
  case $opt in
  s)
    source_dir="$OPTARG"
    ;;
  d)
    destination_dir="$OPTARG"
    ;;
  c)
    converted_dir="$OPTARG"
    ;;
  r)
    delete_destination=true
    ;;
  f)
    show_ffmpeg_output=true
    ;;
  o)
    show_rsync_output=true
    ;;
  p)
    profile_name="$OPTARG"
    save_profile
    exit 0
    ;;
  l)
    profile_name="$OPTARG"
    load_profile
    ;;
  i)
    list_profiles
    exit 0
    ;;
  h)
    usage
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    usage
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    usage
    ;;
  esac
done

# Check required options
if [ -z "$source_dir" ] || [ -z "$destination_dir" ]; then
  echo "Source and destination directories are required."
  usage
fi

# If converted directory is not specified, create and use the default directory
if [ ! -d "$converted_dir" ]; then
  mkdir -p "$converted_dir"
fi

# Main function
main() {
  echo "Converting audio files to MP3..."
  process_files
  echo "Conversion completed."

  echo "Syncing with destination directory..."
  sync_with_destination
  echo "Sync completed."
}

# Run the main function
main
