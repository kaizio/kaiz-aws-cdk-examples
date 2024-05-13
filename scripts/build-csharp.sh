#!/bin/bash
set -euxo pipefail
scriptdir=$(cd $(dirname $0) && pwd)
projFile=$1

# install CDK CLI from npm, so that npx can find it later
cd $scriptdir/../csharp
npm install

echo "=============================="
echo "building project: $projFile"
echo "=============================="

cd $(dirname $projFile)
if [[ -f DO_NOT_AUTOTEST ]]; then exit 0; fi

dotnet build src

$scriptdir/synth.sh
