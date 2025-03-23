#!/bin/bash

 # Définition des variables
 MIRROR="https://geo.mirror.pkgbuild.com/"
 TMP_DIR="/tmp/mewpkg_temp"
 REPOS=("core" "extra" "community" "multilib")

 mkdir -p "$TMP_DIR"

 # Vérification des arguments
 if [ "$#" -ne 2 ] || [ "$1" != "install" ]; then
     echo "Utilisation : mewpkg install <paquet>"
     exit 1
 fi

 PACKAGE="$2"

 echo "🔍 Recherche de la dernière version de $PACKAGE..."

 # Recherche de la version et du dépôt où se trouve le paquet
 LATEST_VERSION=""
 FOUND_REPO=""
 PACKAGE_ARCH="x86_64"  # Par défaut, on cherche en x86_64

 for REPO in "${REPOS[@]}"; do
     PACKAGE_INFO=$(pacman -Si "$PACKAGE" --dbpath /var/lib/pacman 2>/dev/null)
     if [ ! -z "$PACKAGE_INFO" ]; then
         LATEST_VERSION=$(echo "$PACKAGE_INFO" | grep Version | awk '{print $3}')
         PACKAGE_ARCH=$(echo "$PACKAGE_INFO" | grep Architecture | awk '{print $3}')
         FOUND_REPO="$REPO"
         break
     fi
