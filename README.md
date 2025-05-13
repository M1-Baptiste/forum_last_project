# Forum Anonyme

Un forum anonyme permettant aux utilisateurs de publier des messages sous un pseudonyme sans système d'authentification.

## Architecture

Le projet est composé de 4 services Docker :

1. **API** : Gestion de la création et récupération des messages du forum
2. **DB** : Base de données MongoDB pour stocker les messages
3. **Thread** : Service d'affichage des messages (port 80)
4. **Sender** : Service d'écriture des messages (port 8080)

## Configuration réseau

- Réseau `backend` : Réseau interne isolé d'Internet (API et DB)
- Réseau `frontend` : Réseau bridge pour l'accès externe (Thread et Sender)

## Prérequis

- Docker et Docker Compose
- Node.js (pour le développement)

## Installation

```bash
# Cloner le dépôt
git clone <url-du-repo>
cd forum-anonyme

# Installer les dépendances de développement
npm install

# Construire et démarrer les services
npm run build
npm start
```

## Utilisation

- Accéder à l'interface d'affichage des messages : http://localhost
- Accéder à l'interface d'envoi des messages : http://localhost:8080

## Développement

Ce projet utilise Conventional Commits pour la gestion des versions :

```bash
# Pour faire un commit suivant la convention
npm run commit
```

## CI/CD

Une pipeline CI/CD est configurée pour :
1. Valider le code (linting)
2. Exécuter les tests
3. Construire les images Docker
4. Déployer les images sur le registry GitHub/GitLab 