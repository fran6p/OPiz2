# OctorangePi
  OctoPrint script d'installation complet pour une carte OrangePi Zero 2 avec gestion d'une Webcam

  Ce projet n'est nullement destiné à remplacer OctoPi, mais à donner aux possesseurs d'une imprimante 3D une installation de base avec la plupart des paramètres déjà configurés et quelques greffons qui me semblent indispensables. 
  Ce projet ne guide pas l'utilisateur à travers le flashage d'images ou la configuration du Wifi (même si tout est prévu).
  Il suppose que l'utilisateur peut faire une image d'une carte SD et se connecter à sa nouvelle installation Armbian via SSH.  Je n'aborderai donc pas ces étapes.

## Ce qui est configuré
- OctoPrint (dernière version (1.7.3 à la date de la réalisation de ce texte)
- Quelques greffons pour «améliorer» Octoprint
- Fail2Ban (sécurité supplémentaire)
- HAProxy (URLs propres sans numéros de port)
- MJPEG-Streamer (envoie les images en tant que vidéo)
- Samba (accès à un partage sur la carte via le réseau informatique)

  
## Requis:
- Imprimante 3D
- OrangePi Zero 2 avec une alimentation adéquate.
- Une Webcam USB (facultatif)
- Carte SD de 8 Go ou plus
- Câble USB inclus avec l'imprimante (ou pas)

# Avertissement
  - **Ce n'est jamais une bonne pratique d'exécuter aveuglément des scripts aléatoires à partir d'Internet**.  Les scripts fournis ici sont un outil d'apprentissage, pas un remplacement général de OctoPi. **Veuillez examiner les commentaires et le code**.

# Étape 1) Configuration de la carte SD
  - Télécharger la dernière version de [Armbian](https://www.armbian.com/orange-pi-zero-2/) ( Armbian 22.02 Bullseye au moment de la rédaction )  
  - Imagez votre carte SD avec votre imageur préféré
  
# Étape 2) Configuration initiale du OrangePI Zero 2 (OPiz2)
  - Insérez la carte SD imagée dans le OPiz2.
  - Branchez votre câble RJ45 sur le OPiz2 d'un côté et sur votre routeur de l'autre.
  - Connectez votre OPiz2 à l'alimentation électrique via un câble USB-C.
  - Attendez une minute pour qu'il démarre (la doide rouge passe au vert), la carte a reçu une adresse IP de votre routeur.
  - Connectez-vous via SSH (vérifier votre routeur pour connaitre quelle adresse a été assignée)
    - ```ssh root@ADRESSE.IP.OPiz2.ICI```
    - Mot de passe : ``1234``
  - Exécutez la commande suivante pour télécharger le script d'initialisation à partir de ce dépôt, puis suivez les instructions.
    - ```bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/1-armbian-OPiz2.sh)``
    - Sélectionnez votre langue, votre emplacement et votre fuseau horaire
      - J'utilise ```fr_FR.UTF-8`` pour la langue FR et la zone Europe/Paris pour le fuseau horaire
  - A la fin du script, la carte devrait redémarrer automatiquement.
  
# Étape 3) Préparation de Linux
  - Votre Pi devrait avoir redémarré.
  - Vous pouvez maintenant vous reconnecter via SSH en utilisant ``1234`` comme mot de passe «root».
  - VOUS POUVEZ CHANGER LE MOT DE PASSE SI VOUS LE SOUHAITEZ (RECOMMANDÉ)
    - Tapez ``passwd`` et suivez les instructions.
  - Exécutez la commande suivante pour télécharger le script de préparation de ce dépôt.
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/2-installation-paquets.sh)``
    - Cela mettra à jour et installera les dépendances de Armbian Bullseye requises pour ce projet (à jour au 4-2022).
    - soyez patient, cela peut prendre un certain temps.
    - AVERTISSEMENT - ceci téléchargera quelques centaines de Mo de données de mise à jour.  Une connexion instable peut accroitre le temps de téléchargement.

# Étape 4) Installation du logiciel Octoprint
  - Exécutez la commande suivante pour télécharger le script d'installation à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/3-install-octo-only.sh)``
  - A la fin du script, la carte devrait redémarrer automatiquement.
  
# Étape 5) Complément d'installation d'Octoprint
  - Exécutez la commande suivante pour télécharger le script d'installation des compléments à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/4-install-octoprint-suite.sh)``
  - A la fin du script, la carte devrait redémarrer automatiquement.
   
 # Étape 6) Installations facultatives mais bien pratiques
  - Exécutez la commande suivante pour télécharger le script permettant de gérer les «GPIO» à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/5-armbian-gpio.sh)``
  - Exécutez la commande suivante pour télécharger le script permettant de gérer les «GPIO» à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/6-octo-samba.sh)``	
  - Après installation de ces derniers scripts, Octoprint est pleinement fonctionnel et n'attends plus que la connexion de la carte sur l'imprimante 3D.
  
 # Étape 7) Connecter l'imprimante et tester
  - Laissez à votre OPz2i une minute ou deux pour redémarrer.
  - Connectez votre câble USB d'un côté sur la carte OPiz2 et de l'autre à votre imprimante 3D
  - Mettez votre imprimante 3D sous tension
  - Ouvrez un navigateur et visitez l'URL suivante :
    - ```http://ADRESSE.IP.OPiz2.ICI```
    - Vous devriez voir l'écran de l'assistant de configuration du premier lancement d'OctoPrint.
    
 # Étape 8) Configurer OctoPrint et en profiter !
  - Ce n'est pas le but de ce texte de réaliser un guide de configuration d'Octoprint... N'importe quel moteur de recherche avec les bons mots clés devrait vous fournir de nombreux liens ;-) 
  
  
 # Méthode alternative à lexécution de scripts distants
  - Vous pouvez, plutôt qu'exécuter les scripts à distance, récupérer le contenu de ce dépôt :
    - ```
    cd ~
    git clone https://github.com/fran6p/OPiz2.git
```
  - Rendre exécutables les scripts (.sh):
    - ```
    cd ~/OPiz2
    chmod +x *.sh
```
  - Exécuter chacun des scripts les uns à la suite des autres (étapes 2 à 4 (ou 6)).

:-)   
  
  
 
