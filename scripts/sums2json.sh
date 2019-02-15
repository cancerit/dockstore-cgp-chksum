#!/bin/bash

function usage {
  echo -e "\nUsage: sums2json.sh -i input_file [ -p PUT_URL ] [ -H header ]\n";
  echo " -i File : input file.";
  echo " -p URL : URL to send PUT request of checksum result to.";
  echo " -H String : header to include when sending the PUT request. Can be specified multiple times for headers.";
  echo " -j File : a json file to use as the chksum output, i.e. skip chksum generating step.";
  echo " -E cURL_exit_code : exit 1 if the last cURL command exits with the code. Can be specified multiple times for extra error codes.";
  echo " -A Flag : to suppress all curl exit codes - the tool will exit 0 regardless curl's exit status.";
}

# require at leaest 1 argument
if [ $# -eq 0 ];
then
  echo ""
  echo "Error: No arguments" >&2
  usage >&2
  exit 1
fi

SUPPRESS_ALL_CURL_EXITS=0

# processing the inputs
while getopts ":hi:j:p:H:E:A" opt; do
  case $opt in
    h ) usage
        exit 0 ;;
    i ) IN_FILE="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    j ) IN_JSON="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    p ) ENDPOINT_URL="$OPTARG" ;;
    H ) PUT_HEADERS+=(-H "$OPTARG") ;;
    E ) ACCEPTABLE_CURL_EXIT_CODES+=("$OPTARG") ;;
    A ) SUPPRESS_ALL_CURL_EXITS=1 ;;
    \? ) echo ""
        echo "Error: Unimplemented option: -$OPTARG" >&2
        usage >&2
        exit 1 ;;
    : ) echo ""
        echo "Error: Option -$OPTARG needs an argument." >&2
        usage >&2
        exit 1 ;;
    * ) usage >&2
        exit 1 ;;
  esac
done

# check mandatory options:
if [ "-$IN_FILE" == "-" ]; then echo "Error: missing mandatory parameter -i." >&2; exit 1; fi

if [ "-$ENDPOINT_URL" == "-" ] && [ ${#PUT_HEADERS[@]} != 0 ];
then
  echo "Error: -p (PUT URL) must be specified when -H is specified." >&2
  exit 1
fi

set -x

IN_FILE_BASE=$(basename ${IN_FILE})
JSON_OUT="${IN_FILE_BASE}.check_sums.json"

set -o pipefail
if [ -z "$IN_JSON" ]
then
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
else
  echo "Use file: $IN_JSON as chksum output, I'm not generating a new one!"
  cp $IN_JSON $JSON_OUT
fi

set +ue

if [ ! -z "$ENDPOINT_URL" ]; then
  # max connection time is 2mins, 3 mins in total to complete the request
  # add -f to fail on server errors.
  curl -H "Content-Type: application/json" "${PUT_HEADERS[@]}"  -X PUT -d @"$JSON_OUT" --connect-timeout 120 --max-time 180 -f "$ENDPOINT_URL" > ${IN_FILE_BASE}.server_response.txt
  exit_code=$?

  if [ $SUPPRESS_ALL_CURL_EXITS -eq 1 ]; then
    exit 0
  fi 

  IS_IN=0
  for code in ${ACCEPTABLE_CURL_EXIT_CODES[@]}; do
    if [ "$exit_code" -eq "$code" ]; then
      IS_IN=1
    fi
  done

  # if the exit code is in acceptable_curl_exit_codes, exit 0, otherwise exits with the code
  if [ $IS_IN -eq 0 ]; then
    exit $exit_code
  else
    exit 0
  fi
fi
