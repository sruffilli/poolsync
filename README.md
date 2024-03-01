# PoolSync Music/Podcast Sync Script

## Introduction

PoolSync is a Bash script developed to address the need for simplified music or podcast syncing with local storage devices, particularly headphones used in environments like swimming pools. While initially created to meet this specific requirement, PoolSync offers versatile functionality suitable for various syncing tasks involving audio files.

## Features

- Converts audio files to MP3 format using ffmpeg.
- Syncs converted MP3 files with the destination directory using rsync.
- Allows customization of source directory, destination directory, and converted directory.
- Option to delete everything at the destination directory before starting the sync process.
- Options to show ffmpeg and rsync output for debugging purposes.

## Prerequisites

- ffmpeg: Required for audio file conversion.
- rsync: Required for syncing files between directories.

## Usage

```
Usage: ./poolsync.sh -s <source_directory> -d <destination_directory> [-c <converted_directory>] [-r] [-f] [-o]

Options:
  -s <source_directory>: Specify the source directory containing audio files.
  -d <destination_directory>: Specify the destination directory (SD card) to sync with.
  -c <converted_directory>: Specify the directory to store converted MP3 files. If not provided, $HOME/.poolsync-cache will be used.
  -r: Delete everything at the destination directory before starting the sync process.
  -f: Show ffmpeg output.
  -o: Show rsync output.
```

## Example

```bash
./poolsync.sh -s /path/to/music -d /path/to/headphones -r
```

This command will sync the music files from `/path/to/music` to `/path/to/headphones`, deleting everything at the destination directory before starting the sync process.

## Notes

- Ensure that the source directory contains the audio files you want to sync.
- Make sure the destination directory points to the local storage of your headphones or SD card.
- The script will automatically create the converted directory if it does not exist.

## License

This script is licensed under the MIT License.
