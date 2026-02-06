#!/usr/bin/env bash
# vim:ts=4:sts=4:sw=4:et
# shellcheck disable=SC2317,SC2329

# SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
# SPDX-License-Identifier: Apache-2.0
#
# Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

set -eEuo pipefail

declare -r PROGNAME="${0##*/}"

declare -r COLOR_RESET_DEFAULT="\033[0m"
declare -r COLOR_RED_DEFAULT="\033[31;1m"
declare -r COLOR_GREEN_DEFAULT="\033[32;1m"
declare -r COLOR_YELLOW_DEFAULT="\033[33;1m"
declare -r COLOR_BLUE_DEFAULT="\033[34;1m"
declare -r COLOR_CYAN_DEFAULT="\033[36;1m"

COLOR_RESET="${COLOR_RESET_DEFAULT}"
COLOR_RED="${COLOR_RED_DEFAULT}"
COLOR_GREEN="${COLOR_GREEN_DEFAULT}"
COLOR_YELLOW="${COLOR_YELLOW_DEFAULT}"
COLOR_BLUE="${COLOR_BLUE_DEFAULT}"
COLOR_CYAN="${COLOR_CYAN_DEFAULT}"

CONSOLE_MODE="auto"

DESTINATION="generic/platform=iOS Simulator"

function log_timestamp()
{
    date "+%Y-%m-%d %H:%M:%S"
}

function log_info()
{
    printf '%b\n' "${COLOR_CYAN}[$(log_timestamp)] [INFO]${COLOR_RESET} $*"
}

function log_success()
{
    printf '%b\n' "${COLOR_GREEN}[$(log_timestamp)] [SUCCESS]${COLOR_RESET} $*"
}

function log_warning()
{
    printf '%b\n' "${COLOR_YELLOW}[$(log_timestamp)] [WARNING]${COLOR_RESET} $*"
}

function log_error()
{
    printf '%b\n' "${COLOR_RED}[$(log_timestamp)] [ERROR]${COLOR_RESET} $*" >&2
}

function log_step()
{
    printf '\n%b\n\n' "${COLOR_BLUE}[$(log_timestamp)] [STEP]${COLOR_RESET} $*"
}

function apply_console_mode()
{
    function _disable_colors()
    {
        COLOR_RESET=""
        COLOR_RED=""
        COLOR_GREEN=""
        COLOR_YELLOW=""
        COLOR_BLUE=""
        COLOR_CYAN=""
    }

    case "${CONSOLE_MODE}" in
        auto)
            if [[ ! -t 1 ]]; then
                _disable_colors
            fi
            ;;
        plain)
            _disable_colors
            ;;
        colored)
            :
            ;;
        verbose)
            set -x
            ;;
        *)
            log_error "Invalid --console value: '${CONSOLE_MODE}'. Allowed: auto, plain, colored, verbose"
            usage
            exit 1
            ;;
    esac
}

function check_cmd()
{
    command -v "${1}" >/dev/null 2>&1
}

function is_ci()
{
    if [[ -n "${CI:-}" ]] && [[ "${CI}" != "false" ]] && [[ "${CI}" != "0" ]]; then
        return 0
    fi

    local -a CI_VARS=(
        GITHUB_ACTIONS
        GITLAB_CI
        JENKINS_URL
        TEAMCITY_VERSION
        BUILDKITE
        CIRCLECI
        TRAVIS
        TF_BUILD
        BITBUCKET_BUILD_NUMBER
        DRONE
        SEMAPHORE
        CODEBUILD_BUILD_ID
    )

    local VAR
    for VAR in "${CI_VARS[@]}"; do
        [[ -n "${!VAR:-}" ]] && return 0
    done

    return 1
}

function setup_mac_deps()
{
    if [[ "$(uname)" != "Darwin" ]]; then
        return 0
    fi

    if ! check_cmd brew; then
        log_error "Missing Homebrew. Run:"
        # shellcheck disable=SC2016
        log_error '$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi

    local BREW_PREFIX
    BREW_PREFIX="$(brew --prefix)"

    # package:path_suffix
    local -a DEPS=(
        "gnu-getopt:gnu-getopt/bin"
    )

    local DEP PKG PATH_SUFFIX
    for DEP in "${DEPS[@]}"; do
        PKG="${DEP%%:*}"
        PATH_SUFFIX="${DEP##*:}"

        if ! brew ls --versions "${PKG}" > /dev/null 2>&1; then
            log_error "Missing ${PKG}. Run 'brew install ${PKG}'"
            exit 1
        fi

        export PATH="${BREW_PREFIX}/opt/${PATH_SUFFIX}:${PATH}"
    done
}

function get_example_name()
{
    local PROJECT_PATH="${1}"
    basename "${PROJECT_PATH}" .xcodeproj
}

function contains_in_array()
{
    local NEEDLE="$1"
    shift

    local NEEDLE_LC
    NEEDLE_LC="$(printf '%s' "${NEEDLE}" | tr '[:upper:]' '[:lower:]')"

    local ITEM ITEM_LC
    for ITEM in "$@"; do
        ITEM_LC="$(printf '%s' "${ITEM}" | tr '[:upper:]' '[:lower:]')"
        [[ "${ITEM_LC}" == "${NEEDLE_LC}" ]] && return 0
    done

    return 1
}

function filtering_active()
{
    [[ ${#ONLY_EXAMPLES[@]} -gt 0 ]] || [[ ${#EXCLUDE_EXAMPLES[@]} -gt 0 ]]
}

function validate_filter_names()
{
    local NAME PROJECT_PATH EXAMPLE_NAME
    local FOUND
    local -a UNKNOWN_ONLY=()
    local -a UNKNOWN_EXCLUDE=()

    for NAME in "${ONLY_EXAMPLES[@]}"; do
        FOUND=false
        for PROJECT_PATH in "${EXAMPLE_PROJECTS[@]}"; do
            EXAMPLE_NAME="$(get_example_name "${PROJECT_PATH}")"
            if contains_in_array "${NAME}" "${EXAMPLE_NAME}"; then
                FOUND=true
                break
            fi
        done
        if ! "${FOUND}"; then
            UNKNOWN_ONLY+=("${NAME}")
        fi
    done

    for NAME in "${EXCLUDE_EXAMPLES[@]}"; do
        FOUND=false
        for PROJECT_PATH in "${EXAMPLE_PROJECTS[@]}"; do
            EXAMPLE_NAME="$(get_example_name "${PROJECT_PATH}")"
            if contains_in_array "${NAME}" "${EXAMPLE_NAME}"; then
                FOUND=true
                break
            fi
        done
        if ! "${FOUND}"; then
            UNKNOWN_EXCLUDE+=("${NAME}")
        fi
    done

    if [[ ${#UNKNOWN_ONLY[@]} -gt 0 ]]; then
        log_error "Unknown example(s) in --only: ${UNKNOWN_ONLY[*]}"
        log_error "Use --list-examples to see available examples"
        exit 1
    fi

    if [[ ${#UNKNOWN_EXCLUDE[@]} -gt 0 ]]; then
        log_warning "Unknown example(s) in --exclude (ignored): ${UNKNOWN_EXCLUDE[*]}"
    fi
}

SCRIPT_DIR=""
OUTPUT_DIR=""
SHOW_EXIT_MESSAGE=true

declare -a EXAMPLE_PROJECTS=()
declare -a ONLY_EXAMPLES=()
declare -a EXCLUDE_EXAMPLES=()

function ctrl_c()
{
    exit 1
}
trap ctrl_c INT TERM

function dist_clean()
{
    [ "${CLEAN_ON_EXIT}" = true ] || return 0

    if [[ -n "${OUTPUT_DIR}" ]] && [[ -d "${OUTPUT_DIR}" ]]; then
        log_info "Cleaning build artifacts..."
        rm -rf "${OUTPUT_DIR}"
    fi

    local DEFAULT_DERIVED_DATA="${HOME}/Library/Developer/Xcode/DerivedData"
    if [[ -d "${DEFAULT_DERIVED_DATA}" ]] && [[ ${#EXAMPLE_PROJECTS[@]} -gt 0 ]]; then
        log_info "Cleaning default DerivedData..."
        local EXAMPLE_NAME
        for PROJECT_PATH in "${EXAMPLE_PROJECTS[@]}"; do
            EXAMPLE_NAME="$(get_example_name "${PROJECT_PATH}")"
            find "${DEFAULT_DERIVED_DATA}" -maxdepth 1 -type d -name "${EXAMPLE_NAME}-*" -exec rm -rf {} + 2>/dev/null || true
        done
    fi
}

function on_exit()
{
    local EXIT_CODE=$?
    set +e

    dist_clean

    if "${SHOW_EXIT_MESSAGE}"; then
        if [[ ${EXIT_CODE} -eq 0 ]]; then
            log_success "Done"
        else
            log_error "Build failed (exit code ${EXIT_CODE})"
        fi

        printf '\n'
        log_info "Bye-Bye"
    fi

    exit "${EXIT_CODE}"
}
trap on_exit EXIT

function usage()
{
    SHOW_EXIT_MESSAGE=false

    printf '%b\n' "${COLOR_GREEN}
Usage: ${PROGNAME} [options]

Options:
    -h, --help                   Show this help message

    --list-examples              List detected example names and exit

    --only <name>                Build only this example (can be repeated)

    --exclude <name>             Exclude this example from build (can be repeated)

    --fail-fast                  Exit on first error

    --clean                      Remove build artifacts on exit
                                 (default: on in CI, off locally)

    --console=(auto|plain|colored|verbose)
                                 Specifies which type of console output to generate

                                 auto:    colored when attached to a terminal,
                                          plain otherwise (default)
                                 plain:   plain text only; disables all color
                                 colored: colored output
                                 verbose: colored output and verbose logging
${COLOR_RESET}"
}

function check_prerequisites()
{
    log_step "Checking prerequisites..."

    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script must be run on macOS"
        exit 1
    fi

    if ! check_cmd xcodebuild; then
        log_error "xcodebuild not found. Please install Xcode from the App Store"
        exit 1
    fi

    log_info "Checking for installed iOS Simulator SDK..."

    local SIMULATOR_SDK
    SIMULATOR_SDK="$(xcodebuild -showsdks 2>/dev/null | grep "iphonesimulator" | tail -1 | sed -n 's/.*iphonesimulator\([0-9.]*\)/\1/p')"

    if [[ -z "${SIMULATOR_SDK}" ]]; then
        log_error "No iOS Simulator SDK found"
        log_error "Please install iOS platform components:"
        log_error "  Xcode > Settings > Platforms > iOS"
        exit 1
    fi

    log_info "Found iOS Simulator SDK: ${SIMULATOR_SDK}"
    log_success "Prerequisites OK"
}

function discover_examples()
{
    log_step "Discovering examples..."

    mapfile -t EXAMPLE_PROJECTS < <(
        find "${SCRIPT_DIR}" \
            -type d \( -name ".git" -o -name "Build" -o -name "DerivedData" -o -name "BUILD" -o -name "Internal" \) -prune -o \
            -type d -name "*.xcodeproj" \
                -not -name "Pods.xcodeproj" \
                -not -path "*/Pods/*" \
                -not -path "*/Internal/*" \
                -print 2>/dev/null | sort
    )

    if [[ ${#EXAMPLE_PROJECTS[@]} -eq 0 ]]; then
        log_error "No Xcode projects found under ${SCRIPT_DIR}"
        exit 1
    fi

    log_info "Found ${#EXAMPLE_PROJECTS[@]} project(s)"
}

function list_examples()
{
    SHOW_EXIT_MESSAGE=false

    local PROJECT_PATH EXAMPLE_NAME
    for PROJECT_PATH in "${EXAMPLE_PROJECTS[@]}"; do
        EXAMPLE_NAME="$(get_example_name "${PROJECT_PATH}")"
        printf '%s\n' "${EXAMPLE_NAME}"
    done
}

function filter_examples()
{
    local -a FILTERED=()
    local PROJECT_PATH EXAMPLE_NAME

    if [[ ${#ONLY_EXAMPLES[@]} -gt 0 ]] && [[ ${#EXCLUDE_EXAMPLES[@]} -gt 0 ]]; then
        log_error "Do not use --only and --exclude together"
        usage
        exit 1
    fi

    for PROJECT_PATH in "${EXAMPLE_PROJECTS[@]}"; do
        EXAMPLE_NAME="$(get_example_name "${PROJECT_PATH}")"

        if [[ ${#ONLY_EXAMPLES[@]} -gt 0 ]]; then
            if contains_in_array "${EXAMPLE_NAME}" "${ONLY_EXAMPLES[@]}"; then
                FILTERED+=("${PROJECT_PATH}")
            fi
            continue
        fi

        if [[ ${#EXCLUDE_EXAMPLES[@]} -gt 0 ]]; then
            if contains_in_array "${EXAMPLE_NAME}" "${EXCLUDE_EXAMPLES[@]}"; then
                continue
            fi
        fi

        FILTERED+=("${PROJECT_PATH}")
    done

    EXAMPLE_PROJECTS=("${FILTERED[@]}")

    if [[ ${#EXAMPLE_PROJECTS[@]} -eq 0 ]]; then
        log_error "After filtering, no examples remain to build"
        exit 1
    fi

    local -a EXAMPLE_NAMES=()
    for PROJECT_PATH in "${EXAMPLE_PROJECTS[@]}"; do
        EXAMPLE_NAME="$(get_example_name "${PROJECT_PATH}")"
        EXAMPLE_NAMES+=("${EXAMPLE_NAME}")
    done
    log_info "Selected ${#EXAMPLE_PROJECTS[@]} example(s): ${EXAMPLE_NAMES[*]}"
}

function get_schemes()
{
    local PROJECT="${1}"
    local -a SCHEMES

    mapfile -t SCHEMES < <(
        LC_ALL=C xcodebuild -quiet -project "${PROJECT}" -list 2>/dev/null | \
            sed -n '/Schemes:/,/^$/p' | \
            grep -v "Schemes:" | \
            sed 's/^[[:space:]]*//' | \
            grep -v '^$'
    )

    printf '%s\n' "${SCHEMES[@]}"
}

function build_project()
{
    local PROJECT_PATH="${1}"
    local CURRENT_INDEX="${2}"
    local TOTAL_COUNT="${3}"
    local EXAMPLE_NAME
    local EXAMPLE_OUTPUT_DIR
    local -a SCHEMES
    local SCHEME
    local BUILD_STATUS

    function _clean_default_derived_data()
    {
        local DEFAULT_DERIVED_DATA="${HOME}/Library/Developer/Xcode/DerivedData"
        [[ -d "${DEFAULT_DERIVED_DATA}" ]] || return 0

        find "${DEFAULT_DERIVED_DATA}" -maxdepth 1 -type d -name "${EXAMPLE_NAME}-*" -exec rm -rf {} + 2>/dev/null || true
    }

    EXAMPLE_NAME="$(get_example_name "${PROJECT_PATH}")"
    EXAMPLE_OUTPUT_DIR="${OUTPUT_DIR}/${EXAMPLE_NAME}"

    log_step "Building example (${CURRENT_INDEX}/${TOTAL_COUNT}): ${EXAMPLE_NAME} (${PROJECT_PATH})"
    mkdir -p "${EXAMPLE_OUTPUT_DIR}"

    mapfile -t SCHEMES < <(get_schemes "${PROJECT_PATH}")

    if [[ ${#SCHEMES[@]} -eq 0 ]]; then
        log_error "No schemes found in project '${EXAMPLE_NAME}'. Ensure schemes are shared (xcshareddata/xcschemes)."
        return 1
    fi

    log_info "Found ${#SCHEMES[@]} scheme(s): ${SCHEMES[*]}"
    log_info "Destination: ${DESTINATION}"

    for SCHEME in "${SCHEMES[@]}"; do
        [[ -z "${SCHEME}" ]] && continue

        log_info "Building scheme: ${SCHEME}"

        set +e
        xcodebuild \
            -quiet \
            -project "${PROJECT_PATH}" \
            -scheme "${SCHEME}" \
            -destination "${DESTINATION}" \
            -configuration Debug \
            -derivedDataPath "${EXAMPLE_OUTPUT_DIR}" \
            -clonedSourcePackagesDirPath "${EXAMPLE_OUTPUT_DIR}/SourcePackages" \
            -showBuildTimingSummary \
            build
        BUILD_STATUS=$?
        set -e

        if [[ ${BUILD_STATUS} -ne 0 ]]; then
            log_error "Scheme '${SCHEME}' failed to build (exit code ${BUILD_STATUS})"
            if "${CLEAN_ON_EXIT}"; then
                rm -rf "${EXAMPLE_OUTPUT_DIR}"
                _clean_default_derived_data
            fi
            return 1
        fi

        log_success "Scheme '${SCHEME}' built successfully"
    done

    log_success "Example '${EXAMPLE_NAME}' built successfully"

    if "${CLEAN_ON_EXIT}"; then
        rm -rf "${EXAMPLE_OUTPUT_DIR}"
        _clean_default_derived_data
    fi

    return 0
}

# =============================================================================
# Main
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/BUILD"

setup_mac_deps

FAIL_FAST=false
CLEAN_ON_EXIT=false
LIST_EXAMPLES=false

if is_ci; then
    CLEAN_ON_EXIT=true
fi

SHORTOPTS="h"
LONGOPTS_LIST=(
    "help"
    "list-examples"
    "only:"
    "exclude:"
    "fail-fast"
    "clean"
    "console:"
)

if ! PARSED_OPTIONS="$(getopt \
    -s bash \
    --options "${SHORTOPTS}" \
    --longoptions "$(printf "%s," "${LONGOPTS_LIST[@]}")" \
    --name "${PROGNAME}" \
    -- "$@")"; then
    usage
    exit 1
fi

eval set -- "${PARSED_OPTIONS}"
unset PARSED_OPTIONS

while true; do
    case "${1}" in
        -h|--help)
            usage
            exit 0
            ;;
        --list-examples)
            LIST_EXAMPLES=true
            ;;
        --only)
            shift
            ONLY_EXAMPLES+=("${1}")
            ;;
        --exclude)
            shift
            EXCLUDE_EXAMPLES+=("${1}")
            ;;
        --fail-fast)
            FAIL_FAST=true
            ;;
        --clean)
            CLEAN_ON_EXIT=true
            ;;
        --console)
            shift
            CONSOLE_MODE="${1}"
            ;;
        --)
            shift
            break
            ;;
        *)
            log_error "Internal error"
            exit 1
            ;;
    esac
    shift
done

apply_console_mode

check_prerequisites
discover_examples

if "${LIST_EXAMPLES}"; then
    list_examples
    exit 0
fi

if filtering_active; then
    validate_filter_names
fi
filter_examples

log_step "Setting up build environment..."
mkdir -p "${OUTPUT_DIR}"

BUILD_FAILED=false

TOTAL_EXAMPLES=${#EXAMPLE_PROJECTS[@]}
CURRENT_INDEX=0

for PROJECT_PATH in "${EXAMPLE_PROJECTS[@]}"; do
    CURRENT_INDEX=$((CURRENT_INDEX + 1))
    if ! build_project "${PROJECT_PATH}" "${CURRENT_INDEX}" "${TOTAL_EXAMPLES}"; then
        BUILD_FAILED=true

        if "${FAIL_FAST}"; then
            exit 1
        fi
    fi
done

if "${BUILD_FAILED}"; then
    log_error "One or more examples failed to build"
    exit 1
fi

exit 0
