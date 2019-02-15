# CHANGES

## 0.4.1

* added `-j` option to take a file as chksum output JSON file, so that this tool will not generate a new one, i.e. the tool will skip chksum generating step.

## 0.4.0

* the tool is now changed to use `PUT` method other than `POST`, and a default header `"Content-Type: application/json"` is added when put the result to an endpoint.
* added `set -x` in the script to print commands being executed;
* added `-A` option to suppress all curl exit status.

## 0.3.0

* allow user to provide list of curl exit codes, so that if curl exits with any of those codes, the tool still exits 0.

## 0.2.0

* allow user to provide list of headers to include in the POST request

## 0.1.2

* changed output file names to be input_file_name plus suffixes

## 0.1.1

* corrected texts in LICENSE part of README
