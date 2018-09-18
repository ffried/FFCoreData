#!/bin/sh

if [ -z "$XCODE_PROJECT" ] && [ -z "$XCODE_WORKSPACE" ]; then
	echo "Missing environment variables XCODE_PROJECT or XCODE_WORKSPACE!"
	exit 1
elif [ ! -z "$XCODE_PROJECT" ] && [ ! -z "$XCODE_WORKSPACE" ]; then
	echo "Both environment variables XCODE_PROJECT and XCODE_WORKSPACE are defined. They are mutually exclusive!"
	exit 1
fi

if [ -z "$XCODE_SCHEME" ]; then
	echo "Missing environment variable XCODE_SCHEME!"
	exit 1
fi

if [ -z "$XCODE_DESTINATION" ]; then
	echo "Missing environment variable XCODE_DESTINATION!"
	exit 1
fi

XCODE_CONTAINER_ARG=""
if [ ! -z "$XCODE_PROJECT" ]; then
	XCODE_CONTAINER_ARG="-project $XCODE_PROJECT"
else
	XCODE_CONTAINER_ARG="-workspace $XCODE_WORKSPACE"
fi

set -o pipefail && \
xcodebuild \
	$XCODE_CONTAINER_ARG \
	-scheme "$XCODE_SCHEME" \
	-destination "$XCODE_DESTINATION" \
	build test | \
xcpretty
