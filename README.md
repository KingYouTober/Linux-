# Droidian — Samsung Galaxy Tab A7 (SM-T500 / gta4lwifi)

**Eigener Droidian-Port für das Samsung Galaxy Tab A7 (SM-T500 / `gta4lwifi`)**

> ⚠️ **Projektstatus: In Entwicklung**
> Das SM-T500 wird nicht offiziell von Droidian unterstützt. Dieses Projekt portiert Droidian selbst auf das Gerät.

---

## 🎯 Projektziel

Minimalistisches Linux-System auf dem **Samsung Galaxy Tab A7 Wi-Fi** als Testgerät.

| Eigenschaft | Wert |
|---|---|
| Modell | SM-T500 |
| Codename | gta4lwifi |
| SoC | Qualcomm Snapdragon 662 (SM7125 / Bengal) |
| Architektur | ARM64 |
| Kernel | 4.19.315 (HeribertYavuz) |
| Halium-Basis | Halium 12 / LineageOS 19.1 |
| Oberfläche | Phosh |
| Linux-System | Droidian |

**Geplante Apps:**
- 💬 Signal (via Axolotl)
- 🟢 WhatsApp (als PWA via Chromium)
- ⚙️ Einstellungen (WLAN, Bluetooth)
- 💻 Terminal (foot)
- 🌑 Dunkles minimalistisches Design
- 🚀 Minimalistischer Bootscreen (Plymouth fade-in)

---

## 📁 Repository-Struktur

```
Linux-/
├── README.md
├── install.sh                          ← Oberfläche einrichten (nach erstem Boot)
├── configs/
│   └── phosh.css                       ← Dunkles Phosh-Theme (blau/schwarz)
├── droidian/
│   ├── build.sh                        ← Lokaler Docker-Build (optional)
│   ├── setup.sh                        ← Lokale Build-Umgebung vorbereiten
│   ├── README.md                       ← Kernel-Build Dokumentation
│   └── defconfig-fragments/
│       └── halium.config               ← Halium/Droidian Kernel-Optionen
└── .github/
    ├── Con.ini                         ← Build-Konfiguration
    └── workflows/
        └── Kerlen.yml                  ← GitHub Actions Kernel-Build
```

---

## 📊 Entwicklungsstand

| Schritt | Aufgabe | Status |
|---|---|---|
| 1 | Kernel-Quelle (Heribert 4.19.315) beschaffen | ✅ |
| 2 | Kernel-Build-Bugs fixen (LLVM_IAS, P85946 DTBO) | ✅ |
| 3 | Halium Kernel-Optionen (`halium.config`) | ✅ |
| 4 | GitHub Actions Workflow mit ccache | ✅ |
| 5 | Kernel erfolgreich gebaut (`boot.img`) | ✅ |
| 6 | Einrichtungs-Script (`install.sh`) | ✅ |
| 7 | Gerät vorbereiten (OEM Unlock) | ⏳ |
| 8 | `vbmeta.img` + `boot.img` flashen (Odin3) | ⏳ ← **du bist hier** |
| 9 | LineageOS Recovery flashen | ⏳ |
| 10 | Droidian Rootfs via `adb sideload` flashen | ⏳ |
| 11 | Erster Droidian-Boot | ⏳ |
| 12 | Hardware testen (WLAN, Touch, Audio, Bluetooth) | ⏳ |
| 13 | Phosh + Apps einrichten (`install.sh` ausführen) | ⏳ |
| 14 | Stabiler Port | 🔜 |

---

## 🔧 Kernel bauen

**Actions → Build Droidian Kernel (gta4lwifi) → Run workflow**

| Option | Beschreibung |
|---|---|
| `sync: false` | Direkt bauen (~20 Min, ab 2. Run ~5 Min via ccache) |
| `sync: true` | Erst Kernel von Heribert neu synchronisieren, dann bauen |

**Ergebnis:** ZIP mit `boot.img`, `bengal.dtb`, `Image.gz` — fertig zum Flashen.

### Behobene Build-Fehler

| Fehler | Fix |
|---|---|
| `/usr/bin/as: unrecognized option '-EL'` | `LLVM_IAS=1` |
| `multiple definition of 'yylloc'` | Im Heribert-Repo bereits gefixt |
| `P85946: Assertion 'generate_fixups' failed` | Via `sed` aus Makefile entfernt |

---

## 📲 Schritt 7 — Gerät vorbereiten

**Voraussetzungen am PC:** `adb` und `Odin3` installiert

**Developer Mode + OEM Unlock auf dem Tablet:**
1. Einstellungen → Über das Tablet → Software-Informationen
2. 7× auf **Build-Nummer** tippen
3. Entwickleroptionen → **OEM-Entsperrung** aktivieren
4. USB-Debugging aktivieren
5. Neu starten und prüfen ob OEM-Entsperrung noch aktiv ist

---

## 🔐 Schritt 8 — vbmeta.img + boot.img flashen

> Du hast `boot.img` und `vbmeta.img` bereits aus den GitHub Actions Artifacts.

Das SM-T500 prüft beim Boot jedes Image kryptografisch (Android Verified Boot / AVB).
Die `vbmeta.img` deaktiviert AVB → danach bootet der eigene Kernel.

> ⚠️ TWRP gibt es nicht für das SM-T500. Stattdessen wird **Odin3** + **LineageOS Recovery** verwendet.

### Download Mode starten

```
Tablet ausschalten
→ Volume Down + Volume Up + Power gleichzeitig halten
→ USB-Kabel zum PC anschließen
→ Mit Volume Up "Device unlock mode" bestätigen
```

### vbmeta.img flashen (Odin3)

**Odin3 herunterladen:** https://odindownload.com/ → Odin3 v3.13.1

```bash
# vbmeta.img als .tar verpacken (Odin3 braucht .tar):
tar --format=ustar -cvf vbmeta.tar vbmeta.img
```

In Odin3:
```
AP → vbmeta.tar auswählen → Start → PASS! abwarten
→ Tablet startet neu → Android Setup durchklicken (WLAN überspringen)
→ Danach Developer Mode + OEM Unlock nochmal aktivieren (wird zurückgesetzt)
```

### boot.img flashen (Odin3)

```bash
tar --format=ustar -cvf boot.tar boot.img
```

In Odin3:
```
AP → boot.tar auswählen → Start → PASS! abwarten
→ Tablet startet neu
```

---

## 🔁 Schritt 9 — LineageOS Recovery flashen

> TWRP gibt es nicht für das SM-T500. Die **LineageOS Recovery** übernimmt diese Rolle — sie kann per `adb sideload` jedes ZIP flashen, also auch das Droidian Rootfs.

### LineageOS Recovery herunterladen

```
https://download.lineageos.org/devices/gta4lwifi/builds
```

Neueste Zeile → `recovery.img` herunterladen.

### Als .tar verpacken und flashen

```bash
tar --format=ustar -cvf recovery.tar recovery.img
```

In Odin3:
```
Options → Auto Reboot DEAKTIVIEREN (wichtig!)
AP → recovery.tar auswählen → Start → PASS! abwarten
→ USB-Kabel trennen
```

### In Recovery booten

Sofort nach dem Flash (Tablet zeigt noch "Downloading..."):
```
Volume Up + Power halten → loslassen sobald Bildschirm schwarz wird
→ LineageOS Recovery startet
```

> ⚠️ Nicht warten — bootet das Tablet normal, überschreibt Samsung die Recovery wieder mit der Stock-Version.

---

## 💾 Schritt 10 — Droidian Rootfs flashen

### Droidian Rootfs herunterladen

```
https://github.com/droidian-images/rootfs-api29gsi-all/releases/latest
```

Datei: `droidian-ROOTFS-arm64_DATUM_arm64.zip`

### Daten löschen (Erstinstallation)

In der LineageOS Recovery:
```
Factory Reset → Format data / factory reset → "Format" bestätigen
→ Zurück zum Hauptmenü
```

> ⚠️ Löscht alle Daten auf dem Tablet.

### Rootfs via adb sideload flashen

In der LineageOS Recovery:
```
Apply Update → Apply from ADB
```

Am PC:
```bash
adb -d sideload droidian-ROOTFS-arm64_*.zip
```

Warten bis fertig. Falls die Ausgabe bei 47% hängt und `adb: failed to read command: Success` kommt — das ist normal, der Flash war erfolgreich.

### Reboot

```
In der Recovery → Reboot system now
```

Der **erste Boot dauert 3–5 Minuten** — Droidian richtet sich ein. Das ist normal.

---

## 🖥️ Schritt 11 — Erster Boot

Nach dem Boot erscheint der **Phosh Lockscreen** (Uhr auf schwarzem Hintergrund).

Standard-Login: PIN `1234`

### Via SSH verbinden (bequemer als Tippen auf dem Tablet)

```bash
# Am PC:
adb forward tcp:2222 tcp:22
ssh -p 2222 droidian@localhost
# Passwort: 1234
```

---

## ⚙️ Schritt 13 — Oberfläche einrichten (install.sh)

```bash
# Auf dem Tablet via SSH:
wget https://raw.githubusercontent.com/KingYouTober/Linux-/main/install.sh
sudo bash install.sh
sudo reboot
```

`install.sh` richtet automatisch ein:
- System-Update
- WLAN (interaktiv — fragt nach SSID und Passwort)
- Signal (Axolotl via Flatpak)
- WhatsApp (Chromium PWA — beim ersten Start QR-Code mit Handy scannen)
- Terminal (foot)
- Einstellungen (GNOME Control Center)
- Dunkles Phosh-Theme (`configs/phosh.css`)
- Homescreen auf 4 Apps reduziert
- Schwarzer Hintergrund
- Plymouth Bootscreen (minimalistisch)

---

## 🧱 Halium Hardware-Status

| Komponente | Status |
|---|---|
| Boot | ✅ |
| Touchscreen | ✅ |
| WLAN | ✅ |
| Lautsprecher | ✅ |
| Lautstärketasten | ✅ |
| Bluetooth | 🟡 teilweise |
| Kamera | 🟡 in Arbeit |

---

## 🐞 Debugging

```bash
# Halium-Container prüfen
lxc-ls --fancy

# Container-Logs
lxc-start -n android --logfile=/tmp/lxclog --logpriority=DEBUG

# Kernel-Logs nach Absturz
ls /sys/fs/pstore
```

---

## 📚 Quellen

- **Droidian Porting Guide:** https://docs.droidian.org/porting-guide/
- **Kernel-Quelle (Heribert):** https://github.com/HeribertYavuz/android_kernel_samsung_gta4l
- **LineageOS Recovery + vbmeta.img:** https://download.lineageos.org/devices/gta4lwifi/builds
- **LineageOS Installationsanleitung (gta4lwifi):** https://wiki.lineageos.org/devices/gta4lwifi/install/
- **Odin3:** https://odindownload.com/
- **XDA Thread:** https://xdaforums.com/t/official-sm-t505-sm-t505n-sm-t505c-sm-t507-gta4l-sm-t500-gta4lwifi-lineageos-23-2-for-galaxy-tab-a7-2020-lte-wifi-version.4576699/
- **postmarketOS Device Wiki:** https://wiki.postmarketos.org/wiki/Samsung_Galaxy_Tab_A7_(samsung-gta4lwifi)
