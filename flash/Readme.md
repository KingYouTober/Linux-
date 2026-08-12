=== Droidian Kernel Flash-Paket - SM-T500 gta4lwifi ===

Inhalt:
  boot.img       - Droidian-kompatibler Kernel
  bengal.dtb     - Device Tree fuer SM-T500
  flash.sh       - Flash-Script (Linux/Mac)
  LIES_MICH.txt  - Diese Datei

Bevor du flasht - das brauchst du:

  1. Gepatchtes Heimdall (Linux/Mac):
     https://androidfilehost.com/?w=files&flid=338156
     -> heimdall in diesen Ordner kopieren

  2. vbmeta.img (von LineageOS fuer gta4lwifi):
     https://download.lineageos.org/devices/gta4lwifi/builds
     -> neueste Zeile -> vbmeta.img herunterladen
     -> in diesen Ordner kopieren

  3. Droidian Rootfs (fuer spaeter):
     https://github.com/droidian-images/rootfs-api29gsi-all/releases/latest

Tablet vorbereiten:
  - Developer Mode aktiv
  - OEM Unlock aktiv (in Entwickleroptionen pruefen)

Download Mode starten:
  Tablet aus -> Vol Down + Vol Up halten -> USB anstecken -> bestaetigen

Dann flashen:
  Linux/Mac: ./flash.sh
  Windows:   Odin4 (https://github.com/Adrilaw/OdinV4)
             -> AP: vbmeta.img -> Start -> PASS
             -> AP: boot.img   -> Start -> PASS

Danach Droidian Rootfs flashen (siehe README im Repo).
