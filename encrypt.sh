#!/bin/bash

tempDir="/tmp/cloudcrypt"
filePath="${tempDir}/files"
encPath="./enc"
passFile="${tempDir}/pass"
encFileName=
fileListName="${tempDir}/files.txt"
keyID=
encryptSym=0

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
  echo "  -s, --add-symmetric   Add symmetrically encrypte pass file."
  echo
  echo "Description:"
  echo "This script encrypts files in a folder"
  echo "Use -h or --help to display this help message."
}
    
# Argument read in
until [ -z "${1}" ]; do
    if [ "${1}" = "--decrypted" ] || [ "${1}" = "-d" ]; then
        shift
        filePath="${1}"
    elif [ "${1}" = "--encrypted" ] || [ "${1}" = "-e" ]; then
        shift
        encPath="${1}"
    elif [ "${1}" = "--add-symmetric" ] || [ "${1}" = "-s" ]; then
        encryptSym=1
        shift
    elif [ "${1}" = "--help" ] || [ "${1}" = "-h" ]; then
        print_help
        exit 0
    fi
    shift
done

# Catch errors
if [ ! -f "$(dirname $0)/keyid" ]; then
    printf "Key-ID file does not exist\n"
    exit 1
fi
if [ ! -d "${filePath}" ]; then
    printf "Decrypted folder %s does not exist\n" ${filePath}
    exit 1
fi

# Create tempfile dir
if [ ! -d "${tempDir}" ]; then
    printf "%s\n" "Tempfile path does not exist, creating..."
    mkdir -p ${tempDir}
fi

# Assign encryption key id
keyID=$(cat $(dirname $0)/keyid)

# Generate password
printf "%s\n" "Generating password..."
openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 32 > ${passFile} || error

# Create encrypted dir
if [ ! -d "${encPath}" ]; then
    printf "%s\n" "Encrypted path does not exist, creating..."
    mkdir ${encPath}
fi

# Encrypt password
printf "%s\n" "Encrypting password..."
gpg -ea -r ${keyID} -o ${encPath}/pass.asc --throw-keyids ${passFile} || error

if [ "${encryptSym}" = "1" ]; then
    printf "%s\n" "Encrypting password symmetrically..."
    gpg -ca -o ${encPath}/sympass.asc ${passFile} || error
fi
# Encrypt files
if [ ! -d "${encPath}" ]; then
    printf "%s\n" "Encrypted path does not exist, creating..."
    mkdir ${encPath}
fi

for file in ${filePath}/*; do
    printf "Processing %s...\n" "${file}"

    #printf "%s\n" "Generating encrypted filename"
    encFileName="$(openssl rand -base64 12 | tr -dc 'A-Za-z0-9' | head -c 32).gpg" || error
    
    #printf "%s\n" "Encrypting file..."
    gpg -c -o ${encPath}/${encFileName} --batch --passphrase-file ${passFile} "${file}" || error

    #printf "%s\n" "Adding file to list..."
    printf "%s;%s;%s\n" "${encFileName}" "$(basename "${file}")" "$(md5sum "${file}" | awk '{ print $1 }')" >> ${fileListName} || error
done

# Encrypt fileListName
printf "%s\n" "Encrypting fileListName..."
gpg -ca -o ${encPath}/files.asc --batch --passphrase-file "${passFile}" ${fileListName} || error

printf "%s\n" "Deleting temporary files"
rm ${passFile} ${fileListName}

exit 0

