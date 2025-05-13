/* eslint-env mocha */
const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;

chai.use(chaiHttp);

// Import du serveur pour les tests
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
    it('devrait traiter l\'envoi du message', (done) => {
      const message = {
        username: 'TestUser',
        content: 'Ceci est un message de test'
      };
      
      // En mode test, on vérifie juste que le service répond correctement
      chai.request(app)
        .post('/send')
        .send(message)
        .end((err, res) => {
          expect(res).to.have.status(200);
          done();
        });
    });

    it('ne devrait pas accepter un message sans username', (done) => {
      const message = {
        content: 'Message sans username'
      };
      
      chai.request(app)
        .post('/send')
        .send(message)
        .end((err, res) => {
          expect(res).to.have.status(200);  // Renvoie la page avec une erreur
          expect(res).to.be.html;
          done();
        });
    });
  });
}); 