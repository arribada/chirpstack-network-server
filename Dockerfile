FROM --platform=$BUILDPLATFORM golang:1.13-alpine AS development

ENV PROJECT_PATH=/chirpstack-network-server
ENV PATH=$PATH:$PROJECT_PATH/build
ENV CGO_ENABLED=0
ENV GO_EXTRA_BUILD_ARGS="-a -installsuffix cgo"

RUN apk add --no-cache ca-certificates tzdata make git bash protobuf

RUN mkdir -p $PROJECT_PATH
COPY . $PROJECT_PATH
WORKDIR $PROJECT_PATH

RUN make dev-requirements

# Install TARGETPLATFORM parser to translate its value to GOOS, GOARCH, and GOARM
COPY --from=tonistiigi/xx:golang / /
# Bring TARGETPLATFORM to the build scope
ARG TARGETPLATFORM


RUN make

FROM alpine:latest AS production

WORKDIR /root/
RUN apk --no-cache add ca-certificates tzdata
COPY --from=development /chirpstack-network-server/build/chirpstack-network-server .
ENTRYPOINT ["./chirpstack-network-server"]
