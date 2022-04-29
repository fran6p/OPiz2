#!/bin/bash
# Installation d'Octoprint
# F. Poulizac (fran6p)
# La majorité des commandes vient de ce lien https://community.octoprint.org/t/setting-up-octoprint-on-a-raspberry-pi-running-raspbian/2337 
# 

# Liste de greffons (plugins) 'indispensables' (à modifier éventuellement)
# Dashboard, DisplayLayerProgress, FirmwareUpdater, PrintTimeGenius, UICustomizer, BackupScheduler, Resource-Monitor,
# Preheat, GPIO-Status, MultipleUpload, NetworkHealth, AutoLoginConfig
OCTOPRINT_PLUGINS=( "https://github.com/j7126/OctoPrint-Dashboard/archive/master.zip"
                    "https://github.com/OllisGit/OctoPrint-DisplayLayerProgress/releases/latest/download/master.zip"
                    "https://github.com/OctoPrint/OctoPrint-FirmwareUpdater/archive/master.zip"
                    "https://github.com/eyal0/OctoPrint-PrintTimeGenius/archive/master.zip"
                    "https://github.com/LazeMSS/OctoPrint-UICustomizer/archive/main.zip"
                    "https://github.com/jneilliii/OctoPrint-BackupScheduler/archive/master.zip"
                    "https://github.com/Renaud11232/OctoPrint-Resource-Monitor/archive/master.zip"
                    "https://github.com/marian42/octoprint-preheat/archive/master.zip"
                    "https://github.com/danieleborgo/OctoPrint-GPIOStatus/archive/master.zip"
                    "https://github.com/eyal0/OctoPrint-MultipleUpload/archive/master.zip"
                    "https://github.com/jonfairbanks/OctoPrint-NetworkHealth/archive/master.zip"                    
                    "https://github.com/OctoPrint/OctoPrint-AutoLoginConfig/releases/latest/download/release.zip"            
)

if ! [ $(id -u) -ne 0 ]; then
	echo "Ce script ne doit pas être exécuté en tant que «root»"
	echo 
	echo "L'installation se fait en tant qu'utilisateur pi"
	exit 1
fi

echo && read -p "L'installation des paquets requis a été faite? (o/n)" -n 1 -r -s installRequis && echo
if [[ $installRequis != "O" && $installRequis != "o" ]]; then
	echo "Installation d'Octoprint annulée."
	echo
	echo "Lancer le script suivant en tant qu'utilisateur «root» :"
	echo " ./2-installation-paquets.sh"
	exit 1
fi
clear
echo && read -p "Voulez-vous installer le serveur Octoprint ? (o/n)" -n 1 -r -s installOcto && echo
if [[ $installOcto != "O" && $installOcto != "o" ]]; then
	echo "Installation d'Octoprint annulée."
	exit 1
fi
clear
#######################OctoPrint#############################
# Les paquets requis pour octoprint sont normalement installés
# PAQUETS REQUIS: python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential

# Configurer l'environnement et le paramétrage d'Octoprint
echo "Installation de Octoprint"
echo

mkdir OctoPrint
cd OctoPrint
python3 -m venv venv
source venv/bin/activate
pip install pip --upgrade
pip install --no-cache-dir Octoprint
deactivate
cd ~

#Premier lancement du serveur. Si tout OK, le dossier caché .octoprint doit avoir été créé.
# Il faut stopper manuellement le serveur pour poursuivre l'installation via CTRL+C 
echo && read -p "Lancement du serveur.\
Pour l'arrêter et poursuivre l'installation: CTRL+C \
 \
Presser ENTRÉE pour procéder" && echo
./OctoPrint/venv/bin/octoprint serve

# Installation des plugins 'indispensables'
echo "Installation de quelques greffons :"
echo "Dashboard, DisplayLayerProgress, FirmwareUpdater, PrintTimeGenius,
echo "UICustomizer, BackupScheduler, Resource-Monitor, Preheat,
echo "GPIO-Status, MultipleUpload, NetworkHealth, AutoLoginConfig"
echo
cd /home/pi
for greffon in "${OCTOPRINT_PLUGINS}"
  do
    /home/pi/OctoPrint/venv/bin/pip --no-cache-dir install ${greffon}
  done

# Mjpeg-streamer
# PAQUETS REQUIS: subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake
clear
echo "Installation de MJPEG-STREAMER"
echo
git clone https://github.com/jacksonliam/mjpg-streamer.git
cd /home/pi/mjpg-streamer/mjpg-streamer-experimental
export LD_LIBRARY_PATH=.
make
cd /home/pi

# Nettoyage: supprimer le fichier d'installation
rm -f 3-install-octo-only.sh
