#!/bin/bash
# Octoprint Armbian - OrangePi Zero 2 (aka OPiz2) Script d'initialisation
# F. Poulizac (fran6p)
#

if [ $(id -u) -ne 0 ]; then
	echo "Ce script doit être exécuté en tant que «root»"
	exit 1
fi

echo && read -p "Voulez-vous initialiser l'OrangePi Zero 2 ? (o/n)" -n 1 -r -s installOPiz2 && echo
if [[ $installOPiz2 != "O" && $installOPiz2 != "o" ]]; then
	echo "Installation d'Armbian-OPiz2 annulée."
	exit 1
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
#(echo "root" ; echo "1234" ; echo "1234") | passwd
echo -e '1234\n1234\n' | (passwd root)

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
echo "Ajout de l'utilisateur 'pi' )Octoprint)"
echo "Cet utilisateur appartient aux groupes : sudo,video,plugdev,dialout,tty "
echo "Son mot de passe est fixé à 'orangepi'"
echo
adduser pi
# Ajouter «pi» aux groupes nécessaires
usermod -a -G sudo,video,plugdev,dialout,tty  pi
# Mettre un mot de passe à l'utilisateur «pi» (à modifier ultérieurement si besoin)
echo -e "orangepi\norangepi\n" | (passwd pi)

# Permettre à «pi» de lancer des commandes normalement lancées avec les droits «root» (shutdown et service)
echo "On autorise l'utilisateur 'pi' à arrêter, redémarrer le système ainsi que redémarrer certains services"
echo
cat << EOF > "/etc/sudoers.d/octoprint-shutdown"
pi ALL=NOPASSWD: /sbin/shutdown
EOF
cat << EOF > "/etc/sudoers.d/octoprint-service"
pi ALL=NOPASSWD: /usr/sbin/service
EOF
cat << EOF > "/etc/sudoers.d/octoprint-ip"
pi ALL=NOPASSWD: /sbin/ip
EOF
# attribuer les bons droits sur ces derniers fichiers
chmod 0440 /etc/sudoers.d/octoprint-s*

# TERMINÉ - Reboot
echo "========================"
echo "Utilisateur : root"
echo "Mot de passe: 1234"
echo "========================"
echo
echo "========================"
echo "Utilisateur : pi"
echo "Mot de passe: orangepi"
echo "========================"
echo
echo " => à modifier après redémarrage (ou pas ;-) )"
echo
echo "========================"
echo "Nom d'hôte : $(hostame)"
echo "IP Ethernet: $IP_RJ45"
echo "IP Wifi    : $IP_WIFI"
echo 
read -p "Presser ENTRÉE pour redémarrer"

reboot now
exit 0
