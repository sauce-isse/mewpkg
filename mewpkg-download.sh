#!/bin/bash

# Vérification si un paquet a été spécifié
if [ -z "$1" ]; then
  echo "Usage: $0 <package>"
  exit 1
fi

PACKAGE=$1
TMP_DIR="/tmp/mewpkg_temp"
mkdir -p "$TMP_DIR"

# Trouver le premier miroir actif
MIRROR="https://geo.mirror.pkgbuild.com/"

if [ -z "$MIRROR" ]; then
  echo "Aucun miroir Arch Linux trouvé. Vérifie /etc/pacman.d/mirrorlist."
  exit 1
fi

echo "Utilisation du miroir : $MIRROR"
# Demander la confirmation de l'utilisateur avant l'installation
read -p "Voulez-vous vraiment installer $PACKAGE-${LATEST_VERSION} ? (y/n) " -n 1 -r
echo    # Saut de ligne
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation annulée."
    exit 0
fi

# Recherche des versions disponibles du paquet
echo "Recherche des versions disponibles pour le paquet $PACKAGE..."

VERSIONS=$(pacman -Si "$PACKAGE" | grep Version | awk '{print $3}' | sort -V)

if [ -z "$VERSIONS" ]; then
  echo "Aucune version trouvée pour le paquet $PACKAGE."
  exit 1
fi

LATEST_VERSION=$(echo "$VERSIONS" | tail -n 1)

echo "La version la plus récente de $PACKAGE est : $LATEST_VERSION"

# Construire l'URL de téléchargement
PACKAGE_URL="${MIRROR}/extra/os/x86_64/${PACKAGE}-${LATEST_VERSION}-x86_64.pkg.tar.zst"

echo "Téléchargement de $PACKAGE-${LATEST_VERSION}-x86_64.pkg.tar.zst depuis $PACKAGE_URL..."

wget -O "${TMP_DIR}/${PACKAGE}-${LATEST_VERSION}-x86_64.pkg.tar.zst" "$PACKAGE_URL"

if [ $? -eq 0 ]; then
  echo "$PACKAGE-${LATEST_VERSION}-x86_64.pkg.tar.zst téléchargé avec succès."
else
  echo "Erreur lors du téléchargement de $PACKAGE-${LATEST_VERSION}-x86_64.pkg.tar.zst."
  exit 1
fi

sudo pacman -U --noconfirm --needed ${TMP_DIR}/${PACKAGE}-${LATEST_VERSION}-x86_64.pkg.tar.zst

exit 0

