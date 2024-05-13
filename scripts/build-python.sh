#!/bin/bash
set -euxo pipefail
scriptdir=$(cd $(dirname $0) && pwd)
projFile=$1

echo "::group::$requirements"
echo "=============================="
echo "building project: $requirements"
echo "=============================="

cd $(dirname $requirements)
echo "$(tput bold)Building project at $(dirname $requirements)$(tput sgr0)"
[[ ! -f DO_NOT_AUTOTEST ]] || exit 0

python3 -m venv /tmp/.venv

source /tmp/.venv/bin/activate
pip install -r requirements.txt

$scriptdir/synth.sh
# It is critical that we clean up the pip venv before we build the next python project
# Otherwise, if anything gets pinned in a requirements.txt, you end up with a weird broken environment
rm -rf /tmp/.venv
echo "::endgroup::"
