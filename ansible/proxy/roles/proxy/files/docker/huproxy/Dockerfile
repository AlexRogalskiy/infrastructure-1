FROM golang:alpine as gobuilder

RUN apk add --update git

ENV GO111MODULE=auto
RUN go get "github.com/DMarby/huproxy"
RUN go install github.com/DMarby/huproxy

FROM alpine:3.8
COPY --from=gobuilder /go/bin/huproxy /usr/bin/huproxy
ENTRYPOINT ["/usr/bin/huproxy"]
