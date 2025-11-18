import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../src/app.module';
import request from 'supertest';
import { Server } from 'http';
import { io as Client, Socket as ClientSocket } from 'socket.io-client';

describe('WebSocket Gateway (e2e)', () => {
  let app: INestApplication;
  let httpServer: Server;
  let baseUrl: string;
  let token: string;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();
    await app.init();
    httpServer = app.getHttpServer();
    const address = httpServer.address();
    if (address && typeof address === 'object') {
      baseUrl = `http://localhost:${address.port}`;
    } else {
      baseUrl = 'http://localhost:3000'; // fallback
    }

    // 회원가입 및 토큰 발급
    const res = await request(httpServer)
      .post('/auth/register')
      .send({ email: 'wsuser@test.com', password: 'test1234' });
    token = res.body.accessToken;
  });

  afterAll(async () => {
    await app.close();
  });

  it('should connect, join room, and send/receive message', (done) => {
    const client: ClientSocket = Client(baseUrl, {
      auth: { token },
      transports: ['websocket'],
    });

    client.on('connect', () => {
      client.emit('joinRoom', { roomId: 'test-room' });
    });

    client.on('userJoined', (data) => {
      expect(data.userId).toBeDefined();
      client.emit('sendMessage', {
        roomId: 'test-room',
        content: 'Hello WebSocket!',
      });
    });

    client.on('newMessage', (msg) => {
      expect(msg.body).toBe('Hello WebSocket!');
      client.disconnect();
      done();
    });

    client.on('error', (err) => {
      client.disconnect();
      done.fail(err);
    });
  });
});
