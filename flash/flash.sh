#!/usr/bin/env bash
# flash.sh — Droidian Flash-Script fuer Samsung Galaxy Tab A7 SM-T500 (gta4lwifi)
# Voraussetzungen: siehe Readme.md in diesem Ordner

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step()  { echo -e "\n${GREEN}==>${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[FEHLER]${NC} $1\n"; exit 1; }

echo -e "${GREEN}=== Droidian Flash-Script - SM-T500 gta4lwifi ===${NC}"
echo ""

# Heimdall suchen
HEIMDALL="./heimdall"
[ -f "$HEIMDALL" ] || HEIMDALL="$(which heimdall 2>/dev/null || true)"
if [ -z "$HEIMDALL" ] || [ ! -f "$HEIMDALL" ]; then
  error "heimdall nicht gefunden!\nGepatchtes Heimdall herunterladen:\nhttps://androidfilehost.com/?w=files&flid=338156\n→ in diesen Ordner kopieren"
fi

# Dateien pruefen
[ -f "vbmeta.img" ] || error "vbmeta.img fehlt!\nHerunterladen von:\nhttps://download.lineageos.org/devices/gta4lwifi/builds\n→ neueste Zeile → vbmeta.img"
[ -f "boot.img" ]   || error "boot.img fehlt! Bitte aus den GitHub Actions Artifacts herunterladen."

echo "Gefunden:"
ls -lh vbmeta.img boot.img

echo ""
echo "Tablet muss im Download Mode sein:"
echo "  Tablet aus → Vol Down + Vol Up halten → USB anstecken → bestaetigen"
echo ""
read -r -p "Weiter? [Enter]"

step "1/2 — VBMeta deaktivieren (AVB aus)"
"$HEIMDALL" flash --VBMETA vbmeta.img --no-reboot
echo "=> Erledigt. Tablet NICHT normal starten lassen!"

echo ""
echo "Tablet neu in Download Mode bringen:"
echo "  Power lang druecken → aus → dann wieder Vol Down + Vol Up + USB"
echo ""
read -r -p "Weiter wenn Download Mode aktiv ist [Enter]"

step "2/2 — Droidian boot.img flashen"
"$HEIMDALL" flash --BOOT boot.img --no-reboot
echo "=> Erledigt."

echo ""
echo -e "${GREEN}Fertig!${NC}"
echo "Tablet manuell neu starten: Power-Taste lang druecken"
echo ""
warn "Beim ersten Boot erscheint noch kein Droidian."
warn "Als naechstes das Droidian Rootfs flashen — siehe Readme.md"
