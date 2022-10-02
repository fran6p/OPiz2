# OctorangePi

OctoPrint: scripts d'installation complète pour une carte OrangePi Zero 2 avec gestion d'une Webcam
  
Ce <a href="https://github.com/fran6p/Documents-LI3D/blob/main/Installer%20Octoprint%20sur%20une%20OrangePi%20Zero%202.md" target="_blank">document</a>
décrit en détails une installation manuelle (en ligne de commandes), les scripts proposés ici agrègent les différentes manipulations réalisées afin d'automatiser l'installation et éviter des erreurs de manipulations / saisies / recopies, autrement dénommées [ICC](https://fr.wiktionary.org/wiki/interface_chaise-clavier) ([PEBCAK](https://fr.wiktionary.org/wiki/PEBCAK) pour les anglophones :smirk: ).

 Il s'agit ici d'offrir aux possesseurs d'imprimante 3D une installation de base d'Octoprint avec la plupart des paramètres déjà configurés et quelques greffons qui me semblent indispensables.
 
  Je ne guide pas l'utilisateur à travers toutes les étapes (flashage de l'image, configuration du Wifi, ...), se référer au document en lien plus haut pour une description plus détaillée.
  
  **Il est supposé que l'utilisateur sait réaliser une image système sur une carte SD et se connecter à sa nouvelle installation Armbian via SSH**.  Je n'aborderai donc pas ces étapes.

## Ce que ces scripts vont configurer

- OctoPrint (dernière version (1.7.3 à la date de la réalisation de ce texte)
- Quelques greffons pour «améliorer» Octoprint
- Fail2Ban (sécurité supplémentaire), installé mais à paramétrer en fonction de votre paranoïa
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

>  **Ce n'est jamais une bonne pratique d'exécuter aveuglément des scripts d'inconnus à partir d'Internet**.  Les scripts fournis ici ne sont qu'un outil d'apprentissage. **Veuillez examiner les commentaires et le code**.

# Étape 1)
## Configuration de la carte SD

  - Télécharger la dernière version de [Armbian](https://www.armbian.com/orange-pi-zero-2/) ( Armbian 22.02 Bullseye au moment de la rédaction )  
  - Imager votre carte SD avec votre imageur préféré
  
# Étape 2) 
## Configuration initiale du OrangePI Zero 2 (OPiz2)

  - Insérer la carte SD imagée dans le OPiz2.
  - Brancher un câble RJ45 sur le OPiz2 d'un côté et sur votre routeur de l'autre.
  - Connecter votre OPiz2 à l'alimentation électrique via un câble USB-C.
  - Attendre une minute ou plus qu'il démarre (la diode est rouge). Quand elle passe au vert, la carte a reçu une adresse IP de votre routeur.
  - Se connecter via SSH (vérifier sur votre routeur ou par n'importe quel autre moyen afin de connaitre quelle adresse a été assignée)
    - ```ssh root@ADRESSE.IP.OPiz2.ICI```
    - Mot de passe : ``1234``
  - Exécuter la commande suivante pour télécharger le script d'initialisation à partir de ce dépôt, puis suivre les instructions.
    - ``bash <(curl -Ls https://raw.githubusercontent.com/fran6p/OPiz2/main/1-armbian-OPiz2.sh)``
    - Si vous souhaitez pouvoir accéder à la carte en Wifi, indiquer le nom du point d'accès (SSID) et son mot de passe pour pouvoir l'activer.
    - Sélectionner votre langue, votre emplacement et votre fuseau horaire (J'utilise ``fr_FR.UTF-8 UTF8  `` pour la langue FR les locales et la zone Europe/Paris pour le fuseau horaire)
  - A la fin du script, un récapitulatif sera affiché puis la carte devrait redémarrer après confirmation.
  *Il est assez fréquenr que la carte ne redémarre pas correctement. Le plus simple, ne ce cas, est de débrancher l'alimentation, attednre quelques secondes puis reconnecter (en espérant que la DEL (LED) passe au vert, si elle reste rouge fixe, c'est malheuresuement souvent dû à la version Armbian installée :smirk: ). 
  
# Étape 3)
## Préparation de Linux

  - Une fois votre OPiz2 redémarré.
  - Vous reconnecter via SSH en utilisant ``1234`` comme mot de passe «root».
    - L'utilisateur «pi» (gestion d'Octoprint) a été créé, son mot de passe est initialisé à ``orangepi``
  - VOUS POUVEZ CHANGER LE MOT DE PASSE «ROOT» SI VOUS LE SOUHAITEZ (**RECOMMANDÉ**)
    - Taper ``passwd`` et suivre les instructions.
  - Exécuter la commande suivante pour télécharger le script de préparation à partir de ce dépôt.
    - ``bash <(curl -Ls https://raw.githubusercontent.com/fran6p/OPiz2/main/2-installation-paquets.sh)``
    - Cela mettra à jour et installera les dépendances de Armbian Bullseye requises pour ce projet (à jour au 4-2022).
    - Soyez patient, **cela peut prendre un certain temps**.
    - AVERTISSEMENT - ceci téléchargera de quelques dizaines à quelques centaines de Mo de données de mise à jour.  Une connexion instable accroitra le temps de téléchargement.

# Étape 4) 
## Installation du logiciel Octoprint et compléments d'installation d'Octoprint

  - Exécuter la commande suivante pour télécharger le script d'installation d'Octoprint et de ses compléments (installation, activation et démarrage des services (octoprint, webcamd, haproxy, modification du fichier config.yaml (Octoprint)) à partir de ce dépôt
    - ``bash <(curl -Ls https://raw.githubusercontent.com/fran6p/OPiz2/main/3-install-octoprint.sh)``
  - A la fin du script, la carte va redémarrer automatiquement.
  
 # Étape 5) 
 ## Installations facultatives mais bien pratiques
 
  - Exécuter la commande suivante pour télécharger le script permettant de gérer les «GPIO» de *maniére identique* à un Raspberry Pi à partir de ce dépôt (utilisateur: root, groupe: gpio, droits (0660) (crw-rw----) au lieu de root:root (0600))
    - ``bash <(curl -Ls https://raw.githubusercontent.com/fran6p/OPiz2/main/5-armbian-gpio.sh)``
  - Exécuter la commande suivante pour télécharger le script permettant de gérer le partage réseau «pi» à partir de ce dépôt
    - ``bash <(curl -Ls https://raw.githubusercontent.com/fran6p/OPiz2/main/6-octo-samba.sh)``	
  - Après installation de ces derniers scripts, Octoprint est pleinement fonctionnel et n'attends plus que la connexion de la carte sur l'imprimante 3D.
  
 # Étape 6) 
 ## Connecter l'imprimante et tester
 
  - Laisser à votre OPz2i une minute ou deux pour redémarrer (normalement pas nécessaire après l'étapes 5).
  - Brancher votre câble USB d'un côté sur la carte OPiz2 (*un seul port USB disponible à moins que vous n'ayez ajouté son HAT USB complémentaire*) et de l'autre à votre imprimante 3D
  - Mettre votre imprimante 3D sous tension
  - Ouvrir un navigateur et visiter l'URL suivante :
    - ```http://ADRESSE.IP.OPiz2.ICI```
    - L'écran de l'assistant de configuration du premier lancement d'OctoPrint devrait s'afficher.
    
 # Étape 7) 
 ## Configurer OctoPrint et en profiter !
 
  - Le but de ce texte n'est pas de réaliser un guide de configuration d'Octoprint... N'importe quel moteur de recherche avec les bons mots clés devrait vous fournir de nombreux liens :smirk: 
  
 > **A NOTER**: 
 > Quelques greffons ont été préinstallés qu'il faudra également configurer :wink:
 > - Dashboard, 
 > - DisplayLayerProgress,
 > - FirmwareUpdater,
 > - PrintTimeGenius, 
 > - UICustomizer, 
 > - BackupScheduler, 
 > - Resource-Monitor,
 > - Preheat, 
 > - MultipleUpload, 
 > - NetworkHealth, 
 > - AutoLoginConfig
  
  Vous pouvez évidemment en ajouter d'autres ou en retirer si cela ne vous convient pas 😏:
  
  
 # UPDATE (Octoprint est monté en version 1.8.0 depuis le 18 mai 2022)
 
 # UPDATE 2 Octoprint en version 1.8.1 depuis le 25 mai 2022
 
 # UPDATE Septembre 2022, Octoprint est désormais en version 1.8.4
 
 ## Mise à jour de la version 1.7.3 en 1.8.0 (1.8.1) via la notification du serveur ne se fait pas :cry:
 
Pour mettre à jour la version 1.7.3 en 1.8.0 (1.8.1 et plus), il est préférable d'utiliser le script "7-maj-octoprint.sh", en tentant de faire cette mise à jour proposée en notification dans l'interface du serveur Octoprint, elle n'aboutit pas et provoque une erreur (le chemin d'installation du script de Foosel n'est pas identique à celui utilisé ici pour installer Octoprint sur la carte Orange Pi Zero 2).

  - Exécuter la commande suivante pour télécharger le script permettant de mettre à jour Octoprint dans la dernière version disponible à partir de ce dépôt :
    - ``bash <(curl -Ls https://raw.githubusercontent.com/fran6p/OPiz2/main/7-maj-octoprint.sh)``
  - Après l'exécution de ce dernier script, le système redémarrera. Octoprint devrait être passé en version 1.8.0 (1.8.1 ou plus). Vérifier en bas à gauche de l'interface Web que cette version s'affiche :smirk: .

 # Méthode alternative à l'exécution de scripts distants
 
  - Plutôt qu'exécuter les scripts à distance, vous pouvez récupérer le contenu de ce dépôt :
      - ```cd ~ && git clone https://github.com/fran6p/OPiz2.git```
  - Rendre exécutables les scripts (.sh):
      - ```cd ~/OPiz2 && chmod +x *.sh```
  - Exécuter chacun des scripts les uns à la suite des autres (étapes 2 à 4 (ou 5)):
      - ```./1-armbian-OPiz2.sh```
      - ...

# :smiley: 
  
  
 
