#!/bin/bash
if [ ! $# == 1 ] ; then
echo "Usage: $0 installPath"
exit 1
fi
INSTALLPATH=$1 ; export INSTALLPATH

echo "Updating symbolic links ..."

cd $INSTALLPATH

rm live > /dev/null
ln -s $(readlink prev) live

echo "Deployment successfully rolled back."
