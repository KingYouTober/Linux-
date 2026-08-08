# Droidian Kernel — Samsung Galaxy Tab A7 (SM-T500 / gta4lwifi)

Dieses Verzeichnis enthält alles was nötig ist, um den Linux-Kernel
für das SM-T500 als Droidian-kompatibles `.deb`-Paket zu bauen.

## Gerät

| Eigenschaft | Wert |
|---|---|
| Modell | Samsung Galaxy Tab A7 (2020) |
| Modellnummer | SM-T500 (WiFi) |
| Codename | gta4lwifi |
| SoC | Qualcomm Snapdragon 662 (sm7125) |
| Kernel | 4.19 |
| Android-Basis | Android 10 |

## Schnellstart (lokal)

```bash
# Schritt 1: Kernel klonen und Branch vorbereiten
bash droidian/setup.sh

# Schritt 2: Kernel kompilieren (braucht Docker)
bash droidian/build.sh
```

Die fertigen `.deb`-Pakete landen in `~/droidian/packages/`.

## Über GitHub Actions

Der Workflow `.github/workflows/build-kernel.yml` baut den Kernel
automatisch bei jedem Push auf Dateien unter `droidian/`.
Die `.deb`-Pakete sind danach als Artifacts herunterladbar.

## Verzeichnisstruktur

```
droidian/
├── README.md               # Diese Datei
├── setup.sh                # Kernel klonen + Branch vorbereiten
├── build.sh                # Docker-Build starten
├── debian/
│   ├── kernel-info.mk      # Gerätespezifische Build-Config
│   ├── rules               # Debian-Build-Regeln
│   ├── compat              # Debian-Compat-Level
│   └── source/
│       └── format          # Paketformat
└── defconfig-fragments/
    └── halium.config       # Halium/Droidian Kernel-Optionen
```

## Was die Pakete enthalten

Nach dem Build entstehen drei `.deb`-Pakete:

- `linux-image-*` — Der Kernel selbst
- `linux-headers-*` — Kernel-Header (für Module)
- `linux-bootimage-*` — Das fertige `boot.img` für das Tablet

## Nächste Schritte nach dem Build

→ Siehe Hauptdokument `droidian-gta4lwifi-plan.md` (Phase 3–5)
