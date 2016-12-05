## Copyright 2016 Giorgio Pea <giorgio.pea@mail.polimi.it>
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

source ./config.sh
LENGTH=${#ALLOWEDIDS[@]}
ALL_QUERIES=0
REPETITIONS_N=1
APP_ID=""

function isNumber {
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
     echo "Error: Scale factor in config file or Repetition factor is not an integer number" >&2; exit 1
  fi
}
function checkargs {
  RESULT=0
  for i in "${ALLOWEDIDS[@]}"
  do
    if [ $i = $1 ]
    then
      RESULT=1
    fi
  done
  if [ $RESULT -eq 0 ]
  then
    echo "The inserted query id does not match with any existing one"
    exit -1;
  fi
  if [ $1 = "-A" ]
  then
    ALL_QUERIES=1
  else
    if ! [ -z $2 ]
    then
      isNumber $2
      REPETITIONS_N=$2
    fi
  fi
}
function executeQuery {
  if [ -f ./tmp.py ]
  then
      rm tmp.py
  fi
  touch tmp.py
  cat ./queryPreamble.py >> tmp.py
  cat ./queries/query$1.py >> tmp.py
  APP_ID=$(${PYSPARK}/pyspark tmp.py | grep -m1 "/application_([0-9])+_([0-9])+/")
  echo ${APP_ID}
  echo "EXECUTION FINISHED"
  echo "DOWNLOADING LOGS"
  ./logDownload.sh APP_ID
  echo "DOWNLOAD COMPLETED"
}
if [ $# -eq 0 ]
then
  echo "Error: usage is [QUERY_ID | -A FOR EXECUTE ALL] ?[N_TIMES]"
  exit -1;
fi
if [ $# -gt 2 ]
then
  echo "Warning: only one argument is supported, the others will be ignored"
fi
checkargs $1 $2
if [ $ALL_QUERIES -eq 1 ]
then
  for i in $(seq 0 $(expr $LENGTH - 2))
  do
    echo "EXECUTING QUERY ${ALLOWEDIDS[$i]}"
    executeQuery ${ALLOWEDIDS[$i]}
  done
else
  for j in $(seq 1 ${REPETITIONS_N})
  do
    echo "EXECUTING QUERY $1, REPETITION $j"
    executeQuery $1
  done
fi
