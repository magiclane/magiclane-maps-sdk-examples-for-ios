#!/bin/bash

# SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
# SPDX-License-Identifier: Apache-2.0
#
# Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

function on_err()
{
	echo "Error on line $1"
	
	exit 1
}
trap 'on_err $LINENO' ERR

function on_exit()
{
	if [ -d "${MY_DIR}" ]; then
		if [ -d "${MY_DIR}/BUILD" ]; then
			rm -rf "${MY_DIR}/BUILD"
		fi
		find ${MY_DIR} -type d \( -name "Build" -o -name "DerivedData" \) -prune -exec rm -rf {} \;
	fi
}
trap 'on_exit' EXIT

set -euox pipefail

MY_DIR="$(cd "$(dirname "$0")" && pwd)"

OUTPUT_DIR="${MY_DIR}/BUILD"
mkdir -p "${OUTPUT_DIR}"

pushd "${OUTPUT_DIR}" &>/dev/null

# Find paths that contain XCode Workspace's
EXAMPLE_WORKSPACES=( $(find ${MY_DIR} -mindepth 2 -maxdepth 2 -type d -name "*.xcworkspace") )

for EXAMPLE_WORKSPACE in "${EXAMPLE_WORKSPACES[@]}"; do
	PROJECT_NAMES=( $(xcodebuild \
		-quiet \
		-workspace "${EXAMPLE_WORKSPACE}" \
		-list | sed -n '/Schemes/,/^$/p' | grep -v "Schemes:" | grep -o '[^$(printf '\t') ].*') )

    for PROJECT in "${PROJECT_NAMES[@]}"; do
		# Build workspace with scheme
		xcodebuild \
			-quiet \
			-workspace "${EXAMPLE_WORKSPACE}" \
			-scheme "${PROJECT}" \
			-destination generic/platform=com.apple.platform.iphonesimulator \
			-configuration Debug \
			-derivedDataPath "${OUTPUT_DIR}" build MODULE_CACHE_DIR="${OUTPUT_DIR}/DerivedData/ModuleCache" OBJROOT="${OUTPUT_DIR}/Intermediates" \
			SHARED_PRECOMPS_DIR="${OUTPUT_DIR}/Intermediates/PrecompiledHeaders" SYMROOT="${OUTPUT_DIR}/Products"
	done
done

popd &>/dev/null
