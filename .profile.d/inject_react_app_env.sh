#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
set -x

static_json=/app/static.json
if [ -f $static_json ]
then
  echo "Resolving static bundle from "
  static_root=$(/app/.heroku/node/bin/node -pe 'JSON.parse(process.argv[1]).root || ""' "$(cat $static_json)")
fi

# Each bundle is generated with a unique hash name
# to bust browser cache.
js_bundle=/app/$static_root/build/static/js/main.*.js

if [ -f $js_bundle ]
then

  # Get exact filename.
  js_bundle_filename=`ls $js_bundle`
  
  echo "Injecting runtime env into $js_bundle_filename (from .profile.d/inject_react_app_env.sh)"

  # Render runtime env vars into bundle.
  ruby -E utf-8:utf-8 \
    -r /app/.heroku/create-react-app/injectable_env.rb \
    -e "InjectableEnv.replace('$js_bundle_filename')"
fi
