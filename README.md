# OctorangePi
  OctoPrint: scripts d'installation complète pour une carte OrangePi Zero 2 avec gestion d'une Webcam
  
 Ce <a href="https://github.com/fran6p/Documents-LI3D/blob/main/Installer%20Octoprint%20sur%20une%20OrangePi%20Zero%202.md" target="_blank">document</a>
décrit précisément une installation manuelle (en ligne de commandes), les scripts proposés ici agrègent les différentes manipulations réalisées afin d'automatiser l'installation et éviter des erreurs de manipulations / saisies / recopies, autrement dénommées [ICC](https://fr.wiktionary.org/wiki/interface_chaise-clavier) ([PEBCAK](https://fr.wiktionary.org/wiki/PEBCAK) pour les anglophones ;-) ).

 Il s'agit ici d'offrir aux possesseurs d'imprimante 3D une installation de base d'Octoprint avec la plupart des paramètres déjà configurés et quelques greffons qui me semblent indispensables.
 
  Je ne guide pas l'utilisateur à travers toutes les étapes (flashage de l'image, configuration du Wifi, ...), se référer au document en lien plus haut pour une description plus détaillée.
  
  Il est supposé que l'utilisateur sait réaliser une image système sur une carte SD et se connecter à sa nouvelle installation Armbian via SSH.  Je n'aborderai donc pas ces étapes.

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
  - **Ce n'est jamais une bonne pratique d'exécuter aveuglément des scripts d'inconnus à partir d'Internet**.  Les scripts fournis ici sont un outil d'apprentissage. **Veuillez examiner les commentaires et le code**.

# Étape 1) Configuration de la carte SD
  - Télécharger la dernière version de [Armbian](https://www.armbian.com/orange-pi-zero-2/) ( Armbian 22.02 Bullseye au moment de la rédaction )  
  - Imagez votre carte SD avec votre imageur préféré
  
# Étape 2) Configuration initiale du OrangePI Zero 2 (OPiz2)
  - Insérer la carte SD imagée dans le OPiz2.
  - Brancher un câble RJ45 sur le OPiz2 d'un côté et sur votre routeur de l'autre.
  - Connecter votre OPiz2 à l'alimentation électrique via un câble USB-C.
  - Attendre une minute ou plus qu'il démarre (la diode est rouge). Quand elle passe au vert, la carte a reçu une adresse IP de votre routeur.
  - Se connectez via SSH (vérifier votre routeur pour connaitre quelle adresse a été assignée)
    - ```ssh root@ADRESSE.IP.OPiz2.ICI```
    - Mot de passe : ``1234``
  - Exécuter la commande suivante pour télécharger le script d'initialisation à partir de ce dépôt, puis suivre les instructions.
    - ```bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/1-armbian-OPiz2.sh)``
    - Sélectionner votre langue, votre emplacement et votre fuseau horaire
      - J'utilise ```fr_FR.UTF-8`` pour la langue FR et la zone Europe/Paris pour le fuseau horaire
  - A la fin du script, la carte devrait redémarrer automatiquement.
  
# Étape 3) Préparation de Linux
  - Une fois votre OPiz2 redémarré.
  - Vous reconnecter via SSH en utilisant ``1234`` comme mot de passe «root».
  - VOUS POUVEZ CHANGER LE MOT DE PASSE SI VOUS LE SOUHAITEZ (**RECOMMANDÉ**)
    - Taper ``passwd`` et suivre les instructions.
  - Exécuter la commande suivante pour télécharger le script de préparation à partir de ce dépôt.
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/2-installation-paquets.sh)``
    - Cela mettra à jour et installera les dépendances de Armbian Bullseye requises pour ce projet (à jour au 4-2022).
    - Soyez patient, cela peut prendre un certain temps.
    - AVERTISSEMENT - ceci téléchargera de quelques dizaines à quelques centaines de Mo de données de mise à jour.  Une connexion instable accroitra le temps de téléchargement.

# Étape 4) Installation du logiciel Octoprint
  - Exécuter la commande suivante pour télécharger le script d'installation du serveur Octoprint à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/3-install-octo-only.sh)``
  - A la fin du script, la carte va redémarrer automatiquement.
  
# Étape 5) Complément d'installation d'Octoprint
  - Exécuter la commande suivante pour télécharger le script d'installation des compléments à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/4-install-octoprint-suite.sh)``
  - A la fin du script, la carte va redémarrer automatiquement.
   
 # Étape 6) Installations facultatives mais bien pratiques
  - Exécuter la commande suivante pour télécharger le script permettant de gérer les «GPIO» à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/5-armbian-gpio.sh)``
  - Exécuter la commande suivante pour télécharger le script permettant de gérer le partage réseau «pi» à partir de ce dépôt
    - ``bash <(curl -Ls https://github.com/fran6p/OPiz2/raw/master/6-octo-samba.sh)``	
  - Après installation de ces derniers scripts, Octoprint est pleinement fonctionnel et n'attends plus que la connexion de la carte sur l'imprimante 3D.
  
 # Étape 7) Connecter l'imprimante et tester
  - Laisser à votre OPz2i une minute ou deux pour redémarrer (normalement pas nécessaire après les étapes 5 et 6).
  - Brancher votre câble USB d'un côté sur la carte OPiz2 (*un seul port USB disponible à moins que vous n'ayez ajouté son HAT USB complémentaire*) et de l'autre à votre imprimante 3D
  - Mettre votre imprimante 3D sous tension
  - Ouvrir un navigateur et visiter l'URL suivante :
    - ```http://ADRESSE.IP.OPiz2.ICI```
    - L'écran de l'assistant de configuration du premier lancement d'OctoPrint devrait s'afficher.
    
 # Étape 8) Configurer OctoPrint et en profiter !
  - Le but de ce texte n'est pas de réaliser un guide de configuration d'Octoprint... N'importe quel moteur de recherche avec les bons mots clés devrait vous fournir de nombreux liens ;-) 
  
  
 # Méthode alternative à l'exécution de scripts distants
  - Plutôt qu'exécuter les scripts à distance, vous pouvez récupérer le contenu de ce dépôt :```
    cd ~
    git clone https://github.com/fran6p/OPiz2.git ```
  - Rendre exécutables les scripts (.sh):```
    cd ~/OPiz2
    chmod +x *.sh```
  - Exécuter chacun des scripts les uns à la suite des autres (étapes 2 à 4 (ou 6)).

:-)   
  
  
 
