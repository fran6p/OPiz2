#!/bin/bash
# Installation d'Octoprint
# F. Poulizac (fran6p)
# La majorité des commandes vient de ce lien  :
# https://community.octoprint.org/t/setting-up-octoprint-on-a-raspberry-pi-running-raspbian/2337 
# 

# Utilisateur non priviligié (pi)
OCTO_USER="pi"

# Liste de greffons (plugins) 'indispensables' (à modifier éventuellement)
# Dashboard, DisplayLayerProgress, FirmwareUpdater, PrintTimeGenius, UICustomizer, BackupScheduler, Resource-Monitor,
# Preheat, MultipleUpload, NetworkHealth, AutoLoginConfig
OCTOPRINT_PLUGINS=( "https://github.com/j7126/OctoPrint-Dashboard/archive/master.zip"
                    "https://github.com/OllisGit/OctoPrint-DisplayLayerProgress/releases/latest/download/master.zip"
                    "https://github.com/OctoPrint/OctoPrint-FirmwareUpdater/archive/master.zip"
                    "https://github.com/eyal0/OctoPrint-PrintTimeGenius/archive/master.zip"
                    "https://github.com/LazeMSS/OctoPrint-UICustomizer/archive/main.zip"
                    "https://github.com/jneilliii/OctoPrint-BackupScheduler/archive/master.zip"
                    "https://github.com/Renaud11232/OctoPrint-Resource-Monitor/archive/master.zip"
                    "https://github.com/marian42/octoprint-preheat/archive/master.zip"
                    "https://github.com/eyal0/OctoPrint-MultipleUpload/archive/master.zip"
                    "https://github.com/jonfairbanks/OctoPrint-NetworkHealth/archive/master.zip"                    
                    "https://github.com/OctoPrint/OctoPrint-AutoLoginConfig/releases/latest/download/release.zip"            
)

if [ $(id -u) -ne 0 ]; then
	echo "Ce script bien qu'exécuté en tant que «root»"
	echo "effectue une partie de l'installation en tant qu'utilisateur $OCTO_USER"
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
# Les paquets requis pour octoprint sont installés
# PAQUETS REQUIS: python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential

# Configurer l'environnement et le paramétrage d'Octoprint
echo "Installation de Octoprint"
echo

cd /home/$OCTO_USER
su -c "python3 -m venv OctoPrint" -l $OCTO_USER
su -c "source OctoPrint/bin/activate" -l $OCTO_USER
su -c "/home/$OCTO_USER/OctoPrint/bin/pip install pip --upgrade" -l $OCTO_USER
su -c "/home/$OCTO_USER/OctoPrint/bin/pip install --no-cache-dir octoprint" -l $OCTO_USER

#Premier lancement du serveur. Si tout OK, le dossier caché .octoprint doit avoir été créé.
# Il faut stopper manuellement le serveur pour poursuivre l'installation via CTRL+C )
# !!! En fait non, le serveur est arrêté «automatiquement» après un délai de 20s
echo && echo "Lancement du serveur." && read -p "Presser une touche pour procéder" -n 1 -r -s OK && echo
cd /home/$OCTO_USER
su -c "/home/$OCTO_USER/OctoPrint/bin/octoprint serve &" -l $OCTO_USER

# On arrête «brutalement» le serveur octoprint lancé précédemment en tâche de fond (sinon en envoyant un CTRL+C, 
# le script «pense» qu'on veut l'arrêter et il se termine sans aller jusqu'à la fin :-( )
sleep 20
# pkill pourrait également fonctionner : pkill octoprint
kill $(pgrep octoprint)

# Installation des plugins 'indispensables' => c'est mon avis ;-) 
echo "Installation de quelques greffons :"
echo "Dashboard, DisplayLayerProgress, FirmwareUpdater, PrintTimeGenius,"
echo "UICustomizer, BackupScheduler, Resource-Monitor, Preheat,"
echo "MultipleUpload, NetworkHealth, AutoLoginConfig"
echo
echo "Il faudra évidemment les paramétrer !"
echo

cd /home/$OCTO_USER
for greffon in "${OCTOPRINT_PLUGINS[@]}"
  do
    su -c "/home/$OCTO_USER/OctoPrint/bin/pip --no-cache-dir install ${greffon}" -l $OCTO_USER
  done

# Mjpeg-streamer
# PAQUETS REQUIS: subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake
clear
echo "Installation de MJPEG-STREAMER"
echo
cd /home/$OCTO_USER
su -c "git clone --depth 1 https://github.com/jacksonliam/mjpg-streamer.git mjpg-streamer" -l $OCTO_USER
su -c "cd /home/pi/mjpg-streamer/mjpg-streamer-experimental && make" -l $OCTO_USER
cd /home/$OCTO_USER

# Installation d'Octoprint, compléments:
# - services :
#      - octoprint
#      - haproxy
#      - webcamd
# - modification config.yaml :
#      - commandes lancement, arrêt du système, redémarrage Octoprint
#      - profil pré-configuré (CR10)
#

# Créer le «service» pour un démarrage automatique d'OctoPrint
clear
echo "Création du service octoprint puis activation et démarrage du serveur"
echo
# Astuce pour mettre plusieurs lignes en tant que commentaires (évite de précéder chque ligne par un #)
<< FINCOMMENTAIRE
cat << EOF > "/home/pi/octoprint.service"
[Unit]
Description=Octoprint
After=network-online.target
Wants=network-online.target
 
[Service]
User=pi
Type=simple
ExecStart=/home/pi/OctoPrint/bin/octoprint serve

[Install]
WantedBy=multi-user.target
EOF
# Déplacer ce fichier service au bon endroit
mv /home/pi/octoprint.service /etc/systemd/system/octoprint.service
FINCOMMENTAIRE

# Méthode alternative et préférable : récupérer ce script directement sur le Githut d'Octoprint
wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service
# Remplacer l'utilisateur 'pi' en dur par celui correspondant à OCTO_USER
sed -i "s/pi/$OCTO_USER/" octoprint.service
# Modification de la ligne ExecStart de
# ExecStart=/home/pi/OctoPrint/venv/bin/octoprint à ExecStart=/home/OCTO_USER/OctoPrint/bin/octoprint
# Pour tenir compte de l'environnemet virtuel Python ( OctoPrint/venv/ en OctoPrint/ )
sed -i "s/venv\///" octoprint.service
# Déplacer ce fichier au bon endroit
mv octoprint.service /etc/systemd/system/octoprint.service
#Recharger les serrvices, activer l'auto-start puis démarrer le service OctoPrint
systemctl daemon-reload
systemctl enable octoprint
systemctl start octoprint

######################HAProxy###################################
# Installer HAProxy
# PAQUETS REQUIS: haproxy

# Créer le fichier de configuration de HAProxy
clear
echo "Configuration, activation et démarrage de HAPROXY"
echo
cat << EOF >> "/home/pi/haproxy.cfg"
global
    maxconn 4096
    user haproxy
    group haproxy
    daemon
    log 127.0.0.1 local0 debug

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    option redispatch
    option http-server-close
    option forwardfor
    maxconn 2000
    timeout connect 5s
    timeout client  15m
    timeout server  15m

frontend public
    bind *:80
    use_backend webcam if { path_beg /webcam/ }
    default_backend octoprint

backend octoprint
    http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
    option forwardfor
    server octoprint1 127.0.0.1:5000

backend webcam
    http-request replace-path /webcam/(.*) /\1
    server webcam1  127.0.0.1:8080
EOF

# Déplacer ce fichier au bon endroit
mv /home/$OCTO_USER/haproxy.cfg /etc/haproxy/haproxy.cfg
# Ajouter le «flag» pour permettre le démarrage du proxy reverse (plus nécessaire)
#echo ENABLED=1 | sudo tee -a /etc/default/haproxy
# Démarrer le service HAproxy
systemctl daemon-reload
systemctl enable haproxy
systemctl start haproxy

#########################Camera################################

# Ajout des scipts de contrôle de la Webcam
clear
echo "Installation du scipt de contrôle de la Webcam en tant que service, activation et démarrage"
echo
su -l $OCTO_USER -c "mkdir /home/$OCTO_USER/scripts"
cat << EOF > "/home/$OCTO_USER/scripts/webcamd.service"
[Unit]
Description=Camera streamer for OctoPrint
After=network-online.target octoprint.service
Wants=network-online.target

[Service]
Type=simple
User=pi
ExecStart=/home/pi/scripts/webcamDaemon

[Install]
WantedBy=multi-user.target
EOF
# Remplacer l'utilisateur 'pi' en dur par celui correspondant à OCTO_USER
sed -i "s/pi/$OCTO_USER/" webcamd.service
# Déplacer ce fichier dans /etc/systemd/system/
mv /home/$OCTO_USER/scripts/webcamd.service /etc/systemd/system/
# Recharger les services puis activer et démarrer ce nouveau service :
systemctl daemon-reload
systemctl enable webcamd
systemctl start webcamd

# Service Webcam
#
# vcgencmd ne fait pas partie des commandes connues d'Armbian, il est donc commenté ci-dessous
#
sudo -u $OCTO_USER cat << EOF > "/home/$OCTO_USER/scripts/webcamDaemon"
#!/bin/bash

MJPGSTREAMER_HOME=/home/pi/mjpg-streamer/mjpg-streamer-experimental
MJPGSTREAMER_INPUT_USB="input_uvc.so"
MJPGSTREAMER_INPUT_RASPICAM="input_raspicam.so"

# init configuration
camera="auto"
camera_usb_options="-r 640x480 -f 10"
camera_raspi_options="-fps 10"

if [ -e "/boot/octopi.txt" ]; then
    source "/boot/octopi.txt"
fi

# runs MJPG Streamer, using the provided input plugin + configuration
function runMjpgStreamer {
    input=\$1
    pushd \$MJPGSTREAMER_HOME
    echo Running ./mjpg_streamer -o "output_http.so -w ./www" -i "\$input"
    LD_LIBRARY_PATH=. ./mjpg_streamer -o "output_http.so -w ./www" -i "\$input"
    popd
}

# starts up the RasPiCam
function startRaspi {
    logger "Starting Raspberry Pi camera"
    runMjpgStreamer "\$MJPGSTREAMER_INPUT_RASPICAM \$camera_raspi_options"
}

# starts up the USB webcam
function startUsb {
    logger "Starting USB webcam"
    runMjpgStreamer "\$MJPGSTREAMER_INPUT_USB \$camera_usb_options"
}

# we need this to prevent the later calls to vcgencmd from blocking
# I have no idea why, but that's how it is...
# Honest comments are the best!!!! Black Box solution incoming........
#vcgencmd version

# echo configuration
echo camera: \$camera
echo usb options: \$camera_usb_options
echo raspi options: \$camera_raspi_options

# keep mjpg streamer running if some camera is attached
while true; do
    if [ -e "/dev/video0" ] && { [ "\$camera" = "auto" ] || [ "\$camera" = "usb" ] ; }; then
        startUsb
    elif [ "`vcgencmd get_camera`" = "supported=1 detected=1" ] && { [ "\$camera" = "auto" ] || [ "\$camera" = "raspi" ] ; }; then
        startRaspi
    fi

    sleep 120
done
EOF

# Remplacer l'utilisateur "$OCTO_USER" en dur par celui correspondant à OCTO_USER
sed -i "s/pi/$OCTO_USER/" webcamDaemon
# Attribuer les bons droits et appartenance (utilisateur $OCTO_USER, groupe $OCTO_USER)
chown $OCTO_USER:$OCTO_USER /home/$OCTO_USER/scripts/webcamDaemon
chmod +x /home/$OCTO_USER/scripts/webcamDaemon

##################### Paramétrages ##############################
# A adapter en fonction de votre imprimante
# Arrêter OctoPrint pour permettre la «customisation»
systemctl stop octoprint.service

# Ajout de la section dans config.yaml d'OctoPrint pour la gestion de la Webcam
clear
echo "Modifications config.yaml :"
echo "- ajout des commandes d'arrêt, redémarrage du système"
echo "- ajout du redémarrage d'Octoprint"
echo "- ajout de la prise en charge de la Webcam et de sa gestion (arrêt / démarrage)"
echo
sudo -u $OCTO_USER cat << EOF >> "/home/$OCTO_USER/.octoprint/config.yaml"
server:
  host: 127.0.0.1
  commands:
    serverRestartCommand: sudo systemctl restart octoprint
    systemRestartCommand: sudo shutdown -r now
    systemShutdownCommand: sudo shutdown -h now
webcam:
  ffmpeg: /usr/bin/ffmpeg
  snapshot: http://127.0.0.1:8080/?action=snapshot
  stream: /webcam/?action=stream
  streamRatio: '4:3'
  watermark: false
system:
  actions:
   - action: streamon
     command: sudo systemctl start webcamd
     confirm: false
     name: Start video stream
   - action: streamoff
     command: sudo systemctl stop webcamd
     confirm: false
     name: Stop video stream
EOF

# Attribuer les bons droits et appartenance (utilisateur pi)
chown $OCTO_USER:$OCTO_USER /home/$OCTO_USER/.octoprint/config.yaml

# Redémarrer OctoPrint et attendre qu'il ait fini son initialisation - sinon risque de reboots trop rapide et déclenchememt du «safe mode» au prochain démarrage
systemctl start octoprint
sleep 15

# Une petite pause avant de redémarrer
echo && read -p "Presser la touche ENTRÉE pour redémarrer le système. La connexion ssh sera perdue et devra être relancée"
echo

################## Redémarrage final ##########################
# Reboot pour prendre en compte les dernières modifications
reboot now
