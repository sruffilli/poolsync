# PoolSync Music/Podcast Sync Script

## Introduction

PoolSync is a Bash script developed to address the need for simplified music or podcast syncing with local storage devices - in my case dumb headphones with onboard storage.

## Features

- Converts any ffmpeg-supported audio files to MP3.
- Syncs converted MP3 files with the destination directory.
- Allows customization of source directory, destination directory, and converted directory.
- Allows creation of profiles to save configurations that can be easily recalled
- Option to delete everything at the destination directory before starting the sync process.
- Options to show ffmpeg and rsync output for debugging purposes.

## Prerequisites

- ffmpeg, rsync

## Usage

```txt
Usage: ./poolsync.sh -s <source_directory> -d <destination_directory> [-c <converted_directory>] [-r] [-f] [-o] [-p <profile_name>] [-l <profile_name>]
Options:
  -s <source_directory>: Specify the source directory containing audio files.
  -d <destination_directory>: Specify the destination directory (SD card) to sync with.
  -c <converted_directory>: Specify the directory to store converted MP3 files. If not provided, /home/ruffi/.poolsync-cache will be used.
  -r: Delete everything at the destination directory before starting the sync process.
  -f: Show ffmpeg output.
  -o: Show rsync output.
  -p <profile_name>: Save the current configuration as a profile with the given name.
  -l <profile_name>: Load a profile by name.
```

## Example

```bash
./poolsync.sh -s /path/to/music -d /path/to/headphones -r
```

This command will sync the music files from `/path/to/music` to `/path/to/headphones`, deleting everything at the destination directory before starting the sync process.

## Notes

This script is provided as-is and might very well decide to nuke your whole filesystem, drink milk from the carton or go to the bathroom without flushing.

## License

This script is licensed under the MIT License.
