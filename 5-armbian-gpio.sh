#!/bin/bash
# Modification appartenance et droits des /dev/gpiochip*
# F. Poulizac (fran6p)
# 

if [ $(id -u) -ne 0 ]; then
	echo "Ce script doit être exécuté en tant que «root»"
	exit 1
fi


echo && read -p "Voulez-vous modifier les droits et l'appartenance des /dev/gpiochips ? (o/n)" -n 1 -r -s installGpio && echo
if [[ $installGpio != "O" && $installGpio != "o" ]]; then
	echo "Script annulé."
	exit 1
fi

# Créer le groupe (système) «gpio» si absent
#groupadd -f -r gpio
#Mieux:
getent group gpio 2>&1 > /dev/null || groupadd -f -r gpio

# Modifier les droits utilisateurs - Ajout de l'utilisateur au groupe gpio
usermod -a -G gpio pi

# Créer le fichier UDEV «96-gpio.rules» pour avoir les mêmes droits et appartenance qu'avec un Raspberry
cat << EOF > "/etc/udev/rules.d/96-gpio.rules"
# /etc/udev/rules.d/96-gpio.rules
SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c '\
chown -R root:gpio /sys/class/gpio && chmod -R 0770 /sys/class/gpio &&\
chown -R root:gpio /sys/devices/platform/sunxi-pinctrl/gpio && chmod -R 0770
/sys/devices/platform/sunxi-pinctrl/gpio'"
SUBSYSTEM=="gpio", GROUP="gpio", MODE="0660"
EOF

# Recharger les régles et les déclencher
udevadm control --reload-rules
udevadm trigger

# Installation de wiringOP (accès GPIO)
git clone https://github.com/orangepi-xunlong/wiringOP.git
cd wiringOP
./build clean
./build

# Affichage des GPIO
# =>  gpio readall
