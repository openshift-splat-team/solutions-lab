#!/bin/bash

# for each directory under ./.run/ create a tarball of it 
# and store it in ./logs/
for dir in .run/*; do
    tar -czf .run/$(basename $dir).tar.gz $dir
done
