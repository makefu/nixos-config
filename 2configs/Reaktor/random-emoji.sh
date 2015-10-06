#!/bin/sh
curl http://emojicons.com/random -s | \
  grep data-text | \
  sed -n 's/.*>\(.*\)<\/textarea>/\1/p' | \
  head -n 1
