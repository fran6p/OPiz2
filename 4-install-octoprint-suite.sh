#!/bin/bash
# Installation d'Octoprint
# Compléments:
# - services :
#      - octoprint
#      - haproxy
#      - webcamd
# - modification config.yaml :
#      - commandes lancement, arrêt du système, redémarrage Octoprint
#      - profil pré-configuré (CR10)
#
# F. Poulizac (fran6p)
# La majorité des commandes vient de ce lien https://community.octoprint.org/t/setting-up-octoprint-on-a-raspberry-pi-running-raspbian/2337 
# 

if [ $(id -u) -ne 0 ]; then
	echo "Ce script doit être exécuté en tant que «root»"
	echo 
	echo "L'installation se fera sous l'utilisateur pi si besoin"
	exit 1
fi

# Créer le «service» pour un démarrage automatique d'OctoPrint
clear
echo "Création du service octoprint puis activation et démarrage du serveur"
echo
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

# Méthode alternative et préférable : récupérer ce script directement sur le Github d'Octoprint
#wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service && mv octoprint.service /etc/systemd/system/octoprint.service
# 
#Recharger, activer l'auto-start puis démarrer le service OctoPrint
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
mv /home/pi/haproxy.cfg /etc/haproxy/haproxy.cfg
# Ajouter le «flag» pour permettre le démarrage du proxy reverse (nécessaire ?)
#echo ENABLED=1 | sudo tee -a /etc/default/haproxy
# Démarrer le service HAproxy
systemctl enable haproxy
systemctl start haproxy

#########################Camera################################

# Ajout des scipts de contrôle de la Webcam
clear
echo "Installation des scipts de contrôle de la Webcam en tant que service, activation et démarrage"
echo
su -l pi -c "mkdir /home/pi/scripts"
cat << EOF > "/home/pi/scripts/webcamd.service"
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
# Déplacer ce fichier dans /etc/systemd/system/
mv /home/pi/scripts/webcamd.service /etc/systemd/system/
# Recharger les services puis activer et démarrer ce nouveau service :
systemctl daemon-reload
systemctl enable webcamd
systemctl start webcamd

# Service Webcam
#
# vcgencmd ne fait pas partie des commandes connues d'Armbian, il est donc commenté ci-dessous
#
sudo -u pi cat << EOF > "/home/pi/scripts/webcamDaemon"
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
# Attribuer les bons droits et appartenance (utilisateur pi)
chown pi:pi /home/pi/scripts/webcamDaemon
chmod +x /home/pi/scripts/webcamDaemon

##################### Profils imprimante et paramétrages ##############################
# A adapter en fonction de votre imprimante
# Arrêter OctoPrint pour permettre la «customisation»
systemctl stop octoprint.service

# Ajout de la section dans yaml d'OctoPrint pour la gestion de la Webcam
clear
echo "Modifications config.yaml :"
echo "- ajout des commandes d'arrêt, redémarrage du système"
echo "- ajout du redémarrage d'Octoprint"
echo "- ajout de la prise en charge de la Webcam et de sa gestion (arrêt / démarrage)"
echo "- modification du profil d'imprimante par défaut par celui précédemment créé"
echo
sudo -u pi cat << EOF >> "/home/pi/.octoprint/config.yaml"
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
chown pi:pi /home/pi/.octoprint/config.yaml

# Redémarrer OctoPrint et attendre qu'il ait fini son initialisation - sinon risque de reboots trop rapide et déclenchememt du «safe mode» au prochain démarrage
systemctl start octoprint
sleep 30

# Une petite pause avant de redémarrer
echo && read -p "Presser la touche ENTRÉE pour redémarrer. La connexion ssh sera perdue et devra être relancée"
echo

################## Redémarrage final ##########################
# Reboot pour prendre en compte les dernières modifications
reboot now
