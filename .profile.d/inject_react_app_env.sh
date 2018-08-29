#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
#set -x

# Each bundle is generated with a unique hash name to bust browser cache.
# Use shell `*` globbing to fuzzy match.
js_bundle="${JS_RUNTIME_TARGET_BUNDLE:-/app/build/static/js/main.*.js}"

static_json=/app/static.json
static_root=""

if [ -f "$static_json" ]
then
  static_root=$(cat $static_json | ruby -E utf-8:utf-8 -r json -e "STDOUT << JSON.parse(STDIN.read)['root']")
fi

# When JS_RUNTIME_TARGET_BUNDLE empty and static.json declares a custom root,
# dynamically set the bundle location.
if [ -z "$JS_RUNTIME_TARGET_BUNDLE" -a -n "$static_root" ]
then
  js_bundle="/app/${static_root}/static/js/main.*.js"
fi


if [ -f $js_bundle ]
then

  # Get exact filename.
  js_bundle_filename=`ls $js_bundle`
  
  echo "Injecting runtime env into $js_bundle_filename (from .profile.d/inject_react_app_env.sh)"

  # Render runtime env vars into bundle.
  ruby -E utf-8:utf-8 \
    -r /app/.heroku/create-react-app/injectable_env.rb \
    -e "InjectableEnv.replace('$js_bundle_filename')"
else
  echo "Error injecting runtime env: bundle not found '$js_bundle'. See: https://github.com/mars/create-react-app-buildpack/blob/master/README.md#user-content-custom-bundle-location"
fi
