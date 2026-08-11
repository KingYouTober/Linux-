# Droidian — Samsung Galaxy Tab A7 (SM-T500 / gta4lwifi)

**Ziel:** Linux mit minimalistischer Oberfläche, 4 Apps (Signal, WhatsApp, Einstellungen, Terminal), sauberer Boot.

---

## Repo-Struktur

```
Linux-/
├── install.sh                          ← Ersteinrichtung nach dem Flash (alles automatisch)
├── configs/
│   └── phosh.css                       ← Dunkles GTK-Theme für Phosh
├── droidian/
│   ├── build.sh                        ← Lokaler Docker-Build (optional)
│   ├── setup.sh                        ← Lokaler Kernel-Clone (optional)
│   └── defconfig-fragments/
│       └── halium.config               ← Droidian Kernel-Optionen
└── .github/
    ├── Con.ini                         ← pmbootstrap Config
    └── workflows/
        └── Kerlen.yml                  ← GitHub Actions: Kernel bauen
```

---

## Phase 1 — Kernel bauen ✅

Kernel wird via **GitHub Actions** gebaut → `.github/workflows/Kerlen.yml`

**Manuell auslösen:** GitHub → Actions → *Build Droidian Kernel (gta4lwifi)* → Run workflow

Artifacts nach dem Build:
```
artifacts/
├── Image.gz        ← Kernel
├── *.dtb           ← Device Tree
├── boot.img        ← Fertig zum Flashen
└── *.ko            ← Kernel-Module
```

**→ artifacts.zip herunterladen und entpacken.**

---

## Phase 2 — Gerät vorbereiten

**Voraussetzungen am PC:**
```bash
sudo apt install adb fastboot
```

**Developer Mode + OEM Unlock auf dem Tablet:**
1. Einstellungen → Über das Tablet → Software-Informationen
2. 7× auf **Build-Nummer** tippen
3. Entwickleroptionen → **OEM-Entsperrung** + **USB-Debugging** aktivieren

**TWRP herunterladen:** https://twrp.me/samsung/samsunggalaxytaba72020wifi.html

**Tablet in Fastboot bringen:** Power + Volume Down halten bis Fastboot-Screen erscheint

```bash
# TWRP temporär booten (nicht permanent flashen!):
fastboot boot twrp-gta4lwifi.img
```

---

## Phase 3 — Droidian installieren

```bash
# 1. Droidian Rootfs herunterladen:
wget https://github.com/droidian-images/rootfs-api29gsi-all/releases/latest/download/droidian-ROOTFS-arm64.zip

# 2. Eigenes boot.img flashen:
fastboot flash boot artifacts/boot.img
```

**Im TWRP:**
1. Install → `droidian-ROOTFS-arm64.zip` wählen
2. Swipe zum Flashen
3. Reboot → System

**Standard-Login:** User `droidian` / Passwort `1234`

---

## Phase 4 — Ersteinrichtung (install.sh)

SSH über USB verbinden:
```bash
# Am PC:
adb forward tcp:2222 tcp:22
ssh -p 2222 droidian@localhost
# Passwort: 1234
```

Script laden und ausführen — **richtet alles automatisch ein:**
```bash
wget https://raw.githubusercontent.com/KingYouTober/Linux-/main/install.sh
sudo bash install.sh
sudo reboot
```

**Was install.sh macht:**
- System-Update
- WLAN einrichten (interaktiv, fragt nach SSID + Passwort)
- Signal (Axolotl via Flatpak) installieren
- WhatsApp (Chromium PWA) installieren + Desktop-Entry anlegen
- foot Terminal installieren
- GNOME Einstellungen installieren
- Phosh CSS (dunkles Theme) aus `configs/phosh.css` anwenden
- Homescreen auf 4 Apps reduzieren (alle System-Apps verstecken)
- Hintergrund auf Schwarz (`#0a0a0a`) setzen
- Plymouth Bootsplash auf minimalistisch setzen

---

## Phase 5 — Nach dem Reboot

| App | Starten |
|---|---|
| **Signal** | App-Drawer → Axolotl |
| **WhatsApp** | App-Drawer → WhatsApp → QR-Code mit Handy scannen |
| **Terminal** | App-Drawer → foot |
| **Einstellungen** | App-Drawer → Einstellungen |

Weitere Apps manuell verstecken falls nötig:
```bash
echo -e '[Desktop Entry]\nHidden=true' > ~/.local/share/applications/APPNAME.desktop
```

---

## Phase 6 — Sony Xperia Z3 (später)

Nach erfolgreichem Test auf dem Tab A7 dasselbe für das Z3.  
Das Z3 braucht einen eigenen Kernel (Snapdragon 801 / MSM8974) — PostmarketOS als Basis.  
Separater Plan folgt wenn Tab A7 stabil läuft.

---

## Status

| Schritt | Was | Status |
|---|---|---|
| 1 | Kernel bauen (GitHub Actions) | ✅ |
| 2 | boot.img herunterladen | ⏳ |
| 3 | TWRP + Droidian flashen | ⏳ |
| 4 | `sudo bash install.sh` | ⏳ |
| 5 | Reboot, WhatsApp QR-Code scannen | ⏳ |
| 6 | Sony Xperia Z3 | 🔜 |
