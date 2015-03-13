#!/usr/bin/env bash

# Copyright 2015 Alexander Fahlke
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# adjust the following two lines (if you need)
KEY_DIR="${HOME}/.freifunkkeystore" # final output directory for the keys
KEY_FILENAME='freifunkfw' # filename of the keys

# do not edit anything below this line!

# variables for the key file names
PRIVATE_KEY_FILENAME="${KEY_DIR}/${KEY_FILENAME}.ecdsa"
PUBLIC_KEY_FILENAME="${KEY_DIR}/${KEY_FILENAME}.ecdsa.pub"

# try to create the build temp directory
BUILD_TMP_DIR=$(mktemp -q -dt 'ecdsahelper')
if [ $? -ne 0 ]; then
	echo "$0: Can't create temp directory, exiting..."
	exit 1
fi

# exit if KEY_DIR is a file
if [ -e "${KEY_DIR}" ] && [ -f "${KEY_DIR}" ]; then
	echo "$0: The keystore ${KEY_DIR} is not a directory, exiting..."
	exit 2
fi

# create KEY_DIR if it does not exist
if [ ! -e "${KEY_DIR}" ] && [ ! -d "${KEY_DIR}" ]; then
	mkdir "${KEY_DIR}"
	echo '*' > "${KEY_DIR}/.gitignore" # add gitignore file to prevent adding the keys to a git repository ;)
fi

# exit if private key already exists
if [ -e "${PRIVATE_KEY_FILENAME}" ] && [ -f "${PRIVATE_KEY_FILENAME}" ]; then
	echo "$0: The private key ${KEY_DIR}/${KEY_FILE_NAME}.ecdsa already exists, exiting..."
	exit 3
fi

# prerequisites for the build
sudo apt-get update
sudo apt-get install -y git pkg-config cmake
sudo apt-get install -y doxygen

# make and install libuecc
cd "${BUILD_TMP_DIR}"
wget 'http://git.universe-factory.net/libuecc/snapshot/libuecc-4.tar'
tar xvf 'libuecc-4.tar'
cd 'libuecc-4'
mkdir 'build'
cd 'build'
cmake ..
sudo make install

# make and install ecdsakeygen
cd "${BUILD_TMP_DIR}"
git clone 'https://github.com/tcatm/ecdsautils.git'
cd 'ecdsautils'
mkdir 'build'
cd 'build'
cmake ..
sudo make install

# generate ecdsa keypair
ecdsakeygen -s > "${PRIVATE_KEY_FILENAME}"
ecdsakeygen -p < "${PRIVATE_KEY_FILENAME}" > "${PUBLIC_KEY_FILENAME}"
chmod 400 "${PRIVATE_KEY_FILENAME}" # writing intentionally disabled ;)

# clean up build directory
if [ -n "${BUILD_TMP_DIR}" ] && [ "${BUILD_TMP_DIR}" != "/" ]; then
	if [ -e "${BUILD_TMP_DIR}" ] && [ -d "${BUILD_TMP_DIR}" ]; then
		rm -rf "${BUILD_TMP_DIR}"
	fi
fi
