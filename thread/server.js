const express = require('express');
const axios = require('axios');
const path = require('path');

// Configuration
const app = express();
const PORT = process.env.PORT || 80;
const API_URL = process.env.API_URL || 'http://api:3000';

// Configuration du moteur de template
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', async (req, res) => {
  try {
    const response = await axios.get(`${API_URL}/api/messages`);
    res.render('index', { messages: response.data });
  } catch (error) {
    console.error('Erreur lors de la récupération des messages:', error.message);
    res.render('index', { 
      messages: [],
      error: 'Impossible de récupérer les messages. Veuillez réessayer plus tard.'
    });
  }
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Service Thread en écoute sur le port ${PORT}`);
}); 