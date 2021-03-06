FROM alpine:3.6

MAINTAINER yx2@sanger.ac.uk

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="0.4.1" \
      description="tool to produce and post file checksum for dockstore.org"

USER root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH

RUN apk add --no-cache curl
RUN apk add --no-cache bash

RUN addgroup -S cgp && adduser -G cgp -S cgp
RUN mkdir -p $OPT/bin
COPY scripts/sums2json.sh $OPT/bin
RUN chmod 755 $OPT/bin/sums2json.sh

USER cgp
WORKDIR /home/cgp

CMD ["/bin/bash"]
