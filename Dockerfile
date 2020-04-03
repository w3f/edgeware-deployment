FROM phusion/baseimage:0.11 AS builder
LABEL maintainer="jake@commonwealth.im"
LABEL description="This is the build stage. Here we create the binary."

ARG PROFILE=release
WORKDIR /edgeware

RUN apt-get update && \
  apt-get install -y --no-install-recommends git && \
  git clone https://github.com/hicommonwealth/edgeware-node.git . && \
  ./setup.sh

# ===== SECOND STAGE ======

FROM phusion/baseimage:0.11
LABEL maintainer="hello@commonwealth.im"
LABEL description="This is the 2nd stage: a very small image where we copy the Edgeware binary."
ARG PROFILE=release
COPY --from=builder /edgeware/target/$PROFILE/edgeware /usr/local/bin
COPY --from=builder /edgeware/chains /usr/local/bin/chains

RUN rm -rf /usr/lib/python* && \
	useradd -m -u 1000 -U -s /bin/sh -d /edgeware edgeware && \
	mkdir -p /edgeware/.local/share/edgeware && \
	chown -R edgeware:edgeware /edgeware/.local && \
  ln -s /edgeware/.local/share/edgeware /data && \
  rm -rf /usr/bin /usr/sbin


USER edgeware
EXPOSE 30333 9933 9944
VOLUME ["/data"]

WORKDIR /usr/local/bin
CMD ["edgeware", "--chain", "edgeware", "--ws-external"]
