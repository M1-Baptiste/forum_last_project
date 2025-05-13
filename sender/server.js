const express = require('express');
const axios = require('axios');
const path = require('path');

// Configuration
const app = express();
const PORT = process.env.PORT || 8080;
const API_URL = process.env.API_URL || 'http://api:3000';

// Configuration du moteur de template
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.render('form', { 
    success: null,
    error: null,
    username: '',
    content: ''
  });
});

app.post('/send', async (req, res) => {
  const { username, content } = req.body;
  
  // Validation
  if (!username || !content) {
    return res.render('form', {
      error: 'Le pseudonyme et le contenu sont requis',
      success: null,
      username,
      content
    });
  }
  
  try {
    await axios.post(`${API_URL}/api/messages`, {
      username,
      content
    });
    
    res.render('form', {
      success: 'Message envoyé avec succès',
      error: null,
      username: '',
      content: ''
    });
  } catch (error) {
    console.error('Erreur lors de l\'envoi du message:', error.message);
    res.render('form', {
      error: 'Impossible d\'envoyer le message. Veuillez réessayer plus tard.',
      success: null,
      username,
      content
    });
  }
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Service Sender en écoute sur le port ${PORT}`);
}); 