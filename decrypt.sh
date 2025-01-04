#!/bin/bash

filePath="./files"
encPath="./enc"
passFile="./pass"
fileListName="files.txt"
encryptedPassFile=
encryptedFileListName=

function error(){
	if [ "${?}" != "0" ]; then
		printf "Operation was unsuccessful.\nExiting."
		exit 1
	fi
}

# Function to display help message
print_help() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  -h, --help        Show this help message and exit."
  echo "  -d, --decrypted   Decrypted files path."
  echo "  -e, --encrypted   Encrypted files path."
  echo
  echo "Description:"
  echo "This script decrypts files in a folder"
  echo "Use -h or --help to display this help message."
}

# Argument read in
until [ -z "${1}" ]; do
    if [ "${1}" = "--decrypted" ] || [ "${1}" = "-d" ]; then
        shift
        filePath=$(basename ${1})
    elif [ "${1}" = "--encrypted" ] || [ "${1}" = "-e" ]; then
        shift
        encPath=$(basename ${1})
    elif [ "${1}" = "--help" ] || [ "${1}" = "-h" ]; then
        print_help
        exit 0
    fi
    shift
done

# Catch errors
if [ ! -d "${encPath}" ]; then
    printf "Encrypted folder %s does not exist\n" ${encPath} || error
    exit 1
fi

encryptedPassFile="${encPath}/pass.asc"
encryptedFileListName="${encPath}/files.asc"

# Decrypt password
gpg -d -o "${passFile}" "${encryptedPassFile}" || error

# Decrypt file list
gpg -d -o ${fileListName} --batch --passphrase-file ${passFile} ${encryptedFileListName} || error

# Decrypt files
if [ ! -d "${filePath}" ]; then
    printf "%s\n" "Decrypted path does not exist, creating..."
    mkdir ${filePath}
fi

while read line; do
    IFS=";" read -r col1 col2 col3 <<< "${line}"
    printf "Processing %s...\n" "${col2}"
    newfile=$(basename "${col2}")
    gpg -d -o "${filePath}/${newfile}" --batch --passphrase-file ${passFile} ${encPath}/${col1} || error
done < ${fileListName}

printf "%s\n" "Deleting temporary files"
rm $passFile $fileListName

exit 0