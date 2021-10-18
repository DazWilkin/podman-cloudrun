ARG GOLANG_VERSION="1.17"

FROM docker.io/golang:${GOLANG_VERSION} as build

WORKDIR /test

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY main.go main.go

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo .

RUN useradd --uid=10001 scratchuser


FROM scratch

LABEL org.opencontainers.image.source https://github.com/dazwilkin/test

COPY --from=build test /
COPY --from=build /etc/passwd /etc/passwd

USER scratchuser

ENTRYPOINT ["/test"]
