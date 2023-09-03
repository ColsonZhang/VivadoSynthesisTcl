#!/bin/bash

find "./vivado" -mindepth 1 ! -name "readme.txt" -delete
find "./" -name "*vivado*.log" -type f -delete
find "./" -name "*vivado*.jou" -type f -delete
find "./" -type d -name "*.Xil" -exec rm -rf {} +

echo "清理完成"
