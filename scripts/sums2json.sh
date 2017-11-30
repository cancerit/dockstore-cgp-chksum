#! /bin/bash

# fail if used variable unset
set -u
IN_FILE=$1
JSON_OUT=$2

set -o pipefail
cat $IN_FILE | tee >(md5sum > md5.checksum) | sha512sum > sha2.checksum
exit_code=$?

# exit with error code of any command that fails from here
set -e 

if [ $exit_code -eq 0 ]
then
  md5=`cut -d ' ' -f1 md5.checksum`
  sha=`cut -d ' ' -f1 sha2.checksum` 
  echo -e "{\n\t\"status\":\"success\",\n\t\"md5sum\":\"$md5\",\n\t\"sha2sum\":\"$sha\"\n}" > $JSON_OUT
else
  echo -e "{\n\t\"status\":\"failed\"\n}" > $JSON_OUT
fi

rm -f md5.checksum sha2.checksum

set +u
POST_ADDRESS=$3

if [ ! -z "$POST_ADDRESS" ]
then
      curl -X POST -d @"$JSON_OUT" "$POST_ADDRESS"
fi

