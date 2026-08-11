#!/usr/bin/env bash
# install.sh — Droidian Ersteinrichtung für Samsung Galaxy Tab A7 (SM-T500)
# Auf dem Tablet ausführen nach dem ersten Boot
# Verbindung via: adb forward tcp:2222 tcp:22 && ssh -p 2222 droidian@localhost
#
# Führt aus:
#   1. System-Update
#   2. WLAN einrichten (interaktiv)
#   3. Apps installieren (Signal/Axolotl, Chromium/WhatsApp-PWA, foot-Terminal)
#   4. Phosh CSS (dunkles Theme) anwenden
#   5. Homescreen aufräumen (nur 4 Apps sichtbar)
#   6. Hintergrund auf schwarz setzen
#   7. Plymouth Bootsplash (minimalistisch)

set -e

REPO_RAW="https://raw.githubusercontent.com/KingYouTober/Linux-/main"

# ── Farben ──────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step()  { echo -e "\n${GREEN}==>${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[FEHLER]${NC} $1"; exit 1; }

# ── Root-Check ───────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  error "Bitte als root ausführen: sudo bash install.sh"
fi

ACTUAL_USER="${SUDO_USER:-droidian}"
USER_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

# ════════════════════════════════════════════════════════════════════════
step "1/7 — System aktualisieren"
# ════════════════════════════════════════════════════════════════════════
apt-get update -qq
apt-get upgrade -y -qq
echo "System aktuell."

# ════════════════════════════════════════════════════════════════════════
step "2/7 — WLAN einrichten"
# ════════════════════════════════════════════════════════════════════════
echo ""
echo "Verfügbare Netzwerke:"
nmcli -f SSID,SIGNAL,SECURITY device wifi list 2>/dev/null || warn "nmcli nicht verfügbar, WLAN manuell einrichten."
echo ""
read -r -p "WLAN-Name (SSID): " WIFI_SSID
read -r -s -p "WLAN-Passwort:   " WIFI_PASS
echo ""
if [ -n "$WIFI_SSID" ]; then
  nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS" && echo "WLAN verbunden." || warn "WLAN-Verbindung fehlgeschlagen — bitte manuell verbinden."
else
  warn "Kein WLAN-Name eingegeben, überspringe."
fi

# ════════════════════════════════════════════════════════════════════════
step "3/7 — Apps installieren"
# ════════════════════════════════════════════════════════════════════════

# Flatpak + Flathub
echo "  → Flatpak..."
apt-get install -y -qq flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# Signal: Axolotl (Flatpak)
echo "  → Signal (Axolotl)..."
sudo -u "$ACTUAL_USER" flatpak install -y --noninteractive flathub com.github.nanu_c.Axolotl 2>/dev/null \
  || warn "Axolotl konnte nicht installiert werden — später manuell: flatpak install flathub com.github.nanu_c.Axolotl"

# Chromium (für WhatsApp PWA)
echo "  → Chromium..."
apt-get install -y -qq chromium

# WhatsApp Desktop-Entry (PWA)
WHATSAPP_DESKTOP="$USER_HOME/.local/share/applications/whatsapp.desktop"
mkdir -p "$(dirname "$WHATSAPP_DESKTOP")"
cat > "$WHATSAPP_DESKTOP" << 'DESKTOP'
[Desktop Entry]
Name=WhatsApp
Exec=chromium --app=https://web.whatsapp.com --window-size=412,892 --force-device-scale-factor=1
Icon=chromium
Type=Application
Categories=Network;Chat;
StartupNotify=true
DESKTOP
chown "$ACTUAL_USER:$ACTUAL_USER" "$WHATSAPP_DESKTOP"
echo "  WhatsApp PWA Desktop-Entry erstellt."
echo "  Beim ersten Start: QR-Code mit deinem Handy scannen."

# foot Terminal
echo "  → Terminal (foot)..."
apt-get install -y -qq foot

# GNOME Settings
echo "  → GNOME Einstellungen..."
apt-get install -y -qq gnome-control-center

echo "Apps installiert."

# ════════════════════════════════════════════════════════════════════════
step "4/7 — Phosh CSS (dunkles Theme) anwenden"
# ════════════════════════════════════════════════════════════════════════
GTK_CSS_DIR="$USER_HOME/.config/gtk-3.0"
mkdir -p "$GTK_CSS_DIR"

# CSS aus dem Repo laden
if curl -fsSL "$REPO_RAW/configs/phosh.css" -o "$GTK_CSS_DIR/gtk.css" 2>/dev/null; then
  chown -R "$ACTUAL_USER:$ACTUAL_USER" "$GTK_CSS_DIR"
  echo "Phosh CSS angewendet → $GTK_CSS_DIR/gtk.css"
else
  warn "CSS konnte nicht geladen werden (kein Internet?). Manuell kopieren: configs/phosh.css → ~/.config/gtk-3.0/gtk.css"
fi

# ════════════════════════════════════════════════════════════════════════
step "5/7 — Homescreen aufräumen (nur 4 Apps sichtbar)"
# ════════════════════════════════════════════════════════════════════════
APPS_DIR="$USER_HOME/.local/share/applications"
mkdir -p "$APPS_DIR"

# Apps die SICHTBAR bleiben sollen (alles andere verstecken)
KEEP_APPS=(
  "com.github.nanu_c.Axolotl"   # Signal
  "whatsapp"                     # WhatsApp PWA
  "foot"                         # Terminal
  "gnome-control-center"         # Einstellungen
)

# Bekannte System-Apps die versteckt werden sollen
HIDE_APPS=(
  "org.gnome.Nautilus"
  "org.gnome.gedit"
  "org.gnome.eog"
  "org.gnome.Totem"
  "org.gnome.Rhythmbox3"
  "org.gnome.Music"
  "org.gnome.Maps"
  "org.gnome.Calendar"
  "org.gnome.Contacts"
  "org.gnome.Weather"
  "org.gnome.clocks"
  "org.gnome.Calculator"
  "org.gnome.baobab"
  "org.gnome.TextEditor"
  "org.gnome.FileRoller"
  "org.gnome.Screenshot"
  "org.gnome.font-viewer"
  "org.gnome.Characters"
  "org.gnome.DiskUtility"
  "org.freedesktop.Piper"
  "org.gnome.Evince"
  "simple-scan"
  "nm-connection-editor"
  "htop"
  "vim"
  "yelp"
  "software-properties-gtk"
)

for app in "${HIDE_APPS[@]}"; do
  DESKTOP_FILE="$APPS_DIR/${app}.desktop"
  if [ ! -f "$DESKTOP_FILE" ]; then
    printf '[Desktop Entry]\nHidden=true\n' > "$DESKTOP_FILE"
    chown "$ACTUAL_USER:$ACTUAL_USER" "$DESKTOP_FILE"
  fi
done

echo "Homescreen bereinigt — nur Signal, WhatsApp, Terminal, Einstellungen sichtbar."
echo "Weitere Apps verstecken: echo -e '[Desktop Entry]\nHidden=true' > ~/.local/share/applications/APPNAME.desktop"

# ════════════════════════════════════════════════════════════════════════
step "6/7 — Hintergrund auf schwarz setzen"
# ════════════════════════════════════════════════════════════════════════
sudo -u "$ACTUAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$ACTUAL_USER")/bus" \
  gsettings set org.gnome.desktop.background picture-uri '' 2>/dev/null || true
sudo -u "$ACTUAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$ACTUAL_USER")/bus" \
  gsettings set org.gnome.desktop.background primary-color '#0a0a0a' 2>/dev/null || true
sudo -u "$ACTUAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$ACTUAL_USER")/bus" \
  gsettings set org.gnome.desktop.background color-shading-type 'solid' 2>/dev/null || true
echo "Hintergrund: schwarz (#0a0a0a)"

# ════════════════════════════════════════════════════════════════════════
step "7/7 — Plymouth Bootsplash (minimalistisch, schwarzer Screen)"
# ════════════════════════════════════════════════════════════════════════
apt-get install -y -qq plymouth plymouth-themes

# Theme auf "fade-in" (sehr minimalistisch, fast unsichtbar)
if plymouth-set-default-theme fade-in 2>/dev/null; then
  update-initramfs -u -k all 2>/dev/null || update-initramfs -u
  echo "Plymouth Theme: fade-in (minimalistisch)"
else
  warn "Plymouth Theme konnte nicht gesetzt werden — manuell: sudo plymouth-set-default-theme fade-in && sudo update-initramfs -u"
fi

# ════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Einrichtung abgeschlossen!             ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "  Signal:      flatpak run com.github.nanu_c.Axolotl"
echo "  WhatsApp:    Im App-Drawer → WhatsApp (QR-Code mit Handy scannen)"
echo "  Terminal:    foot"
echo "  Einstellungen: gnome-control-center"
echo ""
echo "  → Tablet neu starten: sudo reboot"
echo ""
