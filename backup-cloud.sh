#!/bin/bash

# 0 11 * * 6 /var/backup/backup-cloud.sh > /dev/null 2>&1

source_file="/home/nextcloud/data"

destination_dir="/home/backup"

compressed_file_name="backup"

date_format=$(date +%Y%m%d)

max_backups=5

if [ ! -e "$source_file" ]; then
  echo "Le fichier source n'existe pas."
  exit 1
fi

if [ ! -d "$destination_dir" ]; then
  echo "Le répertoire de destination n'existe pas."
  exit 1
fi

backup_count=$(ls -1t "$destination_dir/$compressed_file_name-"*.tar.gz 2>/dev/null | wc -l)
if [ "$backup_count" -ge "$max_backups" ]; then
  ls -1t "$destination_dir/$compressed_file_name-"*.tar.gz | tail -n +$((max_backups + 1)) | xargs rm
fi

temp_file="$destination_dir/$compressed_file_name-$date_format.tmp"
cp -rf "$source_file" "$temp_file" || { echo "Erreur lors de la copie du fichier source."; exit 1; }

tar -czf "$destination_dir/$compressed_file_name-$date_format.tar.gz" -C "$destination_dir" "$(basename "$temp_file")" || { echo "Erreur lors de la compression du fichier."; exit 1; }

rm -rf "$temp_file" || { echo "Erreur lors de la suppression du fichier temporaire."; exit 1; }

chmod 664 "$destination_dir/$compressed_file_name-$date_format.tar.gz" || { echo "Erreur lors de la modification des permissions du fichier compressé."; exit 1; }

echo "Le fichier a été copié, compressé et renommé en $compressed_file_name-$date_format.tar.gz dans $destination_dir avec les bonnes permissions pour le téléchargement via FTP."
