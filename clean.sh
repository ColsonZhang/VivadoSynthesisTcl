#!/bin/bash


directory="./vivado"
find "$directory" -mindepth 1 ! -name "readme.txt" -delete

echo "清理完成"
