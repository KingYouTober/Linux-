#!/usr/bin/env bash
# build.sh — Droidian-Kernel im Docker-Container bauen
# Ausführen auf dem Host nach setup.sh

set -e

KERNEL_DIR="$HOME/droidian/kernel/samsung/gta4lwifi"
PACKAGES_DIR="$HOME/droidian/packages"

if [ ! -d "$KERNEL_DIR/debian" ]; then
  echo "FEHLER: $KERNEL_DIR/debian nicht gefunden."
  echo "Bitte zuerst setup.sh ausführen."
  exit 1
fi

echo "==> Starte Droidian-Build-Container..."
docker run --rm \
  -v "$PACKAGES_DIR:/buildd" \
  -v "$KERNEL_DIR:/buildd/sources" \
  quay.io/droidian/build-essential:trixie-amd64 \
  bash -c '
    set -e
    cd /buildd/sources

    echo "--- Installiere linux-packaging-snippets ---"
    apt-get install -y linux-packaging-snippets

    echo "--- Erzeuge debian/control ---"
    rm -f debian/control
    debian/rules debian/control

    echo "--- Starte Kernel-Kompilierung ---"
    RELENG_HOST_ARCH="arm64" releng-build-package
  '

echo ""
echo "==> Build abgeschlossen!"
echo "    Pakete in: $PACKAGES_DIR"
echo ""
echo "    Ergebnis:"
ls -lh "$PACKAGES_DIR"/*.deb 2>/dev/null || echo "    (noch keine .deb-Dateien)"
