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

#######################################################
#        do not edit anything below this line!        #
#######################################################

# variables for the key file names and error handling
PRIVATE_KEY_FILENAME="${KEY_DIR}/${KEY_FILENAME}.ecdsa"
PUBLIC_KEY_FILENAME="${KEY_DIR}/${KEY_FILENAME}.ecdsa.pub"
EXIT_CODE=0

# exit if KEY_DIR is a file
EXIT_CODE=$((EXIT_CODE + 1))
if [ -e "${KEY_DIR}" ] && [ -f "${KEY_DIR}" ]; then
	echo "$0: The keystore \"${KEY_DIR}\" is not a directory, exiting..."
	exit ${EXIT_CODE}
fi

# exit if private key already exists
EXIT_CODE=$((EXIT_CODE + 1))
if [ -e "${PRIVATE_KEY_FILENAME}" ] && [ -f "${PRIVATE_KEY_FILENAME}" ]; then
	echo "$0: The private key \"${PRIVATE_KEY_FILENAME}\" already exists, exiting..."
	exit ${EXIT_CODE}
fi

# create KEY_DIR if it does not exist
EXIT_CODE=$((EXIT_CODE + 1))
if [ ! -e "${KEY_DIR}" ] && [ ! -d "${KEY_DIR}" ]; then
	mkdir "${KEY_DIR}"
	if [ $? -ne 0 ]; then
		echo "$0: Can't create key directory, exiting..."
		exit ${EXIT_CODE}
	fi

	echo '*' > "${KEY_DIR}/.gitignore" # add gitignore file to prevent adding the keys to a git repository ;)
fi

# check if apt-get is available
EXIT_CODE=$((EXIT_CODE + 1))
which 'apt-get' > /dev/null
if [ $? -ne 0 ]; then
	echo "$0: \"apt-get\" not found, exiting..."
	exit ${EXIT_CODE}
fi

# get the newest updates
sudo apt-get update 2> /dev/null
if [ $? -ne 0 ]; then
	echo "$0: \"apt-get update\" failed."
fi

# install git if not present
EXIT_CODE=$((EXIT_CODE + 1))
which 'git' > /dev/null
if [ $? -ne 0 ]; then
	sudo apt-get install -y 'git' 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "$0: \"git\" not installed, exiting..."
		exit ${EXIT_CODE}
	fi
fi

# install pkg-config if not present
EXIT_CODE=$((EXIT_CODE + 1))
which 'pkg-config' > /dev/null
if [ $? -ne 0 ]; then
	sudo apt-get install -y 'pkg-config' 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "$0: \"pkg-config\" not installed, exiting..."
		exit ${EXIT_CODE}
	fi
fi

# install cmake if not present
EXIT_CODE=$((EXIT_CODE + 1))
which 'cmake' > /dev/null
if [ $? -ne 0 ]; then
	sudo apt-get install -y 'cmake' 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "$0: \"cmake\" not installed, exiting..."
		exit ${EXIT_CODE}
	fi
fi

# install doxygen if not present
EXIT_CODE=$((EXIT_CODE + 1))
which 'doxygen' > /dev/null
if [ $? -ne 0 ]; then
	sudo apt-get install -y 'doxygen' 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "$0: \"doxygen\" not installed, exiting..."
		exit ${EXIT_CODE}
	fi
fi

# try to create the build temp directory
EXIT_CODE=$((EXIT_CODE + 1))
BUILD_TMP_DIR=$(mktemp -dt 'ecdsahelper.XXXXXX')
if [ $? -ne 0 ]; then
	echo "$0: Can't create temp directory, exiting..."
	exit ${EXIT_CODE}
fi

# make and install libuecc
EXIT_CODE=$((EXIT_CODE + 1))
cd "${BUILD_TMP_DIR}"
wget --quiet 'http://git.universe-factory.net/libuecc/snapshot/libuecc-4.tar'
if [ $? -ne 0 ]; then
	echo "$0: download of \"libuecc-4.tar\" failed, exiting..."
	exit ${EXIT_CODE}
fi

EXIT_CODE=$((EXIT_CODE + 1))
tar xvf 'libuecc-4.tar'
if [ $? -ne 0 ]; then
	echo "$0: extracting of \"libuecc-4.tar\" failed, exiting..."
	exit ${EXIT_CODE}
fi

EXIT_CODE=$((EXIT_CODE + 1))
cd "${BUILD_TMP_DIR}"
mkdir 'libuecc-4/build'
cd 'libuecc-4/build'
cmake ..
if [ $? -ne 0 ]; then
	echo "$0: cmake of \"libuecc-4\" failed, exiting..."
	exit ${EXIT_CODE}
fi

EXIT_CODE=$((EXIT_CODE + 1))
sudo make install
if [ $? -ne 0 ]; then
	echo "$0: installation of \"libuecc-4\" failed, exiting..."
	exit ${EXIT_CODE}
fi

# make and install ecdsautils
EXIT_CODE=$((EXIT_CODE + 1))
cd "${BUILD_TMP_DIR}"
git clone 'https://github.com/tcatm/ecdsautils.git'
cd 'ecdsautils'
mkdir 'build'
cd 'build'
cmake ..
sudo make install
if [ $? -ne 0 ]; then
	echo "$0: make install of \"ecdsautils\" failed, exiting..."
	exit ${EXIT_CODE}
fi

# generate ecdsa keypair
EXIT_CODE=$((EXIT_CODE + 1))
ecdsakeygen -s > "${PRIVATE_KEY_FILENAME}"
if [ $? -ne 0 ]; then
	echo "$0: Could not generate ecdsa private key, exiting..."
	exit ${EXIT_CODE}
fi
ecdsakeygen -p < "${PRIVATE_KEY_FILENAME}" > "${PUBLIC_KEY_FILENAME}"
chmod 400 "${PRIVATE_KEY_FILENAME}" # writing intentionally disabled ;)
echo -e "\n\n$0: Keys successfully created in \"${KEY_DIR}\"."

# clean up build directory
if [ -n "${BUILD_TMP_DIR}" ] && [ "${BUILD_TMP_DIR}" != "/" ]; then
	if [ -e "${BUILD_TMP_DIR}" ] && [ -d "${BUILD_TMP_DIR}" ]; then
		rm -rf "${BUILD_TMP_DIR}"
	fi
fi
