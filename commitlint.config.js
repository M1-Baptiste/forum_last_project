module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // Nouvelles fonctionnalités
        'fix',      // Corrections de bugs
        'docs',     // Documentation
        'style',    // Changements de style (formatage, etc.)
        'refactor', // Réfactorisation du code
        'perf',     // Améliorations des performances
        'test',     // Ajout ou modification de tests
        'build',    // Système de build ou dépendances externes
        'ci',       // Configuration CI et scripts
        'chore',    // Tâches diverses
        'revert'    // Annulation d'un commit précédent
      ]
    ],
    'subject-case': [0] // Désactive la vérification de la casse pour le sujet
  }
}; 