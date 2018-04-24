#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "cgp-chksum"

label: "CGP file checksum generator"

cwlVersion: v1.0

doc: |
    ![build_status](https://quay.io/repository/wtsicgp/dockstore-cgp-chksum/status)
    A Docker container for producing file md5sum and sha512sum. See the [dockstore-cgp-chksum](https://github.com/cancerit/dockstore-cgp-chksum) website for more information.

dct:creator:
  "@id": "yaobo.xu@sanger.ac.uk"
  foaf:name: Yaobo Xu
  foaf:mbox: "yx2@sanger.ac.uk"

requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/wtsicgp/dockstore-cgp-chksum:0.2.0"

inputs:
  in_file:
    type: File
    doc: "file to have checksum generated from"
    inputBinding:
      position: 1
      prefix: -i
      separate: true
      shellQuote: true

  post_address:
    type: ["null", string]
    doc: "Optional POST address to send JSON results"
    inputBinding:
      position: 2
      prefix: -p
      separate: true
      shellQuote: true

  post_header:
    type: string[]?
    doc: "Optional POST address to send JSON results"
    inputBinding:
      position: 3
      prefix: -H
      separate: true
      shellQuote: true

outputs:
  chksum_json:
    type: File
    outputBinding:
      glob: $(inputs.in_file.basename).check_sums.json

  post_server_response:
    type: ["null", File]
    outputBinding:
      glob: $(inputs.in_file.basename).post_server_response.txt

baseCommand: ["/opt/wtsi-cgp/bin/sums2json.sh"]
