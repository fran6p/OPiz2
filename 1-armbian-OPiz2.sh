#!/bin/bash
# Octoprint Armbian - OrangePi Zero 2 (aka OPiz2) Script d'initialisation
# F. Poulizac (fran6p)
#

# Variables
# Mot de passe root
ROOTPWD="1234"
# Utilisateur Octoprint et son mot de passe
OCTO_USER="pi"
OCTO_USERPWD="orangepi"

if [ $(id -u) -ne 0 ]; then
	echo "Ce script doit être exécuté en tant que «root»"
	exit 1
fi

echo && read -p "Voulez-vous initialiser l'OrangePi Zero 2 ? (o/n)" -n 1 -r -s installOPiz2 && echo
if [[ $installOPiz2 != "O" && $installOPiz2 != "o" ]]; then
	echo "Installation d'Armbian-OPiz2 annulée."
	exit 1
fi

# TEST
# Ajout du Wifi
echo && read -p "Voudrez-vous accéder en Wifi sur la carte ? (o/n)" -n 1 -r -s installWifi && echo
if [[ $installWifi != "N" && $installWifi != "n" ]]; then
	echo "Préparation à l'installation de la connexion Wifi."
	read -p "Quel est le nom du point d'accès Wifi ?"  -r SSID
	read -p "Quel est le mot de passe du point d'accès Wifi ?"  -r WIFIPWD
	echo "Wifi: $SSID Mot de passe Wifi: $WIFIPWD"
	echo && read -p "Est-ce correct ? ( o / n )" -n 1 -r -s Correct && echo
        if [[ $Correct != "N" && $Correct != "n" ]]; then
	nmcli device wifi connect "$SSID" password "$WIFIPWD"
	fi
fi

# Mises à jour
apt update
apt -y upgrade

# Nom d'hôte $(hostname)
rHostname="orangepizero2"

# Adresses IP
IP_RJ45=$(ifconfig eth0 |perl -ne 'print $1 if /inet\s.*?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b/')
IP_WIFI=$(ifconfig wlan0 |perl -ne 'print $1 if /inet\s.*?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b/')

# Mot de passe
#(echo "root" ; echo "$ROOTPWD" ; echo "$ROOTPWD") | passwd
echo -e "$ROOTPWD\n$ROOTPWD" | passwd root

# Eviter qu'à la prochaine connexion en root qu'il soit demandé de modifier le MDP
rm -f /root/.not_logged_in_yet

# Choix de la Timezone
echo "Configuration de la zone horaire"
echo
dpkg-reconfigure tzdata

# Choix de la langue
echo "Configuration de la langue du système"
echo
dpkg-reconfigure locales
source /etc/default/locale
sed -i "s/^LANGUAGE=.*/LANGUAGE=$LANG/" /etc/default/locale
export LANGUAGE=$LANG

# Choix du clavier
# La commande ci-dessous ne fonctionne qu'avec un clavier physiquement connecté (pas en ssh :-( )
#dpkg-reconfigure keyboard-configuration
echo "Configuration du clavier"
echo
localectl set-keymap fr
setupcon



# Ajout de l'utilisateur «pi» (Octoprint)
echo "Ajout de l'utilisateur $OCTO_USER (Octoprint)"
echo "Cet utilisateur appartient aux groupes : sudo,video,plugdev,dialout,tty "
echo "Son mot de passe est fixé à '**orangepi**'"
echo
useradd -d /home/$OCTO_USER $OCTO_USER
# Ajouter «pi» aux groupes nécessaires
usermod -a -G sudo,video,plugdev,dialout,tty  $OCTO_USER
# Mettre un mot de passe à l'utilisateur «pi» (à modifier ultérieurement si besoin)
echo -e "$OCTO_USERPWD\n$OCTO_USERPWD" | passwd $OCTO_USER

# Permettre à «pi» de lancer des commandes normalement lancées avec les droits «root» (shutdown et service)
echo "On autorise l'utilisateur $OCTO_USER à arrêter, redémarrer le système ainsi que redémarrer certains services"
echo
echo "$OCTO_USER ALL=(ALL) NOPASSWD: /sbin/shutdown *" > /etc/sudoers.d/octoprint-shutdown
echo "$OCTO_USER ALL= NOPASSWD: /bin/systemctl restart octoprint.service" > /etc/sudoers.d/octoprint-service
echo "$OCTO_USER ALL= NOPASSWD: /sbin/ip" > /etc/sudoers.d/octoprint-ip
# attribuer les bons droits sur ces derniers fichiers
chmod 0440 /etc/sudoers.d/octoprint-s*

# TERMINÉ - Reboot
echo "========================"
echo "Utilisateur : root"
echo "Mot de passe: $ROOTPWD"
echo "========================"
echo
echo "========================"
echo "Utilisateur : $OCTO_USER"
echo "Mot de passe: $OCTO_USERPWD"
echo "========================"
echo
echo "========================"
echo "WIfi        : $SSID"
echo "Mot de passe: $WIFIPWD"
echo "========================"
echo
echo "========================"
echo "Nom d'hôte : $rHostname"
echo "IP Ethernet: $IP_RJ45"
echo "IP Wifi    : $IP_WIFI"
echo 
read -p "Presser ENTRÉE pour redémarrer"

reboot now
