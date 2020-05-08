#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -rf project/obj
haxelib run lime rebuild . ios -v
haxelib run lime rebuild . ios -debug -v
rm -rf project/obj
