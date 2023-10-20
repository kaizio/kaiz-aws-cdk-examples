files=$(find ../typescript/ -iname package.json -not -path "*/node_modules/*")
echo $files
echo $files | xargs sed -i 's/\("@types\/jest": "\)\(.*\)\(",\?\)/\1^29.5.5\3/g'
echo $files | xargs sed -i 's/\("@types\/node": "\)\(.*\)\(",\?\)/\120.6.3\3/g'
echo $files | xargs sed -i 's/\("jest": "\)\(.*\)\(",\?\)/\1^29.7.0\3/g'
echo $files | xargs sed -i 's/\("ts-jest": "\)\(.*\)\(",\?\)/\1^29.1.1\3/g'
echo $files | xargs sed -i 's/\("aws-cdk": "\)\(.*\)\(",\?\)/\12.99.1\3/g'
echo $files | xargs sed -i 's/\("ts-node": "\)\(.*\)\(",\?\)/\1^10.9.1\3/g'
echo $files | xargs sed -i 's/\("typescript": "\)\(.*\)\(",\?\)/\1~5.2.2\3/g'
echo $files | xargs sed -i 's/\("aws-cdk-lib": "\)\(.*\)\(",\?\)/\12.99.1\3/g'
echo $files | xargs sed -i 's/\("constructs": "\)\(.*\)\(",\?\)/\1^10.0.0\3/g'
echo $files | xargs sed -i 's/\("source-map-support": "\)\(.*\)\(",\?\)/\1^0.5.21\3/g'
