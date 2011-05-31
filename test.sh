#!/bin/bash

p="##################################"

for f in `ls programas/*.pas` ; do
  echo -e "\n$p\n    $f\n$p\n"
  ./compilador $f
done

