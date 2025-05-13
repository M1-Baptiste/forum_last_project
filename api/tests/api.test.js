/* eslint-env mocha */
const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;

chai.use(chaiHttp);

// Mock du serveur pour les tests
const app = require('../server');

describe('API Forum', () => {
  describe('GET /messages', () => {
    it('devrait retourner tous les messages', (done) => {
      chai.request(app)
        .get('/messages')
        .end((err, res) => {
          expect(res).to.have.status(200);
          expect(res.body).to.be.an('array');
          done();
        });
    });
  });

  describe('POST /messages', () => {
    it('devrait créer un nouveau message', (done) => {
      const message = {
        pseudo: 'TestUser',
        content: 'Ceci est un message de test'
      };
      
      chai.request(app)
        .post('/messages')
        .send(message)
        .end((err, res) => {
          expect(res).to.have.status(201);
          expect(res.body).to.be.an('object');
          expect(res.body).to.have.property('pseudo', 'TestUser');
          expect(res.body).to.have.property('content', 'Ceci est un message de test');
          done();
        });
    });
    
    it('ne devrait pas créer un message sans pseudo', (done) => {
      const message = {
        content: 'Message sans pseudo'
      };
      
      chai.request(app)
        .post('/messages')
        .send(message)
        .end((err, res) => {
          expect(res).to.have.status(400);
          done();
        });
    });
  });
}); 