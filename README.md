# Droidian Einrichtungsplan — Samsung Galaxy Tab A7 (SM-T500)

**Ziel:** Linux mit minimalistischer Oberfläche, 4 Apps (Signal, WhatsApp, Einstellungen, Terminal), sauberer Boot.

---

## Phase 1 — Kernel bauen ✅ (läuft gerade)

Der Kernel wird via GitHub Actions aus `KingYouTober/Linux-` (Branch `kernel`, Quelle: HeribertYavuz 4.19.315) gebaut.

**Ergebnis:** `boot.img` + Kernel-Module als Artifacts bei GitHub Actions.

Nach erfolgreichem Build: Artifacts herunterladen und entpacken.

```
artifacts/
├── Image.gz         ← Kernel
├── *.dtb            ← Device Tree
├── boot.img         ← Fertig zum Flashen
└── *.ko             ← Kernel-Module
```

---

## Phase 2 — Gerät vorbereiten

### 2.1 Voraussetzungen

- Samsung Galaxy Tab A7 SM-T500 (WiFi) mit Android 10/11
- PC mit Linux oder WSL2
- USB-Kabel (USB-A zu USB-C)
- ADB + Fastboot installiert:

```bash
sudo apt install adb fastboot
```

### 2.2 Developer Mode + OEM Unlock

Auf dem Tablet:

1. **Einstellungen → Über das Tablet → Software-Informationen**
2. Siebenmal auf **Build-Nummer** tippen → Developer Mode aktiv
3. **Einstellungen → Entwickleroptionen**
4. **OEM-Entsperrung** aktivieren
5. **USB-Debugging** aktivieren

### 2.3 TWRP installieren

TWRP wird als temporäres Recovery gebraucht um Droidian zu flashen.

```bash
# Tablet in Fastboot-Mode bringen:
# Power + Volume Down gedrückt halten bis Fastboot-Screen erscheint

# TWRP temporär booten (nicht permanent flashen):
fastboot boot twrp-gta4lwifi.img
```

TWRP für gta4lwifi: https://twrp.me/samsung/samsunggalaxytaba72020wifi.html

---

## Phase 3 — Droidian installieren

### 3.1 Droidian Rootfs herunterladen

```bash
# Von droidian.org – immer aktuellste Version nehmen
wget https://github.com/droidian-images/rootfs-api29gsi-all/releases/latest/download/droidian-ROOTFS-arm64.zip
```

### 3.2 Eigenes boot.img flashen

```bash
# Eigenes boot.img aus Phase 1 flashen:
fastboot flash boot artifacts/boot.img
```

### 3.3 Droidian Rootfs via TWRP flashen

Im TWRP:
1. **Install → Wähle droidian-ROOTFS-arm64.zip**
2. Swipe zum Flashen
3. **Reboot → System**

**Standard-Login:** Benutzer `droidian`, Passwort `1234`

---

## Phase 4 — Erste Einrichtung nach dem Boot

SSH über USB einrichten (einfacher als Tippen auf dem Tablet):

```bash
# Am PC:
adb forward tcp:2222 tcp:22
ssh -p 2222 droidian@localhost
# Passwort: 1234
```

### 4.1 System aktualisieren

```bash
sudo apt update && sudo apt upgrade -y
```

### 4.2 WLAN einrichten

```bash
# Via nmcli (NetworkManager):
nmcli device wifi list
nmcli device wifi connect "DEIN_WLAN" password "DEIN_PASSWORT"
```

---

## Phase 5 — Apps installieren

### 5.1 Signal (Axolotl)

Axolotl ist ein Signal-Client für Linux-Phones:

```bash
# Flatpak einrichten falls noch nicht vorhanden:
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Axolotl installieren:
flatpak install flathub com.github.nanu_c.Axolotl
```

Beim ersten Start: Telefonnummer registrieren (funktioniert wie Signal-App).

### 5.2 WhatsApp (als PWA)

WhatsApp hat keinen nativen Linux-Client. Lösung: Chromium als PWA.

```bash
sudo apt install -y chromium
```

Dann auf dem Tablet in Chromium:
1. `https://web.whatsapp.com` öffnen
2. QR-Code mit dem Handy scannen
3. Menü → **Als App installieren** (oder `--app` Flag)

Shortcut als Desktop-Entry erstellen:

```bash
cat > ~/.local/share/applications/whatsapp.desktop << 'EOF'
[Desktop Entry]
Name=WhatsApp
Exec=chromium --app=https://web.whatsapp.com --window-size=412,892
Icon=chromium
Type=Application
Categories=Network;
EOF
```

### 5.3 Terminal (foot)

```bash
sudo apt install -y foot
```

`foot` ist ein schnelles, leichtgewichtiges Wayland-Terminal — perfekt für Phosh.

### 5.4 Einstellungen

Phosh bringt GNOME Settings mit. WLAN + Bluetooth sind standardmäßig drin.
Prüfen ob alles vorhanden ist:

```bash
sudo apt install -y gnome-control-center
```

---

## Phase 6 — Oberfläche anpassen

### 6.1 Phosh Homescreen aufräumen

Nur die 4 gewünschten Apps sollen auf dem Homescreen erscheinen.
Alle anderen Apps aus der App-Übersicht verstecken:

```bash
# Apps die nicht im Launcher erscheinen sollen:
mkdir -p ~/.local/share/applications

# Beispiel: Dateimanager verstecken
echo -e "[Desktop Entry]\nHidden=true" > ~/.local/share/applications/org.gnome.Nautilus.desktop
```

### 6.2 Phosh CSS (Aussehen)

Die `phosh.css` aus dem Repo unter:
```
~/.config/gtk-3.0/gtk.css
```
kopieren — das ist der Custom-Style der bereits erstellt wurde (dunkles Theme, blaue Akzente).

```bash
mkdir -p ~/.config/gtk-3.0
cp /pfad/zur/phosh.css ~/.config/gtk-3.0/gtk.css
```

### 6.3 Wallpaper / Hintergrund

Schlicht schwarz oder dunkelgrau:

```bash
gsettings set org.gnome.desktop.background picture-uri ''
gsettings set org.gnome.desktop.background primary-color '#0a0a0a'
```

### 6.4 Bootsplash (Plymouth)

Minimalistisch — einfach schwarzer Screen ohne Logo:

```bash
sudo apt install -y plymouth

# Theme auf "fade-in" setzen (sehr minimalistisch):
sudo plymouth-set-default-theme fade-in
sudo update-initramfs -u
```

Für eigenes Logo später: Plymouth Theme selbst erstellen (einfaches PNG reicht).

---

## Phase 7 — Sony Xperia Z3 (Hauptgerät)

Nach erfolgreichem Test auf dem Tab A7 dasselbe für das Z3.

Das Z3 nutzt einen **anderen SoC** (Qualcomm Snapdragon 801 / MSM8974), braucht also einen eigenen Kernel-Port. Postmarket OS hat bereits guten Z3-Support — das wäre die Basis.

Separater Plan folgt wenn Tab A7 läuft.

---

## Zusammenfassung: Reihenfolge

| Schritt | Was | Status |
|---|---|---|
| 1 | Kernel bauen (GitHub Actions) | 🔄 läuft |
| 2 | boot.img herunterladen | ⏳ wartet |
| 3 | TWRP + Droidian flashen | ⏳ wartet |
| 4 | System updaten, SSH einrichten | ⏳ wartet |
| 5 | Signal, WhatsApp, Terminal installieren | ⏳ wartet |
| 6 | Phosh anpassen, CSS, Wallpaper | ⏳ wartet |
| 7 | Sony Xperia Z3 | 🔜 später |
