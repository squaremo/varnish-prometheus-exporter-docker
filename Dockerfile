FROM golang:1.12 as exporter
ENV GO111MODULE=on

ARG VARNISH_PROMETHEUS_EXPORTER_VSN=1.5.1

RUN go get github.com/jonnenauha/prometheus_varnish_exporter@$VARNISH_PROMETHEUS_EXPORTER_VSN
#RUN go build

FROM varnish:6.2

EXPOSE 9131
VOLUME /var/lib/varnish
ENTRYPOINT ["/usr/local/bin/prometheus_varnish_exporter"]
COPY --from=exporter /go/bin/prometheus_varnish_exporter /usr/local/bin
