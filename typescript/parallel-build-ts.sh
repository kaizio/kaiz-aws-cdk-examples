cdk_json_path=$1

cdk_app_path=$(dirname $cdk_json_path)

echo $cdk_app_path

cd $cdk_app_path

npm install > /dev/null

npm run build > /dev/null

npx cdk synth > /dev/null
