#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
#set -x

# Each bundle is generated with a unique hash name to bust browser cache.
js_bundle=`ls /app/build/static/js/main.*.js`

# Render runtime env vars into bundle.
ruby -E utf-8:utf-8 \
  -r /app/.heroku/create-react-app/injectable_env.rb \
  -e "InjectableEnv.replace('/app/build/static/js/$js_bundle')"
