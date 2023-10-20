# Download files from aws
curl -sL -o other-packages.json https://raw.githubusercontent.com/aws/aws-cdk/main/packages/aws-cdk/lib/init-templates/app/typescript/package.json
curl -sL -o cdk-version.json https://raw.githubusercontent.com/aws/aws-cdk/main/version.v2.json
curl -sL -o constructs.json https://raw.githubusercontent.com/aws/aws-cdk/main/packages/aws-cdk/package.json

# Find all the package.json files in the typescript/ directory
files=$(find ../typescript/ -iname package.json -not -path "*/node_modules/*")

# Get current @types/jest and update all package.json files
typejest=$(cat other-packages.json | jq -r '.devDependencies."@types/jest"')
echo $files | xargs sed -i 's/\("@types\/jest": "\)\(.*\)\(",\?\)/\1'"$typejest"'\3/g'

# Get current @types/node and update all package.json files
typenode=$(cat other-packages.json | jq -r '.devDependencies."@types/node"')
echo $files | xargs sed -i 's/\("@types\/node": "\)\(.*\)\(",\?\)/\1'"$typenode"'\3/g'

# Get current jest and update all package.json files
jest=$(cat other-packages.json | jq -r '.devDependencies.jest')
echo $files | xargs sed -i 's/\("jest": "\)\(.*\)\(",\?\)/\1'"$jest"'\3/g'

# Get current ts-jest and update all package.json files
tsjest=$(cat other-packages.json | jq -r '.devDependencies."ts-jest"')
echo $files | xargs sed -i 's/\("ts-jest": "\)\(.*\)\(",\?\)/\1'"$tsjest"'\3/g'

# Get current ts-node and update all package.json files
tsnode=$(cat other-packages.json | jq -r '.devDependencies."ts-node"')
echo $files | xargs sed -i 's/\("ts-node": "\)\(.*\)\(",\?\)/\1'"$tsnode"'\3/g'

# Get current typescript and update all package.json files
typescript=$(cat other-packages.json | jq -r '.devDependencies.typescript')
echo $files | xargs sed -i 's/\("typescript": "\)\(.*\)\(",\?\)/\1'"$typescript"'\3/g'

# Get current sourcemap and update all package.json files
sourcemap=$(cat other-packages.json | jq -r '.dependencies."source-map-support"')
echo $files | xargs sed -i 's/\("source-map-support": "\)\(.*\)\(",\?\)/\1'"$sourcemap"'\3/g'

# Update AWS CDK versions for aws-cdk and aws-cdk-lib

cdkversion=$(cat cdk-version.json | jq -r '.version')
echo $files | xargs sed -i 's/\("aws-cdk": "\)\(.*\)\(",\?\)/\1'"$cdkversion"'\3/g'
echo $files | xargs sed -i 's/\("aws-cdk-lib": "\)\(.*\)\(",\?\)/\1'"$cdkversion"'\3/g'

# Get current constructs version and update all package.json files
constructs=$(cat constructs.json | jq -r '.devDependencies.constructs')
echo $files | xargs sed -i 's/\("constructs": "\)\(.*\)\(",\?\)/\1'"$constructs"'\3/g'
