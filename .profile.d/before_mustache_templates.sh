#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
#set -x

function encode_json_with_quote_esc() {
  echo -n $1 | ruby -r json -e "STDOUT << STDIN.read.to_json.gsub(/(^\"|\"$)/, '\\\"')"
}

echo "-----> Generating env variable REACT_APP_VARS_AS_JSON"
json='{'
is_first_line=true
for variable in $(env | grep -e "^REACT_APP_"); do
  IFS='=' read -r env_name env_value <<< "$variable"
  if [ "${env_name}" == "REACT_APP_VARS_AS_JSON" ]; then
    continue
  fi
  echo "       Capturing ${env_name}"
  if [ $is_first_line == false ]; then
    json="${json},"
  fi
  is_first_line=false
  json="${json}$(encode_json_with_quote_esc $env_name):$(encode_json_with_quote_esc $env_value)"
done
json="${json}}"
export REACT_APP_VARS_AS_JSON=$json
