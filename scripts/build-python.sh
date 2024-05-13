#!/bin/bash
set -euo pipefail
scriptdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# Export scriptdir for use in parallel
export scriptdir

# Check for required arguments
# $1: Path to the project
# $2: Rest of path after project path

# install CDK CLI from npm, so that npx can find it later
cd $scriptdir/../python
npm install

# Find all Python projects
projects=$(find "$scriptdir/../python/$1" -name requirements.txt -not -path "$scriptdir/../python/node_modules/*" -print0 | xargs -0 -n1 dirname | sort -u)

build_project() {
    local project_dir="$1"

    echo "::group::$project_dir"
    echo "=============================="
    echo "Building project: $project_dir"
    echo "=============================="

    cd "$project_dir" || exit

    if [[ -f DO_NOT_AUTOTEST ]]; then
        echo "Skipping project due to DO_NOT_AUTOTEST flag"
        echo "::endgroup::"
        return 0
    fi

    echo "$(tput bold)Building project at $(pwd)$(tput sgr0)"

    python3 -m venv "/tmp/.venv-$(basename "$project_dir")"
    source "/tmp/.venv-$(basename "$project_dir")/bin/activate"
    pip install -r "requirements.txt"

    if ! "$scriptdir/synth.sh"; then
        echo "::error::synth.sh failed for project $project_dir"
        deactivate
        rm -rf "/tmp/.venv-$(basename "$project_dir")"
        echo "::endgroup::"
        return 1
    fi

    deactivate
    rm -rf "/tmp/.venv-$(basename "$project_dir")"
    echo "::endgroup::"
}

export -f build_project

# Build projects in parallel
parallel --keep-order --halt-on-error 1 build_project ::: "$projects"
