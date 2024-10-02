#!/bin/bash

echo "Посмотрим, что получилось после перезагрузки"
sudo mount
echo "Проверяем рэйд одним способом"
cat /proc/mdstat
echo "Проверяем рэйд вторым способом"
sudo mdadm -D /dev/md0
echo "Сломаем один диск"