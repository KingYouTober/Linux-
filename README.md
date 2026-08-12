# Droidian – Samsung Galaxy Tab A7 Wi-Fi

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
│
├── README.md                           ← Diese Datei
├── install.sh                          ← Oberfläche einrichten (nach erstem Boot)
│
├── configs/
│   └── phosh.css                       ← Dunkles Phosh-Theme (blau/schwarz)
│
├── flash/
│   ├── flash.sh                        ← Flash-Script (Linux/Mac, Heimdall)
│   └── Readme.md                       ← Flash-Anleitung + Voraussetzungen
│
├── droidian/
│   ├── build.sh                        ← Lokaler Docker-Build (optional)
│   ├── setup.sh                        ← Lokale Build-Umgebung vorbereiten
│   ├── README.md                       ← Kernel-Build Dokumentation
│   └── defconfig-fragments/
│       └── halium.config               ← Halium/Droidian Kernel-Optionen
│
└── .github/
    ├── Con.ini                         ← Build-Konfiguration
    └── workflows/
        └── Kerlen.yml                  ← GitHub Actions Kernel-Build
```

> **Branch `kernel`** enthält den vollständigen Kernel-Source — automatisch via GitHub Actions aus [HeribertYavuz/android_kernel_samsung_gta4l](https://github.com/HeribertYavuz/android_kernel_samsung_gta4l) (Branch `14.0`, Kernel 4.19.315) synchronisiert. Nicht manuell bearbeiten.

---

## 📊 Entwicklungsstand

| Schritt | Aufgabe | Status |
|---|---|---|
| 1 | Kernel-Quelle (Heribert 4.19.315) beschaffen | ✅ |
| 2 | Kernel-Build-Bugs fixen (LLVM_IAS, P85946 DTBO) | ✅ |
| 3 | Halium Kernel-Optionen (`halium.config`) | ✅ |
| 4 | GitHub Actions Workflow mit ccache | ✅ |
| 5 | Kernel erfolgreich gebaut (`boot.img`) | ✅ |
| 6 | Flash-Script + Anleitung (`flash/`) | ✅ |
| 7 | Einrichtungs-Script (`install.sh`) | ✅ |
| 8 | Gerät vorbereiten + `vbmeta.img` + `boot.img` flashen | ⏳ |
| 9 | Droidian Rootfs flashen | ⏳ |
| 10 | Erster Droidian-Boot | ⏳ |
| 11 | Hardware testen (WLAN, Touch, Audio, Bluetooth) | ⏳ |
| 12 | Phosh + Apps einrichten (`install.sh` ausführen) | ⏳ |
| 13 | Droidian Adaptation Package erstellen | ⏳ |
| 14 | Stabiler Port | 🔜 |

---

## 🔧 Kernel bauen

**Actions → Build Droidian Kernel (gta4lwifi) → Run workflow**

| Option | Beschreibung |
|---|---|
| `sync: false` | Direkt bauen mit vorhandenem `kernel`-Branch (~20 Min, ab 2. Run ~5 Min via ccache) |
| `sync: true` | Erst Kernel von Heribert neu synchronisieren, dann bauen |

**Ergebnis:** ZIP-Datei (`droidian-gta4lwifi-DATUM.zip`) mit `boot.img`, `bengal.dtb`, `flash.sh` und Anleitung — fertig zum Flashen.

### Behobene Build-Fehler

| Fehler | Ursache | Fix |
|---|---|---|
| `/usr/bin/as: unrecognized option '-EL'` | x86-Host-Assembler statt ARM | `LLVM_IAS=1` |
| `multiple definition of 'yylloc'` | GCC 10+ `-fno-common` | Im Heribert-Repo bereits gefixt |
| `empty.o` mit CC statt HOSTCC | Samsung Makefile-Bug | Im Heribert-Repo bereits gefixt |
| `P85946: Assertion 'generate_fixups' failed` | Kaputte DTB eines anderen Geräts (Bengal QRD) | Via `sed` aus Makefile entfernt |

---

## 📲 Gerät vorbereiten

### 1. Developer Mode + OEM Unlock

1. **Einstellungen → Über das Tablet → Software-Informationen**
2. Siebenmal auf **Build-Nummer** tippen → Developer Mode aktiv
3. **Einstellungen → Entwickleroptionen → OEM-Entsperrung** aktivieren
4. **USB-Debugging** aktivieren
5. Neu starten → Entwickleroptionen nochmal öffnen und prüfen ob OEM-Entsperrung wirklich gesetzt ist

---

## 🔐 VBMeta — AVB deaktivieren

Das SM-T500 prüft beim Boot jedes Image kryptografisch (Android Verified Boot). Ohne Deaktivierung bootet kein Custom-Kernel.

**Lösung:** Eine leere `vbmeta.img` flashen → AVB deaktiviert → Gerät bootet jedes Image.

### vbmeta.img herunterladen

Die `vbmeta.img` kommt direkt von **LineageOS** — sie ist für das gta4lwifi gemacht und funktioniert auch für Droidian:

1. Geh zu: **https://download.lineageos.org/devices/gta4lwifi/builds**
2. Neueste Zeile → rechts den `vbmeta.img` Link herunterladen

> ⚠️ Niemals eine `vbmeta.img` von einem anderen Gerät verwenden.

### Heimdall (Linux/Mac)

Das SM-T500 benötigt eine **gepatchte Heimdall-Version** — das normale Heimdall funktioniert nicht:

```
https://androidfilehost.com/?w=files&flid=338156
```

### Download Mode starten

```
Tablet ausschalten
→ Volume Down + Volume Up gleichzeitig halten
→ USB-Kabel zum PC anschließen
→ Mit Volume Up bestätigen
```

### Flashen

**Linux/Mac:**
```bash
# vbmeta.img und boot.img in den flash/-Ordner kopieren
# heimdall ebenfalls dort hinein
cd flash/
./flash.sh
```

**Windows (Odin4):**
```
Odin4: https://github.com/Adrilaw/OdinV4
→ AP: vbmeta.img → Start → PASS! abwarten → NICHT neu starten
→ AP: boot.img   → Start → PASS! abwarten
→ Tablet manuell neu starten
```

---

## 💾 Droidian Rootfs

Nach dem ersten Boot mit dem Droidian-Kernel muss noch das Rootfs geflasht werden:

```
https://github.com/droidian-images/rootfs-api29gsi-all/releases/latest
```

Genaue Vorgehensweise folgt wenn der Kernel-Boot bestätigt ist.

---

## 🖥️ Oberfläche einrichten

Nach dem ersten erfolgreichen Droidian-Boot via SSH verbinden und `install.sh` ausführen:

```bash
# Am PC:
adb forward tcp:2222 tcp:22
ssh -p 2222 droidian@localhost
# Passwort: 1234

# Auf dem Tablet:
sudo bash install.sh
```

`install.sh` richtet automatisch ein:
- System-Update
- WLAN (interaktiv)
- Signal (Axolotl via Flatpak)
- WhatsApp (Chromium PWA)
- Terminal (foot)
- Einstellungen (GNOME Control Center)
- Dunkles Phosh-Theme (`configs/phosh.css`)
- Homescreen auf 4 Apps reduziert
- Schwarzer Hintergrund
- Plymouth Bootscreen (minimalistisch)

---

## 🧱 Halium-Basis

Für das SM-T500 existiert ein Community-Port auf Basis von LineageOS 19.1 / Android 12 / Halium 12.

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
- **LineageOS gta4lwifi (vbmeta.img):** https://download.lineageos.org/devices/gta4lwifi/builds
- **Heimdall (gepatchte Version):** https://androidfilehost.com/?w=files&flid=338156
- **XDA Thread:** https://xdaforums.com/t/official-sm-t505-sm-t505n-sm-t505c-sm-t507-gta4l-sm-t500-gta4lwifi-lineageos-23-2-for-galaxy-tab-a7-2020-lte-wifi-version.4576699/
- **postmarketOS Device Wiki:** https://wiki.postmarketos.org/wiki/Samsung_Galaxy_Tab_A7_(samsung-gta4lwifi)
