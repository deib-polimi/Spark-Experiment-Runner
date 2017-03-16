#!/bin/sh

## Copyright 2015-2017 Eugenio Gianniti
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

if [ $# -lt 2 ]; then
  echo "dataset.sh: too few input arguments" 1>&2
  exit 1
fi

isnumber() { test "$1" && printf '%d' "$1" > /dev/null 2>&1; }

if ! isnumber "$1"; then
  echo "dataset.sh: an integer is needed as SCALE" >&2
  exit 2
fi
SCALE=$(printf '%d' "$1")

SCRATCH_DIR="$2"

SOURCE="$0"
while [ -L "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [ "${SOURCE%${SOURCE#?}}" != / ] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

cd "${HOME}"
git clone https://github.com/hortonworks/hive-testbench.git
cp "${DIR}"/tpcds_kit.zip hive-testbench/tpcds-gen
cd hive-testbench
sudo apt-get -y install gcc make
./tpcds-build.sh
./tpcds-setup.sh "${SCALE}" "${SCRATCH_DIR}"
