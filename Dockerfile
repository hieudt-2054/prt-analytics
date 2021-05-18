FROM alpine

MAINTAINER HieuDT<duong.trung.hieu@sun-asterisk.com>

RUN apk add --no-cache cloc \
	curl \
    git && \
    rm -rf /var/cache/apk/*

ARG PATH_CLOC=app \
    TOKEN \
    ENDPOINT

COPY prt-runner /usr/bin/prt-runner
RUN chmod +x /usr/bin/prt-runner

CMD tail -f /dev/null

# ENTRYPOINT cloc ${PATH_CLOC}
