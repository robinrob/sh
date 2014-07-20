#!/bin/bash

backup_path="backup"

documents_path="Documents"
photos_path="Pictures"

mkdir /home/msl/backup_drive
sudo mount /dev/disk/by-label/SD_4G /home/msl/backup_drive
sudo mount /dev/disk/by-label/SD_4G_1 /home/msl/backup_drive
sudo mount /dev/disk/by-label/BLACK_HOLE /home/msl/backup_drive
sudo mount /dev/disk/by-label/MICRO_SD_4G /home/msl/backup_drive
sudo mount /dev/disk/by-label/3B7F-7F32 /home/msl/backup_drive
sudo mount /dev/disk/by-label/INTENSO /home/msl/backup_drive

cd ~/

    echo "Backing up:"
    mkdir ~/backup
    
    echo -e "Copying Documents folder to $backup_path"
    cp -r $documents_path $backup_path/
    echo "Done"
    
    echo -e "Copying Photos folder to $backup_path"
    cp -r $photos_path $backup_path/
    echo "Done"
    
    echo "Compressing $backup_path and backing up to $destination_path"
    sudo tar -zcf $destination_path $backup_path
    
    echo "Backed up $work_path to $destination_path"
	
sudo umount /home/msl/backup_drive
sudo rm -r /home/msl/backup_drive
	
exit 0
