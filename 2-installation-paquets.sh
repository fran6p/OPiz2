#!/bin/bash
# Installation des paquets nécessaires et suffisants
# F. Poulizac (fran6p)

if [ $(id -u) -ne 0 ]; then
	echo "Ce script doit être exécuté en tant que «root»"
	exit 1
fi

# Programmes et Dépendances - à éditer si besoin
BasicFeatures="fail2ban git"
MJPGStreamer="subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake"
OctoPrint="python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential ffmpeg"
Development="avrdude"
HAProxy="haproxy"
SAMBA="samba cifs-utils smbclient"
Fun="cowsay"

# Ajout de toutes les dépendances à la liste
ProgramList="$BasicFeatures $MJPGStreamer $OctoPrint $Development $HAProxy $SAMBA $Fun"

echo "Les programmes suivants seront installés :"
echo "$ProgramList"
echo
echo && read -p "Voulez-vous installer les logiciels absolument nécessaires ? (o/n)" -n 1 -r -s installPrgs && echo
if [[ $installPrgs != "O" && $installPrgs != "o" ]]; then
	echo "Installation annulée."
	exit 1
fi
# Mise à jour du système puis installation de la liste des programmes ci-dessus
apt update -y
apt install -y $ProgramList

echo 
read -p "Presser ENTRÉE pour continuer" \

exit 0
