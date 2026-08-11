# Droidian – Samsung Galaxy Tab A7 Wi-Fi

**Droidian-Port für das Samsung Galaxy Tab A7 (SM-T500 / `gta4lwifi`)**

> ⚠️ **Projektstatus: Experimental / eigener Port**
>
> Das SM-T500 wird derzeit **nicht offiziell von Droidian unterstützt**. Ziel dieses Projekts ist es, Droidian selbst für das `gta4lwifi` zu portieren.

---

## 🎯 Projektziel

Minimalistisches Linux-System auf dem **Samsung Galaxy Tab A7 Wi-Fi** als Testgerät.

| Eigenschaft | Wert |
|---|---|
| Modell | `SM-T500` |
| Codename | `gta4lwifi` |
| SoC | Qualcomm SM7125 / Snapdragon 662 |
| Architektur | ARM64 |
| Kernel | 4.19.315 (HeribertYavuz) |
| Halium-Basis | Halium 12 |
| Oberfläche | Phosh |
| Linux-System | Droidian |

**Geplante Apps:**
- 💬 Signal (via Axolotl)
- 🟢 WhatsApp (als Web-App / PWA)
- ⚙️ Einstellungen (WLAN, Bluetooth)
- 💻 Terminal
- 🌑 Dunkles minimalistisches Design
- 🚀 Minimalistischer Bootscreen

---

## 📁 Repository-Struktur

```
Linux-/
│
├── README.md
├── install.sh                          ← Oberfläche einrichten (nach erstem Boot)
│
├── configs/
│   └── phosh.css                       ← Dunkles Phosh-Theme
│
├── droidian/
│   ├── build.sh                        ← Lokaler Build
│   ├── setup.sh                        ← Build-Umgebung vorbereiten
│   ├── README.md                       ← Kernel-Build Doku
│   └── defconfig-fragments/
│       └── halium.config               ← Halium/Droidian Kernel-Optionen
│
└── .github/
    ├── Con.ini                         ← Build-Konfiguration
    └── workflows/
        └── Kerlen.yml                  ← GitHub Actions Kernel-Build
```

> **Branch `kernel`** enthält den vollständigen Kernel-Source (automatisch von GitHub Actions aus [HeribertYavuz/android_kernel_samsung_gta4l](https://github.com/HeribertYavuz/android_kernel_samsung_gta4l) synchronisiert). Nicht manuell bearbeiten.

---

## ⚠️ Wichtig: Kein TWRP für das SM-T500

Das SM-T500 ist kein normales Fastboot-Gerät. Es gibt **kein offizielles TWRP** für dieses Gerät.

Der Flash-Weg läuft über **Samsung Download Mode** (Heimdall oder Odin):

```
Samsung Download Mode
        │
        ▼
VBMeta / AVB deaktivieren
        │
        ▼
boot.img flashen (Droidian-Kernel)
        │
        ▼
Droidian Rootfs
        │
        ▼
Halium Android Container
        │
        ▼
Phosh
```

Der genaue Flash-Ablauf wird erst festgelegt wenn der Port vollständig gebaut ist.

---

## 🏗️ Entwicklungsstand

| Schritt | Aufgabe | Status |
|---|---|---|
| 1 | SM-T500 Kernel-Quellen beschaffen | ✅ |
| 2 | Kernel-Bugs fixen (LLVM_IAS, yylloc, P85946 DTBO) | ✅ |
| 3 | Halium-Kernel-Optionen (halium.config) | ✅ |
| 4 | GitHub Actions Build-Workflow | ✅ |
| 5 | Kernel bauen | 🔨 |
| 6 | boot.img testen (Samsung Download Mode) | ⏳ |
| 7 | Droidian Adaptation Package erstellen | ⏳ |
| 8 | Droidian Rootfs integrieren | ⏳ |
| 9 | Erster Droidian-Boot | ⏳ |
| 10 | Hardware testen (WLAN, Touch, Audio) | ⏳ |
| 11 | Phosh konfigurieren | ⏳ |
| 12 | Signal, WhatsApp, Terminal installieren | ⏳ |
| 13 | Minimalistische Oberfläche | 🔜 |

---

## 🔧 Kernel

### Kernel-Quelle

Wir verwenden [HeribertYavuz/android_kernel_samsung_gta4l](https://github.com/HeribertYavuz/android_kernel_samsung_gta4l) (Branch `14.0`, Kernel **4.19.315**) statt des originalen Samsung-Quellcodes (4.19.81) weil:

- 234 LTS-Patchlevel mehr (mehr Security-Fixes)
- Alle Build-Bugs bereits gefixt (LLVM_IAS, `empty.o` HOSTCC, `--prefix notdir`)
- EROFS-Support aktiviert
- Kompiliert sauber mit Clang 14 + LLVM_IAS=1

### Kernel bauen (GitHub Actions)

Der Workflow wird manuell ausgelöst:

**Actions → Build Droidian Kernel (gta4lwifi) → Run workflow**

Zwei Optionen beim Start:
- `sync: false` (Standard) — direkt bauen mit dem vorhandenen `kernel`-Branch (~20min, ab 2. Run ~5min via ccache)
- `sync: true` — Kernel zuerst von Heribert neu synchronisieren, dann bauen

**Ergebnis:** `boot.img`, `Image.gz`, DTBs und Module als herunterladbare Artifacts.

### Behobene Build-Fehler

| Fehler | Ursache | Fix |
|---|---|---|
| `/usr/bin/as: unrecognized option '-EL'` | Clang nutzte x86-Host-Assembler | `LLVM_IAS=1` |
| `multiple definition of 'yylloc'` | GCC 10+ `-fno-common` Standard | Im Heribert-Repo bereits gefixt |
| `empty.o` mit CC statt HOSTCC | Samsung Makefile-Bug | Im Heribert-Repo bereits gefixt |
| `P85946-qrd-overlay: Assertion 'generate_fixups' failed` | Kaputte DTB eines anderen Geräts | Im Workflow via `sed` entfernt |

### Halium Kernel-Optionen (`halium.config`)

Wichtigste Optionen die zum Standard-Defconfig hinzugefügt werden:

```
CONFIG_DEVTMPFS=y
CONFIG_VT=y
CONFIG_NAMESPACES=y
CONFIG_OVERLAY_FS=y
CONFIG_IKCONFIG=y
CONFIG_AUDIT=y
CONFIG_ANDROID_PARANOID_NETWORK=n
CONFIG_ANDROID_BINDERFS=n
CONFIG_SW_SYNC=y
```

---

## 🧩 Bekannter Halium-Unterbau

Für das SM-T500 existiert ein Community-Port:

```
Ubuntu Touch 24.04
      │
      └── Halium 12
            │
            └── LineageOS 19.1 / Android 12
```

Laut aktuellem Portstatus funktionieren bereits:
- ✅ Boot
- ✅ Touchscreen
- ✅ WLAN
- ✅ Lautsprecher
- ✅ Lautstärketasten
- 🟡 Bluetooth (noch nicht vollständig)
- 🟡 Kamera (noch nicht vollständig)

Dieser Halium-12-Unterbau ist die Basis für den Droidian-Port.

---

## 🖥️ Geplante Oberfläche

```
┌─────────────────────────────┐
│  Phosh – minimalistisch     │
│                             │
│   💬  Signal                │
│   🟢  WhatsApp              │
│   ⚙️  Einstellungen         │
│   💻  Terminal              │
│                             │
└─────────────────────────────┘
```

- **Signal** → Axolotl (nativer Linux-Phone-Client)
- **WhatsApp** → Chromium PWA (`--app=https://web.whatsapp.com`)
- **Einstellungen** → GNOME Control Center (WLAN, Bluetooth, Display)
- **Terminal** → foot (leichtgewichtiges Wayland-Terminal)
- **Theme** → `configs/phosh.css` (dunkel, blaue Akzente)

---

## 🔐 Samsung VBMeta / AVB

Das SM-T500 verwendet Samsungs Verified Boot. Für den Custom-Port muss VBMeta deaktiviert werden. Die konkrete `vbmeta.img` muss immer zur verwendeten Halium-Basis passen — keine generische Datei verwenden.

---

## 🐞 Debugging

### Halium-Container prüfen
```bash
lxc-ls --fancy
```

### Container-Logs
```bash
lxc-start -n android --logfile=/tmp/lxclog --logpriority=DEBUG
```

### Kernel-Logs nach Absturz (Pstore)
```bash
ls /sys/fs/pstore
```

---

## 📚 Quellen

- **Droidian Porting Guide:** https://docs.droidian.org/porting-guide/
- **Droidian Kernel Compilation:** https://docs.droidian.org/porting-guide/kernel-compilation/
- **Kernel-Quelle (Heribert):** https://github.com/HeribertYavuz/android_kernel_samsung_gta4l
- **postmarketOS Device Wiki:** https://wiki.postmarketos.org/wiki/Samsung_Galaxy_Tab_A7_(samsung-gta4lwifi)
- **Ubuntu Touch Community-Port:** https://sourceforge.net/projects/ubuntu-touch-galaxy-tab-a7/erwendete Partition und Firmware zu prüfen.

---

## SSH funktioniert nicht

Prüfe zuerst ADB:

```bash
adb devices
```

Das Tablet sollte in der Liste erscheinen.

Danach die Weiterleitung erneut setzen:

```bash
adb forward tcp:2222 tcp:22
```

Anschließend:

```bash
ssh -p 2222 droidian@localhost
```

---

## `install.sh` startet nicht

Prüfe, ob das Script vorhanden ist:

```bash
ls -l install.sh
```

Danach:

```bash
sudo bash install.sh
```

---

# 📱 Phase 6 – Sony Xperia Z3

Nachdem das Droidian-System auf dem **Galaxy Tab A7** erfolgreich getestet wurde, soll später zusätzlich ein Sony Xperia Z3 unterstützt werden.

Das Xperia Z3 benötigt jedoch einen **eigenen Kernel**, da es auf einer anderen Hardwareplattform basiert.

Geplant ist daher ein separates Setup:

```text
Galaxy Tab A7
└── gta4lwifi
    └── eigener Droidian-Kernel

Sony Xperia Z3
└── Snapdragon 801 / MSM8974
    └── eigener Kernel
```

Als mögliche Basis soll hierfür **postmarketOS** untersucht werden.

Die Arbeiten am Xperia Z3 beginnen erst, wenn das Tab-A7-Setup stabil funktioniert.

---

# 📊 Projektstatus

| Phase | Aufgabe                          | Status |
| ----- | -------------------------------- | ------ |
| 1     | Kernel über GitHub Actions bauen | ✅      |
| 2     | `boot.img` herunterladen         | ⏳      |
| 3     | TWRP vorbereiten                 | ⏳      |
| 4     | Droidian Rootfs installieren     | ⏳      |
| 5     | `install.sh` ausführen           | ⏳      |
| 6     | System neu starten und testen    | ⏳      |
| 7     | WhatsApp per QR-Code verbinden   | ⏳      |
| 8     | Sony Xperia Z3                   | 🔜     |

---

# ⚠️ Wichtige Hinweise

Dieses Projekt verändert die Software des Tablets auf System-/Boot-Ebene.

Bevor du mit dem Flashen beginnst:

* wichtige Daten sichern
* sicherstellen, dass das Gerät wirklich **SM-T500 / gta4lwifi** ist
* nur passende Images verwenden
* während eines Flash-Vorgangs das USB-Kabel nicht entfernen
* bei Fehlern zuerst die genaue Fehlermeldung prüfen, bevor weitere Partitionen verändert werden

Ein fehlerhaftes Image oder ein falscher Flash-Vorgang kann dazu führen, dass das Tablet nicht mehr normal startet.

---

# 📌 Kurzfassung

Der komplette Ablauf ist:

```text
1. GitHub Actions starten
        ↓
2. artifacts.zip herunterladen
        ↓
3. boot.img entpacken
        ↓
4. Tablet vorbereiten
        ↓
5. TWRP starten
        ↓
6. boot.img installieren
        ↓
7. Droidian Rootfs installieren
        ↓
8. Droidian starten
        ↓
9. Per ADB/SSH verbinden
        ↓
10. install.sh ausführen
        ↓
11. Neustart
        ↓
12. Minimalistisches Linux-System verwenden
```

Das gewünschte Endergebnis ist ein schlankes Droidian-System auf dem Galaxy Tab A7 mit einer möglichst einfachen Oberfläche und den vier wichtigsten Anwendungen.
