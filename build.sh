#!/bin/bash

# Builds binaries for each os/arch combo in ./build/<version>/<os>/<arch>/mc-server-runner
# usage: [COMPRESS=1] ./build.sh [version]
#   version - version specifier; defaults to 'dev'
#   COMPRESS - if this env var is set, tar.gz of each build will be created in ./dist

# to run this build script in a circleci container (note the optional COMPRESS env var):
#   docker run --rm [-e COMPRESS=1] -v ${PWD}:/build -w /build circleci/golang:1.12 /bin/bash /build/build.sh
# to run the build container interactively:
#   docker run -it --rm -v ${PWD}:/build -w /build circleci/golang:1.12 /bin/bash

VERSION=${1:-dev}

# valid GOOS + GOARCH combinations:
# https://golang.org/doc/install/source#environment
for GOOS in darwin linux; do
    for GOARCH in 386 amd64 arm64; do
        echo "* Building $VERSION $GOOS/$GOARCH"
	    go build -o ./build/$VERSION/$GOOS/$GOARCH/mc-server-runner main.go
        if [ -n "$COMPRESS" ]; then
            echo "** Compressing"
            tar -czf "./dist/mc-server-runner.$VERSION.$GOOS.$GOARCH.tar.gz" ./build/$VERSION/$GOOS/$GOARCH/mc-server-runner
        fi
    done
done

# arm64 not supported on windows
GOOS=windows
for GOARCH in 386 amd64; do
    echo "* Building $VERSION $GOOS/$GOARCH"
    go build -o ./build/$VERSION/$GOOS/$GOARCH/mc-server-runner main.go
    if [ -n "$COMPRESS" ]; then
        echo "** Compressing"
        tar -czf "./dist/mc-server-runner.$VERSION.$GOOS.$GOARCH.tar.gz" ./build/$VERSION/$GOOS/$GOARCH/mc-server-runner
    fi
done
