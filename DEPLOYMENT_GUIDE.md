# TalkBus Deployment Guide

## 🚀 Project Status

**Status:** ✅ Production Ready v1.0.0  
**Last Updated:** November 18, 2025  
**Git Repository:** Initialized with root commit  
**Essential Files:** 79 (TS, Dart, MD, JSON, YAML - build artifacts excluded)

---

## 📦 Project Structure

```
/Users/systemi/talkbus/
├── backend/                          # NestJS REST API + WebSocket
│   ├── src/
│   │   ├── auth/                     # Authentication module (5 files)
│   │   ├── users/                    # User management (3 files)
│   │   ├── talks/                    # 1:1 messaging + posts (8 files)
│   │   ├── groups/                   # Group chat (3 files)
│   │   ├── main.ts                   # Application entry point
│   │   ├── app.module.ts             # Root module
│   │   └── prisma.service.ts         # Database service
│   ├── prisma/
│   │   ├── schema.prisma             # 8 database tables
│   │   └── migrations/               # 7+ migration files
│   ├── test/                         # E2E tests
│   ├── package.json                  # 45+ npm dependencies
│   └── docker-compose.yml            # PostgreSQL setup
│
├── lib/                              # Flutter mobile app
│   ├── main.dart                     # App entry point
│   ├── api/                          # API client & models
│   ├── l10n/                         # Localization (EN, JA)
│   └── screens/                      # 16 UI screens
│
├── android/                          # Android platform code
├── ios/                              # iOS platform code
├── web/                              # Web platform code
├── linux/, macos/, windows/          # Desktop platforms
│
├── README.md                         # Main project documentation
├── PROJECT_SUMMARY.md                # Architecture & implementation
├── IMPLEMENTATION_COMPLETE.md        # Completion checklist
└── DEPLOYMENT_GUIDE.md               # This file
```

---

## 🛠️ Backend Setup

### Prerequisites
- Node.js 18+ and npm
- PostgreSQL 14+
- Docker (optional, for PostgreSQL)

### Installation

```bash
cd /Users/systemi/talkbus/backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Edit .env with your configuration:
# - DATABASE_URL=postgresql://user:password@localhost:5432/talkbus
# - JWT_SECRET=your-secret-key
# - JWT_EXPIRATION=7d
# - TWILIO_ACCOUNT_SID=your-account-sid (optional, for SMS)
# - TWILIO_AUTH_TOKEN=your-auth-token (optional)
```

### Database Setup

**Option 1: Using Docker**
```bash
cd /Users/systemi/talkbus/backend
docker-compose up -d

# Run migrations
npx prisma migrate deploy
```

**Option 2: Manual PostgreSQL**
```bash
# Create database
createdb talkbus

# Run migrations
npx prisma migrate deploy

# Seed with sample data (optional)
npx prisma db seed
```

### Build & Run

```bash
# Development
npm run start:dev

# Production build
npm run build
npm run start:prod

# Tests
npm run test
npm test:e2e
```

### API Documentation

Once running, access Swagger/OpenAPI docs at:
```
http://localhost:3000/api-docs
```

### API Endpoints (20+)

#### Authentication (5)
- `POST /auth/register` - Email registration
- `POST /auth/login` - Email login
- `POST /auth/guest` - Guest login
- `POST /auth/sms-verify` - SMS verification
- `GET /auth/profile` - Current user profile

#### Users (4)
- `GET /users` - Get all users
- `GET /users/:id` - Get user profile
- `PATCH /users/:id` - Update profile
- `GET /users/:id/online` - Check online status

#### 1:1 Messaging (6)
- `POST /talks/start` - Start conversation
- `GET /talks/rooms` - Get all rooms
- `GET /talks/rooms/:id` - Get room details
- `GET /talks/rooms/:id/messages` - Get message history
- `POST /talks/rooms/:id/messages` - Send message
- `DELETE /talks/messages/:id` - Delete message

#### Groups (5)
- `POST /groups` - Create group
- `GET /groups` - List groups
- `GET /groups/:id` - Get group details
- `POST /groups/:id/members` - Join group
- `DELETE /groups/:id/members/:userId` - Leave group

#### Talk Posts (3)
- `POST /talks/posts` - Create post
- `GET /talks/posts` - List posts
- `DELETE /talks/posts/:id` - Delete post

---

## 🎯 WebSocket Events (10+)

### Real-time Communication

**Join/Leave:**
- `joinRoom` - Join chat room
- `leaveRoom` - Leave chat room

**Messaging:**
- `sendMessage` - Send message to room
- `messageSent` - Broadcast message to room
- `messageDeleted` - Broadcast message deletion

**Presence:**
- `getOnlineUsers` - Query online users
- `getRoomUsers` - Query room members
- `userJoined` - User joined broadcast
- `userLeft` - User left broadcast
- `userTyping` - User typing indicator (future)

### Example Connection

```javascript
// Client (Flutter/JS)
const socket = io('http://localhost:3000', {
  auth: { token: 'jwt-token' }
});

socket.on('connect', () => {
  socket.emit('joinRoom', { roomId: 'room-123' });
  socket.emit('sendMessage', { 
    roomId: 'room-123',
    content: 'Hello!' 
  });
});

socket.on('messageSent', (data) => {
  console.log('New message:', data);
});
```

---

## 📱 Frontend Setup (Flutter)

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- iOS 12+, Android 5.0+

### Installation

```bash
cd /Users/systemi/talkbus

# Get dependencies
flutter pub get

# Configure API URL
# Edit lib/api/api_client.dart:
# - Set const String apiUrl = 'http://your-backend-url:3000';
```

### Build & Run

```bash
# Run on device/simulator
flutter run

# Build APK (Android)
flutter build apk

# Build iOS App
flutter build ios

# Build web
flutter build web
```

### Localization

Supports English and Japanese. Set in main.dart:
```dart
locale: Locale('en') // or Locale('ja')
```

---

## 🗄️ Database Schema

### 8 Tables with Relationships

1. **User**
   - id, email, nickname, passwordHash
   - Profile: gender, birthdate, topic, bio
   - isGuest, onlineStatus, createdAt, updatedAt

2. **DirectRoom**
   - id, participant1Id, participant2Id, createdAt

3. **DirectMessage**
   - id, roomId, senderId, content, createdAt

4. **GroupRoom**
   - id, name, description, isPublic, ownerId, createdAt

5. **GroupMessage**
   - id, roomId, senderId, content, createdAt

6. **Membership**
   - id, userId, roomId, role (OWNER/MEMBER), joinedAt

7. **TalkPost**
   - id, authorId, content, createdAt, updatedAt

8. **SMSCode**
   - id, phoneNumber, code, verified, expiresAt

---

## 🔒 Security

### Implemented Features
- ✅ **Authentication**
  - JWT tokens (7-day expiration, HS256)
  - Bcrypt password hashing
  - SMS verification (mock mode ready)
  - Guest login support

- ✅ **Authorization**
  - Role-based access control (OWNER/MEMBER)
  - Ownership-based deletion
  - Protected routes with JWT guard

- ✅ **Input Validation**
  - Class-validator DTOs
  - Email format validation
  - Length constraints
  - SQL injection prevention

- ✅ **CORS Protection**
  - Configurable origins
  - Credentials allowed
  - Preflight requests handled

### Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/talkbus

# JWT
JWT_SECRET=your-very-secure-secret-key-min-32-chars
JWT_EXPIRATION=7d

# Twilio (SMS)
TWILIO_ACCOUNT_SID=your-sid
TWILIO_AUTH_TOKEN=your-token
TWILIO_PHONE_NUMBER=+1234567890

# Server
PORT=3000
NODE_ENV=production
CORS_ORIGIN=http://localhost:3000,https://yourdomain.com

# Logging
LOG_LEVEL=info
```

---

## 🚢 Production Deployment

### Cloud Platform Options

#### AWS (Recommended)
```bash
# ECS + RDS setup
1. Create RDS PostgreSQL instance
2. Deploy to ECS/Fargate
3. Configure CloudWatch logging
4. Set up ALB for HTTPS
5. Enable auto-scaling
```

#### Google Cloud
```bash
# Cloud Run + Cloud SQL
1. Create Cloud SQL PostgreSQL
2. Deploy to Cloud Run
3. Configure Cloud Armor for DDoS
4. Set up Cloud CDN
```

#### Azure
```bash
# App Service + Azure Database
1. Create Azure Database for PostgreSQL
2. Deploy to App Service
3. Configure Application Insights
4. Set up Application Gateway
```

#### Heroku
```bash
# Heroku deployment
heroku create talkbus
heroku addons:create heroku-postgresql:standard-0
git push heroku main
heroku open
```

### Pre-Deployment Checklist

- [ ] Environment variables configured for production
- [ ] Database migrations tested
- [ ] SSL/HTTPS certificate installed
- [ ] CORS origins properly configured
- [ ] Database backups scheduled
- [ ] Monitoring and logging enabled
- [ ] Rate limiting configured
- [ ] Load testing completed
- [ ] Security headers configured
- [ ] GDPR/Privacy policy reviewed

### Docker Deployment

```dockerfile
# Dockerfile for backend
FROM node:18-alpine

WORKDIR /app
COPY backend/package*.json ./
RUN npm ci --only=production

COPY backend/src ./src
COPY backend/prisma ./prisma
RUN npm run build

EXPOSE 3000
CMD ["npm", "run", "start:prod"]
```

```bash
# Build and run
docker build -t talkbus:latest .
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://... \
  -e JWT_SECRET=... \
  talkbus:latest
```

---

## 📊 Performance Optimization

### Caching Strategy
- Redis for session caching (future enhancement)
- Client-side JWT token caching
- WebSocket connection pooling

### Database Optimization
- Indexed queries (user IDs, room IDs)
- Connection pooling enabled
- Query optimization in Prisma

### Load Testing

```bash
# Using Apache Bench
ab -n 1000 -c 100 http://localhost:3000/health

# Using k6
npm install -g k6
k6 run backend/test/load-test.js
```

---

## 📈 Monitoring & Logging

### Recommended Tools
- **Logging**: Winston or Bunyan
- **Monitoring**: DataDog, New Relic, or Prometheus
- **Error Tracking**: Sentry
- **Analytics**: Google Analytics (mobile)

### Health Check Endpoint
```bash
GET http://localhost:3000/health
# Returns: { "status": "ok", "timestamp": "..." }
```

---

## 🐛 Troubleshooting

### Common Issues

**1. Database Connection Error**
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```
Solution: Ensure PostgreSQL is running and DATABASE_URL is correct

**2. JWT Token Invalid**
```
Error: Invalid token
```
Solution: Ensure JWT_SECRET matches between backend instances

**3. CORS Error**
```
Access to XMLHttpRequest blocked by CORS policy
```
Solution: Add frontend URL to CORS_ORIGIN in .env

**4. WebSocket Connection Failed**
```
WebSocket connection failed
```
Solution: Ensure websocket port is not blocked by firewall

---

## 📞 Support & Maintenance

### Regular Maintenance Tasks
- Weekly: Monitor logs for errors
- Monthly: Review performance metrics
- Quarterly: Update dependencies
- Annually: Security audit

### Backup Strategy
- Daily: Automated database backups
- Weekly: Full application backup
- Monthly: Archive to cold storage

### Update Process
1. Test updates in staging environment
2. Create database backup
3. Deploy to production during low-traffic period
4. Monitor for errors for 1 hour
5. Keep rollback plan ready

---

## 📚 Additional Resources

- **NestJS Documentation**: https://docs.nestjs.com
- **Prisma ORM**: https://www.prisma.io/docs
- **Socket.io**: https://socket.io/docs
- **Flutter Documentation**: https://flutter.dev/docs
- **PostgreSQL Documentation**: https://www.postgresql.org/docs

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Nov 18, 2025 | Initial production release |

---

## 📄 License

[Add your license here]

---

**Ready to Deploy!** 🎉

For questions or issues, refer to the README.md or PROJECT_SUMMARY.md files.
