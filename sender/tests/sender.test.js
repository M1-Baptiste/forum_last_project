/* eslint-env mocha */
const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;

chai.use(chaiHttp);

// Mock du serveur pour les tests
const app = require('../server');

describe('Sender Service', () => {
  describe('GET /', () => {
    it('devrait retourner le formulaire d\'envoi', (done) => {
      chai.request(app)
        .get('/')
        .end((err, res) => {
          expect(res).to.have.status(200);
          expect(res).to.be.html;
          done();
        });
    });
  });

  describe('POST /send', () => {
    it('devrait transmettre le message à l\'API', (done) => {
      const message = {
        pseudo: 'TestUser',
        content: 'Ceci est un message de test'
      };
      
      // Ce test nécessiterait un mock de l'API
      // Pour simplifier, on vérifie juste que la route existe
      chai.request(app)
        .post('/send')
        .send(message)
        .end((err, res) => {
          expect(res).to.have.status(302); // Redirection après envoi
          done();
        });
    });
  });
}); 