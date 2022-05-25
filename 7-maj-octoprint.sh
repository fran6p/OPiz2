#!/bin/bash
# Mise à jour d'Octoprint
# F. Poulizac (fran6p)
# La majorité des commandes vient de ce lien  :
# https://community.octoprint.org/t/setting-up-octoprint-on-a-raspberry-pi-running-raspbian/2337 
# 

# Utilisateur non priviligié (pi)
OCTO_USER="pi"

echo "Ce script est exécuté en tant qu'utilisateur $OCTO_USER"
echo "Seul le redémarrage du serveur nécessite les droits du superutilisateur «root»"
echo
read -p "Presser ENTRÉE pour continuer"

clear
echo && read -p "Voulez-vous mettre à jour le serveur Octoprint ? (o/n)" -n 1 -r -s majOcto && echo
if [[ $majOcto != "O" && $majOcto != "o" ]]; then
	echo "Mise à jour d'Octoprint annulée."
	exit 1
fi
clear

# Configurer l'environnement et le paramétrage d'Octoprint
echo "Mise à jour de Octoprint"
echo

cd /home/$OCTO_USER
source OctoPrint/bin/activate
/home/$OCTO_USER/OctoPrint/bin/pip install pip --upgrade
/home/$OCTO_USER/OctoPrint/bin/pip install --no-cache-dir octoprint --upgrade

# Redémarrer le serveur Octoprint
systemctl restart octoprint
sleep 5

# Une petite pause avant de redémarrer. Pas vraiment nécessaire mais autant «repartir» sur de bonnes bases
echo && read -p "Presser la touche ENTRÉE pour redémarrer le système. La connexion ssh sera perdue et devra être relancée"
echo

################## Redémarrage final ##########################
# Reboot pour prendre en compte les dernières modifications
reboot now
