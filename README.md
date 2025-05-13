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

- Accéder à l'interface d'affichage des messages : http://localhost:81
- Accéder à l'interface d'envoi des messages : http://localhost:8090

## Développement

Ce projet utilise Conventional Commits pour la gestion des versions :

```bash
# Pour faire un commit suivant la convention
npm run commit

# Pour exécuter les tests
npm test

# Pour générer un changelog
npm run changelog

# Pour créer une nouvelle version
npm run release
```

## CI/CD

Une pipeline CI/CD est configurée pour :
1. Valider le code (linting)
2. Exécuter les tests automatisés
3. Construire les images Docker
4. Déployer les images sur le registry GitHub
5. Mettre à jour automatiquement le changelog

## Gestion de versions et Changelog

Le projet utilise :
- **Commitizen** : Pour faciliter l'utilisation de la convention Conventional Commits
- **Commitlint** : Pour valider que les messages de commit suivent la convention
- **Standard-version** : Pour automatiser la gestion des versions
- **Conventional-changelog** : Pour générer automatiquement le changelog

Ces outils permettent une gestion automatisée des versions et facilitent la génération des changelogs.

## Structure du projet

```
forum-anonyme/
├── api/               # Service API
│   ├── server.js      # Serveur Express
│   ├── Dockerfile     # Configuration Docker
│   └── tests/         # Tests automatisés
├── db/                # Configuration de la base de données
├── thread/            # Service d'affichage
│   ├── server.js      # Serveur Express
│   ├── Dockerfile     # Configuration Docker
│   └── tests/         # Tests automatisés
├── sender/            # Service d'envoi
│   ├── server.js      # Serveur Express
│   ├── Dockerfile     # Configuration Docker
│   └── tests/         # Tests automatisés
├── docker-compose.yml # Configuration Docker Compose
├── .github/workflows/ # Pipelines CI/CD
└── CHANGELOG.md       # Historique des changements
``` 