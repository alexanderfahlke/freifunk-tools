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
KEY_DIR=~/.ssh
KEY_FILENAME=freifunkfw

# do not edit anything below this line!
BUILD_DIR=$(mktemp -dt "ecdsahelper.XXXXXX")
PRIVATE_KEY_FILENAME=${KEY_DIR}/${KEY_FILENAME}.ecdsa
PUBLIC_KEY_FILENAME=${KEY_DIR}/${KEY_FILENAME}.ecdsa.pub

if [ -e ${PRIVATE_KEY_FILENAME} ] && [ -f ${PRIVATE_KEY_FILENAME} ]
then
  echo "Warning, the keyfile ${KEY_DIR}/${KEY_FILE_NAME}.ecdsa already exists"
  echo "Aborting!"
  exit 1
fi

# prerequisites for the build
sudo apt-get update
sudo apt-get install -y git pkg-config cmake
sudo apt-get install -y doxygen

# make and install libuecc
cd ${BUILD_DIR}
wget http://git.universe-factory.net/libuecc/snapshot/libuecc-4.tar
tar xvf libuecc-4.tar
cd libuecc-4
mkdir build
cd build
cmake ..
sudo make install

# make and install ecdsakeygen
cd ${BUILD_DIR}
git clone https://github.com/tcatm/ecdsautils.git
cd ecdsautils
mkdir build
cd build
cmake ..
sudo make install

# generate ecdsa keypair
ecdsakeygen -s > ${PRIVATE_KEY_FILENAME}
ecdsakeygen -p < ${PRIVATE_KEY_FILENAME} > ${PUBLIC_KEY_FILENAME}
chmod 400 ${PRIVATE_KEY_FILENAME} # owner can only read, writing intentionally disabled ;)
