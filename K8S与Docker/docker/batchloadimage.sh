#!/bin/bash
for image_name in $(ls ./ | grep tar.gz)
do
  docker load < ${image_name}
done
