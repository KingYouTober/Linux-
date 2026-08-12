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
- 🟢 WhatsApp (als PWA)
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
├── configs/
│   └── phosh.css                       ← Dunkles Phosh-Theme
├── droidian/
│   ├── build.sh
│   ├── setup.sh
│   └── defconfig-fragments/
│       └── halium.config               ← Halium/Droidian Kernel-Optionen
└── .github/
    ├── Con.ini
    └── workflows/
        └── Kerlen.yml                  ← GitHub Actions Kernel-Build
```

> **Branch `kernel`** enthält den vollständigen Kernel-Source — automatisch via GitHub Actions aus [HeribertYavuz/android_kernel_samsung_gta4l](https://github.com/HeribertYavuz/android_kernel_samsung_gta4l) synchronisiert. Nicht manuell bearbeiten.

---

## 📊 Entwicklungsstand

| Schritt | Aufgabe | Status |
|---|---|---|
| 1 | Kernel-Quelle (Heribert 4.19.315) | ✅ |
| 2 | Kernel-Build-Bugs fixen | ✅ |
| 3 | Halium Kernel-Optionen (`halium.config`) | ✅ |
| 4 | GitHub Actions Workflow | ✅ |
| 5 | Kernel bauen | 🔨 |
| 6 | Gerät vorbereiten + `vbmeta.img` flashen | ⏳ |
| 7 | `boot.img` testen | ⏳ |
| 8 | Droidian Rootfs + Adaptation Package | ⏳ |
| 9 | Erster Droidian-Boot | ⏳ |
| 10 | Hardware testen (WLAN, Touch, Audio) | ⏳ |
| 11 | Phosh + Apps einrichten | ⏳ |

---

## 🔧 Kernel bauen (GitHub Actions)

**Actions → Build Droidian Kernel (gta4lwifi) → Run workflow**

Beim Start gibt es ein Dropdown:
- `sync: false` (Standard) → direkt bauen, ~20 Min (ab 2. Run ~5 Min via ccache)
- `sync: true` → erst Kernel von Heribert synchronisieren, dann bauen

**Ergebnis:** `boot.img`, `Image.gz`, DTBs und Kernel-Module als herunterladbare Artifacts.

---

## 📲 Gerät vorbereiten

### Schritt 1 — Developer Mode + OEM Unlock

1. **Einstellungen → Über das Tablet → Software-Informationen**
2. Siebenmal auf **Build-Nummer** tippen → Developer Mode aktiv
3. **Einstellungen → Entwickleroptionen → OEM-Entsperrung** aktivieren
4. **USB-Debugging** aktivieren
5. Tablet neu starten — nochmal in Entwickleroptionen gehen und prüfen ob OEM Unlock wirklich aktiv ist (Haken muss gesetzt sein)

---

## 🔐 VBMeta — was ist das und warum?

Das SM-T500 verwendet Samsungs **Android Verified Boot (AVB)**. Das bedeutet: Jedes Image (Kernel, Recovery, System) wird beim Boot digital signiert geprüft. Wenn ein fremdes `boot.img` geflasht wird, verweigert das Gerät den Boot.

Die Lösung: Eine **leere/deaktivierte `vbmeta.img`** flashen. Damit wird AVB deaktiviert und das Gerät bootet jedes signierte oder unsignierte Image.

> ⚠️ **Wichtig:** Die `vbmeta.img` muss zur Firmware-Version des Tablets passen. Niemals eine `vbmeta.img` von einem anderen Gerät oder einer anderen Firmware-Version verwenden.

### Schritt 2 — `vbmeta.img` herunterladen

Die `vbmeta.img` kommt direkt aus dem offiziellen **LineageOS-Build für gta4lwifi**:

1. Geh zu: **https://download.lineageos.org/devices/gta4lwifi/builds**
2. Lade den neuesten Nightly-Build herunter (`lineage-*-gta4lwifi-signed.zip`)
3. In der gleichen Zeile gibt es auch separat: **`vbmeta.img`** — diese Datei herunterladen

> Die LineageOS `vbmeta.img` ist eine leere, deaktivierte VBMeta-Partition und funktioniert für alle Custom-ROMs auf dem gta4lwifi — also auch für Droidian.

### Schritt 3 — Download Mode aktivieren

```
Tablet ausschalten
→ Volume Down + Volume Up gleichzeitig halten
→ USB-Kabel zum PC anschließen
→ Download Mode erscheint
→ Lautstärke Hoch drücken um zu bestätigen
```

### Schritt 4 — Heimdall installieren (Linux/Mac) oder Odin (Windows)

**Linux/Mac — Heimdall (gepatchte Version für gta4lwifi):**

Das normale Heimdall funktioniert **nicht** mit dem SM-T500. Es wird eine gepatchte Version benötigt:

```bash
# Gepatchtes Heimdall von androidfilehost herunterladen:
# https://androidfilehost.com/?w=files&flid=338156
# (Link aus dem offiziellen LineageOS XDA-Thread für gta4lwifi)

# Entpacken und ausführbar machen:
chmod +x heimdall
```

**Windows — Odin:**
```
Odin4 herunterladen: https://github.com/Adrilaw/OdinV4
```

### Schritt 5 — `vbmeta.img` flashen

**Linux/Mac (Heimdall):**
```bash
./heimdall flash --VBMETA vbmeta.img --no-reboot
```

**Windows (Odin):**
```
AP-Slot → vbmeta.img auswählen
→ Start
→ Warten bis PASS! erscheint
→ NICHT normal neu starten lassen
```

> ⚠️ Nach dem Flash **nicht normal booten lassen** — direkt in den nächsten Schritt gehen.

---

## 💾 Boot Image flashen

Nach dem `vbmeta.img` Flash direkt das Droidian `boot.img` aus den GitHub Actions Artifacts flashen:

**Linux/Mac (Heimdall):**
```bash
./heimdall flash --BOOT boot.img --no-reboot
```

**Windows (Odin):**
```
AP-Slot → boot.img auswählen
→ Start → PASS! abwarten
```

---

## 🧱 Halium-Basis

Für das SM-T500 existiert ein Community-Port auf Basis von LineageOS 19.1 / Android 12 / Halium 12. Laut aktuellem Portstatus funktionieren bereits:

- ✅ Boot, Touchscreen, WLAN, Lautsprecher, Lautstärketasten
- 🟡 Bluetooth, Kamera (noch nicht vollständig)

Dieser Unterbau ist die Basis für den Droidian-Port.

---

## 🐞 Debugging

```bash
# Halium-Container prüfen
lxc-ls --fancy

# Container-Logs
lxc-start -n android --logfile=/tmp/lxclog --logpriority=DEBUG

# Kernel-Logs nach Absturz (Pstore)
ls /sys/fs/pstore
```

---

## 📚 Quellen

- **Droidian Porting Guide:** https://docs.droidian.org/porting-guide/
- **Kernel-Quelle:** https://github.com/HeribertYavuz/android_kernel_samsung_gta4l
- **LineageOS gta4lwifi (vbmeta.img Quelle):** https://download.lineageos.org/devices/gta4lwifi/builds
- **LineageOS Install Wiki:** https://wiki.lineageos.org/devices/gta4lwifi/install/
- **XDA Thread (Heimdall + vbmeta):** https://xdaforums.com/t/official-sm-t505-sm-t505n-sm-t505c-sm-t507-gta4l-sm-t500-gta4lwifi-lineageos-23-2-for-galaxy-tab-a7-2020-lte-wifi-version.4576699/
- **postmarketOS Device Wiki:** https://wiki.postmarketos.org/wiki/Samsung_Galaxy_Tab_A7_(samsung-gta4lwifi)
