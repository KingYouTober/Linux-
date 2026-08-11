# Droidian auf dem Samsung Galaxy Tab A7

Linux-Setup für das **Samsung Galaxy Tab A7 (SM-T500 / gta4lwifi)** mit einer minimalistischen Oberfläche und nur den wichtigsten Anwendungen.

## 🎯 Ziel des Projekts

Das Ziel ist ein möglichst einfaches und aufgeräumtes Linux-System auf dem Galaxy Tab A7.

Nach der Installation soll das Tablet hauptsächlich folgende Apps enthalten:

* 💬 **Signal** – über Axolotl
* 🟢 **WhatsApp** – als Chromium-Web-App
* ⚙️ **Einstellungen**
* 💻 **Terminal** – über `foot`

Zusätzlich wird die Oberfläche angepasst:

* dunkles Phosh-Design
* schwarzer Hintergrund
* möglichst wenige sichtbare System-Apps
* minimalistischer Bootscreen
* automatisierte Ersteinrichtung über `install.sh`

---

# 📁 Repository-Struktur

Die wichtigsten Dateien und Ordner im Repository:

```text
Linux-/
├── install.sh
│   └── Automatische Ersteinrichtung nach der Installation
│
├── configs/
│   └── phosh.css
│       └── Dunkles GTK-/Phosh-Theme
│
├── droidian/
│   ├── build.sh
│   │   └── Optionaler lokaler Docker-Build
│   │
│   ├── setup.sh
│   │   └── Optionales Skript zum Vorbereiten des Kernel-Repositories
│   │
│   └── defconfig-fragments/
│       └── halium.config
│           └── Zusätzliche Kernel-Konfiguration für Droidian
│
├── .github/
│   ├── Con.ini
│   │   └── pmbootstrap-Konfiguration
│   │
│   └── workflows/
│       └── Kerlen.yml
│           └── GitHub-Actions-Workflow zum Bauen des Kernels
```

Die meisten Nutzer müssen nur mit **GitHub Actions**, **`boot.img`** und anschließend **`install.sh`** arbeiten. Die Dateien unter `droidian/` sind hauptsächlich für den Build-Prozess gedacht.

---

# 🔨 Phase 1 – Kernel bauen

Der benötigte Kernel wird automatisch über **GitHub Actions** gebaut.

Der Workflow befindet sich hier:

```text
.github/workflows/Kerlen.yml
```

## GitHub Actions starten

1. Öffne das GitHub-Repository.
2. Gehe zu **Actions**.
3. Wähle den Workflow **Build Droidian Kernel (gta4lwifi)**.
4. Klicke auf **Run workflow**.
5. Warte, bis der Build erfolgreich abgeschlossen wurde.

Nach einem erfolgreichen Build wird ein Artifact erstellt.

Typischer Inhalt:

```text
artifacts/
├── Image.gz
├── *.dtb
├── boot.img
└── *.ko
```

### Bedeutung der Dateien

| Datei      | Bedeutung                            |
| ---------- | ------------------------------------ |
| `Image.gz` | Komprimierter Linux-Kernel           |
| `*.dtb`    | Device-Tree-Dateien für die Hardware |
| `boot.img` | Fertiges Android/Linux-Boot-Image    |
| `*.ko`     | Zusätzliche Kernel-Module            |

Für die Installation wird hauptsächlich die Datei **`boot.img`** benötigt.

> **Wichtig:** Nach dem Build das entsprechende `artifacts.zip` herunterladen und auf dem PC entpacken.

---

# 💻 Phase 2 – Tablet vorbereiten

## Voraussetzungen

Für die Installation wird ein Linux-/Ubuntu-PC empfohlen.

Installiere zunächst ADB und Fastboot:

```bash
sudo apt update
sudo apt install adb fastboot
```

Prüfe anschließend, ob die Programme installiert wurden:

```bash
adb --version
fastboot --version
```

---

## 🔓 Entwickleroptionen aktivieren

Auf dem Galaxy Tab A7 müssen die Entwickleroptionen und die USB-Debugging-Funktion aktiviert werden.

### 1. Entwickleroptionen aktivieren

Auf dem Tablet:

**Einstellungen → Über das Tablet → Softwareinformationen**

Danach etwa **7-mal auf „Buildnummer“** tippen.

Android zeigt anschließend an, dass die Entwickleroptionen aktiviert wurden.

### 2. Benötigte Optionen aktivieren

Öffne:

**Einstellungen → Entwickleroptionen**

Aktiviere:

* **OEM-Entsperrung**
* **USB-Debugging**

> ⚠️ Das Entsperren des Bootloaders kann einen Werksreset auslösen und dabei alle Daten auf dem Tablet löschen. Sichere wichtige Daten vorher.

---

# 🛠️ TWRP

Für die weiteren Installationsschritte wird **TWRP** verwendet.

Offizielle TWRP-Seite:

https://twrp.me/samsung/samsunggalaxytaba72020wifi.html

Lade die passende TWRP-Datei für das **Samsung Galaxy Tab A7 WiFi / SM-T500 / gta4lwifi** herunter.

Lege die Datei anschließend beispielsweise als:

```text
twrp-gta4lwifi.img
```

in deinen aktuellen Arbeitsordner.

---

# ⚡ Tablet in den benötigten Modus starten

Verbinde das Tablet mit dem PC und starte es in den Bootloader/Fastboot-Modus.

Anschließend kann TWRP je nach unterstütztem Bootloader-Verfahren gestartet werden.

Beispiel:

```bash
fastboot boot twrp-gta4lwifi.img
```

### ⚠️ Wichtig

Dieser Befehl versucht, TWRP **temporär zu starten**, anstatt TWRP dauerhaft als Recovery zu installieren.

Welche Bootloader-/Recovery-Methode auf deinem SM-T500 tatsächlich unterstützt wird, hängt von der verwendeten Firmware und dem aktuellen Gerätestand ab. Bei Problemen deshalb nicht einfach weitere Images flashen, sondern zuerst den genauen Fastboot-/Download-Mode des Geräts prüfen.

---

# 📦 Phase 3 – Droidian installieren

Jetzt werden das eigene Kernel-Image und das Droidian-Rootfs installiert.

## 1. Droidian Rootfs herunterladen

Das verwendete Rootfs kann aus dem offiziellen Droidian-Release heruntergeladen werden:

```bash
wget https://github.com/droidian-images/rootfs-api29gsi-all/releases/latest/download/droidian-ROOTFS-arm64.zip
```

Die Datei ist für **ARM64-Geräte** gedacht, was zum Galaxy Tab A7 passt.

---

## 2. Eigenes `boot.img` flashen

Nachdem das Artifact aus GitHub Actions entpackt wurde:

```bash
fastboot flash boot artifacts/boot.img
```

Dabei wird das zuvor gebaute Boot-Image auf die Boot-Partition des Tablets geschrieben.

> ⚠️ Vergewissere dich unbedingt, dass `artifacts/boot.img` tatsächlich für das **SM-T500 / gta4lwifi** gebaut wurde. Ein falsches Boot-Image kann dazu führen, dass das Gerät nicht mehr normal startet.

---

## 3. Droidian-Rootfs über TWRP installieren

Starte TWRP und wähle:

```text
Install
```

Danach:

```text
droidian-ROOTFS-arm64.zip
```

auswählen und den Flash-Vorgang bestätigen.

Nach erfolgreicher Installation:

```text
Reboot → System
```

Beim ersten Start kann der Bootvorgang länger dauern als gewöhnlich.

---

# 🔐 Standard-Zugangsdaten

Nach erfolgreicher Installation wird zunächst der Standardbenutzer verwendet:

```text
Benutzer: droidian
Passwort: 1234
```

> ⚠️ Ändere das Passwort nach der ersten Anmeldung möglichst zeitnah.

---

# 🧰 Phase 4 – Ersteinrichtung mit `install.sh`

Nach dem ersten Start wird das System mit dem Script

```text
install.sh
```

automatisch eingerichtet.

Das Script übernimmt einen großen Teil der Konfiguration, sodass nicht alle Einstellungen manuell vorgenommen werden müssen.

---

## 🔌 SSH über USB verwenden

Zuerst wird vom PC eine Weiterleitung von TCP-Port `2222` zum SSH-Port des Tablets eingerichtet:

```bash
adb forward tcp:2222 tcp:22
```

Danach kannst du dich per SSH verbinden:

```bash
ssh -p 2222 droidian@localhost
```

Passwort:

```text
1234
```

---

## ⬇️ `install.sh` herunterladen

Im Droidian-System:

```bash
wget https://raw.githubusercontent.com/KingYouTober/Linux-/main/install.sh
```

Danach das Script mit Root-Rechten starten:

```bash
sudo bash install.sh
```

Nach erfolgreicher Einrichtung:

```bash
sudo reboot
```

---

# ⚙️ Was macht `install.sh`?

Das Script übernimmt automatisch mehrere Einrichtungsschritte.

### 🔄 System aktualisieren

Das installierte System wird zuerst aktualisiert, damit die benötigten Pakete möglichst auf dem aktuellen Stand sind.

### 📶 WLAN einrichten

Das Script fragt interaktiv nach:

```text
SSID:
Passwort:
```

Die eingegebenen Daten werden zur WLAN-Konfiguration verwendet.

### 💬 Signal installieren

Signal wird über **Axolotl** eingerichtet.

### 🟢 WhatsApp installieren

WhatsApp wird als **Chromium-PWA** eingerichtet.

Dadurch erscheint WhatsApp wie eine normale Anwendung im App-Drawer.

### 💻 Terminal installieren

Als minimalistisches Terminal wird:

```text
foot
```

installiert.

### ⚙️ Einstellungen installieren

Die benötigte GNOME-/GTK-Einstellungsoberfläche wird eingerichtet.

### 🎨 Phosh anpassen

Die Datei:

```text
configs/phosh.css
```

wird verwendet, um Phosh optisch anzupassen.

Dabei wird ein dunkleres/minimalistisches Erscheinungsbild verwendet.

### 🏠 Homescreen aufräumen

Nicht benötigte System-Apps werden nach Möglichkeit aus der sichtbaren Oberfläche ausgeblendet.

Ziel ist ein möglichst einfacher App-Drawer mit hauptsächlich:

```text
Signal
WhatsApp
Einstellungen
Terminal
```

### 🌑 Hintergrund

Der Hintergrund wird auf einen sehr dunklen Farbwert gesetzt:

```text
#0a0a0a
```

### 🚀 Bootscreen

Der Plymouth-Bootscreen wird auf ein möglichst minimalistisches Erscheinungsbild angepasst.

---

# 🔄 Phase 5 – Nach dem Neustart

Nach dem Reboot sollte das Tablet mit der eingerichteten Phosh-Oberfläche starten.

Die wichtigsten Apps befinden sich anschließend im App-Drawer.

| Anwendung        | Start                          |
| ---------------- | ------------------------------ |
| 💬 Signal        | App-Drawer → **Axolotl**       |
| 🟢 WhatsApp      | App-Drawer → **WhatsApp**      |
| 💻 Terminal      | App-Drawer → **foot**          |
| ⚙️ Einstellungen | App-Drawer → **Einstellungen** |

## WhatsApp verbinden

Beim ersten Start von WhatsApp wird ein QR-Code angezeigt.

Diesen QR-Code kannst du mit dem bereits verwendeten WhatsApp-Konto über dein Smartphone verknüpfen.

---

# 👻 Weitere Apps ausblenden

Falls nach der Installation noch eine nicht benötigte Anwendung sichtbar ist, kann deren Desktop-Datei für den Benutzer ausgeblendet werden.

Beispiel:

```bash
echo -e '[Desktop Entry]\nHidden=true' \
> ~/.local/share/applications/APPNAME.desktop
```

Dabei muss:

```text
APPNAME.desktop
```

durch den tatsächlichen Dateinamen der Anwendung ersetzt werden.

---

# 🧪 Fehlerbehebung

## Tablet startet nicht

Prüfe zunächst:

* Wurde das richtige `boot.img` verwendet?
* Wurde das Image für **SM-T500 / gta4lwifi** gebaut?
* Wurde der Flash-Vorgang ohne Fehler abgeschlossen?
* Kann das Gerät noch in den Bootloader-/Recovery-Modus gestartet werden?

Nicht mehrere unbekannte Images nacheinander flashen, ohne vorher die verwendete Partition und Firmware zu prüfen.

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
