# Copyright (c) 2019, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.
################# Multistage Build, stage 1 ###################################
FROM ubuntu:bionic
LABEL maintainer="Nimbix, Inc." \
      license="BSD"

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20191217.1200}

ARG OPENSCAD_VER=2019.05

# Download source and compile
RUN apt-get -y update && \
    apt-get -y install curl && \
    curl https://files.openscad.org/openscad-$OPENSCAD_VER.src.tar.gz | tar xz && \
    cd openscad-$OPENSCAD_VER && \
    ./scripts/uni-get-dependencies.sh && \
    ./scripts/check-dependencies.sh && \
    qmake openscad.pro && \
    make && \
    make install


################# Multistage Build, stage 2 ###################################

FROM ubuntu:bionic

COPY --from=0 /usr/local/bin/openscad /usr/local/bin/openscad
COPY --from=0 /usr/local/share/openscad /usr/local/share/openscad
COPY --from=0 /usr/local/share/openscad /usr/local/share/openscad
COPY --from=0 /usr/local/share/mime/packages/openscad.xml /usr/local/share/mime/packages/openscad.xml
COPY --from=0 /usr/local/share/metainfo/org.openscad.OpenSCAD.appdata.xml /usr/local/share/metainfo/org.openscad.OpenSCAD.appdata.xml
COPY --from=0 /usr/local/share/pixmaps/openscad.png /usr/local/share/pixmaps/openscad.png
COPY --from=0 /usr/local/share/man/man1/openscad.1 /usr/local/share/man/man1/openscad.1

RUN apt-get -y update && \
    apt-get -y install curl && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
        | bash -s -- --setup-nimbix-desktop

#RUN apt-get update && apt-get install -y software-properties-common python-software-properties
#RUN add-apt-repository ppa:openscad/releases
#RUN apt-get update && apt-get install -y openscad
#
#RUN apt-get clean && rm -rf /var/lib/apt/*

COPY NAE/AppDef.json /etc/NAE/AppDef.json
COPY NAE/screenshot.png /etc/NAE/screenshot.png
