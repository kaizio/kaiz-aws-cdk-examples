#!/bin/bash
set -euxo pipefail
scriptdir=$(cd $(dirname $0) && pwd)
projFile=$1

echo "=============================="
echo "building project: $projFile"
echo "=============================="

cd $(dirname $projFile)
if [[ -f DO_NOT_AUTOTEST ]]; then exit 0; fi

go get -d -t && go build

$scriptdir/synth.sh
