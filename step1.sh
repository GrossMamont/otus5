#!/bin/bash

#приступаем
	      mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
	      yum install -y mdadm smartmontools hdparm gdisk rsync mc

#приступаем
echo "Посмотрим диски"
lsblk
echo "Чистим суперблоки"
mdadm --zero-superblock --force /dev/sd{b,c,d,e}
echo "Собираем райд 10"
sudo mdadm --create --verbose /dev/md0 -l 10 -n4 /dev/sd{b,c,d,e}
sleep 30
echo "Проверяем рэйд одним способом"
cat /proc/mdstat
echo "Проверяем рэйд вторым способом"
sudo mdadm -D /dev/md0
echo "Сломаем один диск"
sudo mdadm /dev/md0 --fail /dev/sde
echo "Посмотрим состояние рейда"
cat /proc/mdstat
sudo mdadm -D /dev/md0
echo "Удалим поломанное"
sudo mdadm /dev/md0 --remove /dev/sde
echo "Добавим рабочее"
sudo mdadm /dev/md0 --add /dev/sde
echo "Смотрим на состояние в процессе"
cat /proc/mdstat
sleep 30
echo "Смотрим на состояние в итоге"
cat /proc/mdstat

# Сохраним конфиг рейда
echo "Смотрим что сейчас имеем"
sudo mdadm --detail --scan --verbose
echo "Создадим каталог для mdadm"
sudo mkdir /etc/mdadm
echo "Сохраним текущий конфиг в файл"
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' > /etc/mdadm/mdadm.conf
echo "Проверяем содержимое конфига"
cat /etc/mdadm/mdadm.conf

# Создаем разметку диска
echo "Размечаем раздел"
sudo parted -s /dev/md0 mklabel gpt
echo "Делим на части"
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%
echo "Создаем файловую систему на дисках"
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
echo "Создаем точки монтирования"
sudo mkdir -p /mnt/rpart{1,2,3,4,5}
echo "Пропишем диски в fstab"
echo "/dev/md0p1    /mnt/rpart1   ext4    defaults    0    1" | sudo tee -a /etc/fstab
echo "/dev/md0p2    /mnt/rpart2   ext4    defaults    0    1" | sudo tee -a /etc/fstab
echo "/dev/md0p3    /mnt/rpart3   ext4    defaults    0    1" | sudo tee -a /etc/fstab
echo "/dev/md0p4    /mnt/rpart4   ext4    defaults    0    1" | sudo tee -a /etc/fstab
echo "/dev/md0p5    /mnt/rpart5   ext4    defaults    0    1" | sudo tee -a /etc/fstab
echo "Подмонтируем разделы"
sudo mount -a
echo "Посмотрим, что получилось перед перезагрузкой"
sudo mount

