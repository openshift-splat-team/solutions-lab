#!/bin/bash

for dir in test-cases/*; do
  if [ -d "$dir" ]; then
    ./run-case.py "$dir"
  fi
done
