/* eslint-env mocha */
const chai = require('chai');
const chaiHttp = require('chai-http');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const expect = chai.expect;

chai.use(chaiHttp);

let app, server;
let mongoServer;

before(async function() {
  this.timeout(10000); // Augmenter le timeout pour le démarrage de MongoDB Memory Server
  
  // Démarrer une instance MongoDB en mémoire pour les tests
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  
  // Fermer toute connexion existante
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
  }
  
  // Se connecter à la BD en mémoire
  await mongoose.connect(mongoUri);
  
  // Charger le app sans démarrer le serveur
  process.env.NODE_ENV = 'test';
  process.env.DATABASE_URL = mongoUri;
  
  // Import après avoir configuré l'environnement
  const appModule = require('../server');
  app = appModule.app;  // Supposons que server.js exporte { app }
});

after(async () => {
  if (server) server.close();
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('API Forum', () => {
  beforeEach(async () => {
    // Vider la base de données avant chaque test
    if (mongoose.connection.readyState !== 0) {
      const collections = await mongoose.connection.db.collections();
      for (const collection of collections) {
        await collection.deleteMany({});
      }
    }
  });

  describe('GET /api/messages', () => {
    it('devrait retourner tous les messages', async () => {
      const res = await chai.request(app).get('/api/messages');
      expect(res).to.have.status(200);
      expect(res.body).to.be.an('array');
    });
  });

  describe('POST /api/messages', () => {
    it('devrait créer un nouveau message', async () => {
      const message = {
        username: 'TestUser',
        content: 'Ceci est un message de test'
      };

      const res = await chai.request(app)
        .post('/api/messages')
        .send(message);
      
      expect(res).to.have.status(201);
      expect(res.body).to.be.an('object');
      expect(res.body).to.have.property('username', 'TestUser');
      expect(res.body).to.have.property('content', 'Ceci est un message de test');
    });

    it('ne devrait pas créer un message sans username', async () => {
      const message = {
        content: 'Message sans username'
      };

      const res = await chai.request(app)
        .post('/api/messages')
        .send(message);
      
      expect(res).to.have.status(400);
    });
  });
});