#!/usr/bin/env bash
# Flash-Script fuer Samsung Galaxy Tab A7 SM-T500 (gta4lwifi)
# Benoetigt:
#   - Gepatchtes Heimdall: https://androidfilehost.com/?w=files&flid=338156
#   - vbmeta.img von:      https://download.lineageos.org/devices/gta4lwifi/builds
#   - Tablet im Download Mode: Vol Down + Vol Up + USB

set -e

HEIMDALL="./heimdall"
[ -f "$HEIMDALL" ] || HEIMDALL="heimdall"

echo "=== Droidian Flash Script - SM-T500 gta4lwifi ==="
echo ""

if [ ! -f "vbmeta.img" ]; then
  echo "FEHLER: vbmeta.img fehlt!"
  echo ""
  echo "Herunterladen von:"
  echo "  https://download.lineageos.org/devices/gta4lwifi/builds"
  echo "  -> neueste Zeile -> vbmeta.img"
  exit 1
fi

if [ ! -f "boot.img" ]; then
  echo "FEHLER: boot.img fehlt!"
  exit 1
fi

echo "Schritt 1: VBMeta deaktivieren (AVB aus)"
$HEIMDALL flash --VBMETA vbmeta.img --no-reboot
echo "=> VBMeta geflasht. NICHT normal neu starten lassen!"
echo ""

echo "Schritt 2: Droidian boot.img flashen"
$HEIMDALL flash --BOOT boot.img --no-reboot
echo "=> boot.img geflasht"
echo ""

echo "Fertig!"
echo "Tablet jetzt manuell neu starten: Power-Taste lang druecken"
echo ""
echo "Naechster Schritt: Droidian Rootfs flashen"
echo "  https://github.com/droidian-images/rootfs-api29gsi-all/releases/latest"
