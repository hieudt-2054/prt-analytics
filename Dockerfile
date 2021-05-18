FROM alpine

MAINTAINER HieuDT<duong.trung.hieu@sun-asterisk.com>

RUN apk add --no-cache cloc \
	curl \
    git && \
    rm -rf /var/cache/apk/*

ENV PATH_CLOC="app tests" \
    TOKEN="token-prt" \
    ENDPOINT="prt-api"

COPY prt /usr/bin/prt
RUN chmod +x /usr/bin/prt

CMD tail -f /dev/null

