#!/bin/sh
find $1 -type f -name '*.ninja' -exec sed -i 's/arm-linux-gnueabihf-//g' {} \;
find $1 -type f -name '*.ninja' -exec sed -i 's/\/arm-linux-gnueabihf//g' {} \;
