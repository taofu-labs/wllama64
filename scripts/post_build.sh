#!/bin/bash

set -e

CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $CURRENT_PATH/..

mkdir -p esm/wasm
if [ -f src/wasm/wllama.wasm ]; then
  cp src/wasm/wllama.wasm esm/wasm
else
  echo "src/wasm/wllama.wasm is missing, run npm run build:wasm to ship it"
fi

# https://stackoverflow.com/questions/62619058/appending-js-extension-on-relative-import-statements-during-typescript-compilat

function patch_esm_import_js {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    find $1 \( -name "*.js" -o -name "*.d.ts" \) -exec sed -i '' -E "s#export (.*) from '\.(.*)';#export \1 from '.\2\.js';#g" {} +;
    find $1 \( -name "*.js" -o -name "*.d.ts" \) -exec sed -i '' -E "s#import (.*) from '\.(.*)';#import \1 from '.\2\.js';#g" {} +;
  else
    find $1 \( -name "*.js" -o -name "*.d.ts" \) -exec sed -i -E "s#export (.*) from '\.(.*)';#export \1 from '.\2\.js';#g" {} +;
    find $1 \( -name "*.js" -o -name "*.d.ts" \) -exec sed -i -E "s#import (.*) from '\.(.*)';#import \1 from '.\2\.js';#g" {} +;
  fi
}

patch_esm_import_js "./esm"
