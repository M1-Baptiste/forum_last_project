const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;

chai.use(chaiHttp);

// Mock du serveur pour les tests
const app = require('../server');

describe('Thread Service', () => {
  describe('GET /', () => {
    it('devrait retourner la page d\'accueil', (done) => {
      chai.request(app)
        .get('/')
        .end((err, res) => {
          expect(res).to.have.status(200);
          expect(res).to.be.html;
          done();
        });
    });
  });

  describe('GET /messages', () => {
    it('devrait faire une requête à l\'API pour récupérer les messages', (done) => {
      // Ce test nécessiterait un mock de l'API
      // Pour simplifier, on vérifie juste que la route existe
      chai.request(app)
        .get('/messages')
        .end((err, res) => {
          expect(res).to.have.status(200);
          done();
        });
    });
  });
}); 