const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');

// Configuration
const app = express();
const PORT = process.env.PORT || 3000;
const DATABASE_URL = process.env.DATABASE_URL || 'mongodb://localhost:27017/forum';

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Connexion à la base de données
const connectDB = async () => {
  try {
    await mongoose.connect(DATABASE_URL);
    console.log('Connexion à MongoDB réussie');
  } catch (err) {
    console.error('Erreur de connexion à MongoDB:', err);
  }
};

// Modèle de données
const messageSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    trim: true
  },
  content: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Message = mongoose.model('Message', messageSchema);

// Routes
app.get('/api/messages', async (req, res) => {
  try {
    const messages = await Message.find().sort({ createdAt: -1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors de la récupération des messages' });
  }
});

app.post('/api/messages', async (req, res) => {
  try {
    const { username, content } = req.body;
    
    if (!username || !content) {
      return res.status(400).json({ error: 'Le pseudonyme et le contenu sont requis' });
    }
    
    const newMessage = new Message({ username, content });
    await newMessage.save();
    
    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors de la création du message' });
  }
});

// Démarrage du serveur seulement si ce fichier est exécuté directement (pas importé comme module)
let server;
if (require.main === module) {
  connectDB();
  server = app.listen(PORT, () => {
    console.log(`API du forum en écoute sur le port ${PORT}`);
  });
} else {
  // Si importé comme module (pour les tests), juste se connecter à la BD
  connectDB();
}

module.exports = { app, server }; 