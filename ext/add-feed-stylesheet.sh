#!/bin/bash

{
  echo '/<?xml'
  printf 's/>/>\\\n/\n'
  echo i
  echo '<?xml-stylesheet href="/feed-style.xsl" type="text/xsl"?>'
  echo .
  echo w
} | ed "$*" >/dev/null
