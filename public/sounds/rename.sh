#!/usr/bin/env bash
#!/bin/bash
FILES=*.wav
for f in $FILES
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  cat $f
done
