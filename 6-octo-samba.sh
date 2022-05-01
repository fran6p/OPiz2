#!/bin/bash
# Permettre l'accès au dossier «pi» via le protocole Samba
# F. Poulizac (fran6p)
# 

if [ $(id -u) -ne 0 ]; then
	echo "Ce script doit être exécuté en tant que «root»"
	exit 1
fi


echo && read -p "Voulez-vous modifier l'accès au dossier «pi» via Samba? (o/n)" -n 1 -r -s installSmb && echo
if [[ $installSmb != "O" && $installSmb != "o" ]]; then
	echo "Script annulé."
	exit 1
fi

# Ajout du montage [pi] à smb.conf
cat << EOF >> "/etc/samba/smb.conf"

[pi]
path =/home/pi
valid users = pi
read only = no
browseable = yes

EOF

#Recharger Samba
systemctl reload smbd

# Ajouter l'utilisateur «pi»
clear
echo "Le mot de passe pour permettre à l'utilisateur «pi» d'accéder au répertoire partagé est initialisé"
echo
echo "Pour accéder au partage via l'explorateur de Windows, saisir : \\adresse_ip_orangepi"
echo
echo
# Manuellement saisir le mot de passe Samba pour pouvoir se connecter sur le partage (smbpasswd -a pi)
echo -e "orangepi\norangepi" | (smbpasswd -a pi)

# Fin 
echo
echo "Le partage [pi] a été créé."
