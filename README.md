dockstore-cgp-chksum
======

`dockstore-cgp-chksum` generates md5sum and sh512sum of a file and optionally POST the result to a server. This has been packaged specifically for use with the [Dockstore.org](https://dockstore.org/) framework.

[![Docker Repository on Quay](https://quay.io/repository/wtsicgp/dockstore-cgp-chksum/status "Docker Repository on Quay")](https://quay.io/repository/wtsicgp/dockstore-cgp-chksum)

[![Build Status](https://travis-ci.org/cancerit/dockstore-cgp-chksum.svg?branch=master)](https://travis-ci.org/cancerit/dockstore-cgp-chksum) : master
[![Build Status](https://travis-ci.org/cancerit/dockstore-cgp-chksum.svg?branch=develop)](https://travis-ci.org/cancerit/dockstore-cgp-chksum) : develop

Inputs are:

1. A file from which md5sum and sha512sum are generated
2. An optional POST address to send the JSON file to
3. An optional list of headers to include in the POST request
4. An optional list of curl exit codes. If curl command exits with any of the code, the whole tool still exits 0.

Outputs are:

1. "${input_file_name}.check_sums.json" - A JSON file where checksums are stored
2. "${input_file_name}.post_server_response.txt" - A text file contains POST server response

LICENCE
=======

Copyright (c) 2017 Genome Research Ltd.

Author: Cancer Genome Project <cgpit@sanger.ac.uk>

This file is part of dockstore-cgp-chksum.

dockstore-cgp-chksum is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

1. The usage of a range of years within a copyright statement contained within
this distribution should be interpreted as being equivalent to a list of years
including the first and last year specified and all consecutive years between
them. For example, a copyright statement that reads ‘Copyright (c) 2005, 2007-
2009, 2011-2012’ should be interpreted as being identical to a statement that
reads ‘Copyright (c) 2005, 2007, 2008, 2009, 2011, 2012’ and a copyright
statement that reads ‘Copyright (c) 2005-2012’ should be interpreted as being
identical to a statement that reads ‘Copyright (c) 2005, 2006, 2007, 2008,
2009, 2010, 2011, 2012’."
