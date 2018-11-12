#!/bin/bash

function usage {
  echo -e "\nUsage: sums2json.sh -i input_file [ -p POST_URL ] [ -H header ]\n";
  echo " -i File : input file.";
  echo " -p URL : URL to send POST request of checksum result to.";
  echo " -H String : header to include when sending the POST request. Can be specified multiple times for headers.";
  echo " -E cURL_exit_code : exit 1 if the last cURL command exits with the code. Can be specified multiple times for extra error codes.";
}

# require at leaest 1 argument
if [ $# -eq 0 ];
then
  echo ""
  echo "Error: No arguments" >&2
  usage >&2
  exit 1
fi

# processing the inputs
while getopts ":hi:p:H:E:" opt; do
  case $opt in
    h ) usage
        exit 0 ;;
    i ) IN_FILE="$OPTARG"
        if [ ! -f "$OPTARG" ]; then echo -e "\nError: $OPTARG does not exist" >&2; exit 1; fi ;;
    p ) POST_ADDRESS="$OPTARG" ;;
    H ) POST_HEADERS+=(-H "$OPTARG") ;;
    E ) ACCEPTABLE_CURL_EXIT_CODES+=("$OPTARG") ;;
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

if [ "-$POST_ADDRESS" == "-" ] && [ ${#POST_HEADERS[@]} != 0 ];
then
  echo "Error: -p (POST URL) must be specified when -H is specified." >&2
  exit 1
fi

IN_FILE_BASE=$(basename ${IN_FILE})
JSON_OUT="${IN_FILE_BASE}.check_sums.json"

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

set +ue

if [ ! -z "$POST_ADDRESS" ]; then
  # max connection time is 2mins, 3 mins in total to complete the request
  # add -f to fail on server errors.
  curl -X POST "${POST_HEADERS[@]}" -d @"$JSON_OUT" --connect-timeout 120 --max-time 180 -f "$POST_ADDRESS" > ${IN_FILE_BASE}.post_server_response.txt
  exit_code=$?

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
