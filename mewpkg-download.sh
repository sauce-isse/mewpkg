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
done

if [ -z "$LATEST_VERSION" ] || [ -z "$FOUND_REPO" ]; then
    echo "❌ Erreur : paquet $PACKAGE introuvable dans les dépôts officiels."
    exit 1
fi
 
# Si le paquet est "any", on met "any" au lieu de "x86_64"
if [ "$PACKAGE_ARCH" == "any" ]; then
    ARCH_DIR="any"
else
    ARCH_DIR="x86_64"
fi
 
 # Télécharger le paquet depuis chaque dépôt jusqu'à ce qu'il soit trouvé
for REPO in "${REPOS[@]}"; do
  PACKAGE_URL="${MIRROR}${REPO}/os/x86_64/${PACKAGE}-${LATEST_VERSION}-x86_64.pkg.tar.zst"
  echo "Tentative de téléchargement depuis ${PACKAGE_URL}..."
  
  wget "$PACKAGE_URL" -O "${TMP_DIR}/${PACKAGE}-${LATEST_VERSION}-x86_64.pkg.tar.zst"
  if [ $? -eq 0 ]; then
    echo "$PACKAGE téléchargé avec succès depuis ${REPO}."
    break  # Si le téléchargement réussit, on arrête la boucle
  else
    echo "Erreur lors du téléchargement depuis ${REPO}. Tentative suivante."
  fi
done
 
echo "⚙️ Installation de $PACKAGE..."
sudo pacman -U --noconfirm --needed "${TMP_DIR}/${PACKAGE}-${LATEST_VERSION}-${PACKAGE_ARCH}.pkg.tar.zst"

if [ $? -eq 0 ]; then
    echo "✅ $PACKAGE installé avec succès depuis le dépôt $REPO !"
else
    echo "❌ Erreur lors de l'installation de $PACKAGE."
    exit 1
fi
