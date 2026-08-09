#!/usr/bin/env bash
# setup.sh — Kernel-Quellen klonen und Droidian-Branch vorbereiten
# Ausführen auf dem Host (nicht im Docker)
#
# Voraussetzungen: git, docker

set -e

KERNEL_DIR="$HOME/droidian/kernel/samsung/gta4lwifi"
PACKAGES_DIR="$HOME/droidian/packages"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Verzeichnisse anlegen..."
mkdir -p "$PACKAGES_DIR"
mkdir -p "$(dirname "$KERNEL_DIR")"

# Kernel klonen falls noch nicht vorhanden
if [ ! -d "$KERNEL_DIR/.git" ]; then
  echo "==> Kernel-Quellen klonen (LineageOS sm7125, ca. 1 GB)..."
  git clone \
    --depth=1 \
    --branch lineage-23.2 \
    https://github.com/LineageOS/android_kernel_samsung_sm7125 \
    "$KERNEL_DIR"
else
  echo "==> Kernel-Quellen bereits vorhanden, überspringe Clone."
fi

# Droidian-Branch erstellen
cd "$KERNEL_DIR"
if ! git show-ref --verify --quiet refs/heads/droidian; then
  echo "==> Droidian-Branch erstellen..."
  git checkout -b droidian
else
  echo "==> Droidian-Branch existiert bereits."
  git checkout droidian
fi

# Prüfen ob debian-Verzeichnis im Repo vorhanden ist
if [ ! -d "$REPO_DIR/droidian/debian" ]; then
  echo "FEHLER: $REPO_DIR/droidian/debian nicht gefunden."
  echo "Bitte das debian/-Verzeichnis mit kernel-info.mk, rules, compat und source/format anlegen."
  exit 1
fi

# Packaging-Dateien aus dem Repo kopieren
echo "==> Droidian-Packaging-Dateien einkopieren..."
cp -rv "$REPO_DIR/droidian/debian" "$KERNEL_DIR/"
cp -rv "$REPO_DIR/droidian/defconfig-fragments" "$KERNEL_DIR/droidian"

echo ""
echo "==> Fertig! Nächster Schritt: Docker-Build starten."
echo "    Führe aus: bash $REPO_DIR/droidian/build.sh"fi

# Packaging-Dateien aus dem Repo kopieren
echo "==> Droidian-Packaging-Dateien einkopieren..."
cp -rv "$REPO_DIR/droidian/debian" "$KERNEL_DIR/"
cp -rv "$REPO_DIR/droidian/defconfig-fragments" "$KERNEL_DIR/droidian"

echo ""
echo "==> Fertig! Nächster Schritt: Docker-Build starten."
echo "    Führe aus: bash $REPO_DIR/droidian/build.sh"
