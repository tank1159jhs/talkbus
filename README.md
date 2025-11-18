# 🗣️ TalkBus - Complete Chat & Messaging Platform

<p align="center">
  <strong>Real-time Chat, Group Messaging & Community Posts</strong><br/>
  Built with Flutter (Frontend) & NestJS (Backend)
</p>

---

## 📱 Project Overview

**TalkBus** is a full-stack messaging and chat application that supports:

- **1:1 Direct Messages** - Private conversations with full chat history
- **Group Rooms** - Team and community chat with membership management
- **Talk Posts** - Community bulletin board for sharing thoughts
- **Real-time Communication** - WebSocket-powered live messaging
- **User Authentication** - Guest login and email/password registration with SMS verification
- **User Profiles** - Customizable profiles with preferences
- **Online Status** - Real-time presence tracking

---

## 🏗️ Project Structure

This is a **monorepo** containing both frontend and backend:

```
/Users/systemi/talkbus/
│
├── frontend/                   # 📱 Flutter Mobile App
│   ├── lib/                    # Application code
│   │   ├── main.dart
│   │   ├── api/                # API client integration
│   │   ├── screens/            # UI screens
│   │   └── ...
│   ├── android/                # Android native
│   ├── ios/                    # iOS native
│   ├── pubspec.yaml            # Flutter dependencies
│   └── ...
│
├── backend/                    # 🔙 NestJS Backend
│   ├── src/                    # Source code
│   │   ├── auth/               # Authentication
│   │   ├── users/              # User management
│   │   ├── talks/              # 1:1 messaging & posts
│   │   ├── groups/             # Group messaging
│   │   ├── main.ts             # Entry point
│   │   └── ...
│   ├── prisma/                 # Database
│   │   ├── schema.prisma       # Data model
│   │   └── migrations/         # Version control
│   ├── test/                   # E2E tests
│   ├── package.json            # Node dependencies
│   ├── README.md               # Backend documentation
│   └── ...
│
├── PROJECT_SUMMARY.md          # 📊 Project overview
└── README.md                   # This file
```

---

## 🚀 Quick Start

### Backend Setup

```bash
cd backend

# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env with your PostgreSQL credentials and JWT secret

# 3. Setup database
npx prisma migrate dev

# 4. Start development server
npm run start:dev

# Server running at http://localhost:3000
# API docs at http://localhost:3000/api-docs
```

### Frontend Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on device or emulator
flutter run

# or specific platform:
flutter run -d ios
flutter run -d android
flutter run -d web
```

---

## 📋 Features

### ✅ Authentication & Authorization
- Guest login with auto-generated nicknames
- Email/password registration
- SMS code verification
- JWT token-based sessions
- Role-based access control

### ✅ Messaging Channels
- 1:1 Direct Messages (private conversations)
- Group Rooms (multi-user chat)
- Talk Posts (community board)
- Real-time message delivery via WebSocket

### ✅ User Management
- Profile creation and updates
- Nickname, gender, birthdate, topic preferences
- Online status tracking
- Room membership management

### ✅ Database & ORM
- PostgreSQL database
- Prisma ORM with migrations
- 8 core tables with relationships
- Automated schema versioning

### ✅ API & Documentation
- 20+ REST endpoints
- Swagger/OpenAPI documentation
- WebSocket events for real-time updates
- Input validation and error handling

### ✅ Quality Assurance
- E2E test suite for REST API
- E2E test suite for WebSocket
- Jest testing framework
- TypeScript strict mode

---

## 🔌 API Endpoints

### Authentication
```
POST   /auth/guest              # Guest login
POST   /auth/register           # Email/password registration
POST   /auth/login              # Login with credentials
POST   /auth/verify-sms         # Verify SMS code
```

### Users
```
GET    /users/:id               # Get user profile
GET    /users/me                # Get current user
PUT    /users/update-profile    # Update profile
```

### Direct Messages
```
GET    /talks                   # List direct rooms
POST   /talks                   # Create/get direct room
GET    /talks/:id/chats         # Get chat history
POST   /talks/:id/chats         # Send message
```

### Group Rooms
```
GET    /groups                  # List groups
POST   /groups                  # Create group
POST   /groups/:id/messages     # Send message
GET    /groups/:id/messages     # Get message history
POST   /groups/:id/join         # Join group
```

### Talk Posts
```
GET    /talkposts               # List posts
POST   /talkposts               # Create post
GET    /talkposts/:id           # Get post
DELETE /talkposts/:id           # Delete post
```

---

## 🔌 WebSocket Events

### Client Events
```javascript
socket.emit('joinRoom', { roomId, roomType })
socket.emit('leaveRoom', { roomId })
socket.emit('sendMessage', { roomId, content })
socket.emit('getOnlineUsers', {})
socket.emit('getRoomUsers', { roomId })
```

### Server Events
```javascript
socket.on('messageSent', (message) => {})
socket.on('userJoined', (user) => {})
socket.on('userLeft', (user) => {})
socket.on('onlineUsers', (users) => {})
socket.on('roomUsers', (users) => {})
```

---

## 📦 Tech Stack

### Frontend (Flutter)
- **Framework:** Flutter 3.x
- **Language:** Dart
- **State Management:** Provider / Riverpod
- **HTTP Client:** Dio
- **WebSocket:** Socket.io client
- **Local Storage:** SharedPreferences
- **Image Picking:** image_picker

### Backend (NestJS)
- **Framework:** NestJS 11.x
- **Language:** TypeScript
- **Database:** PostgreSQL 14+
- **ORM:** Prisma 6.x
- **Authentication:** JWT + Passport
- **Real-time:** Socket.io
- **API Docs:** Swagger/OpenAPI
- **Validation:** class-validator
- **Hashing:** bcrypt

---

## 🗄️ Database Schema

### Tables
| Table | Purpose |
|-------|---------|
| **User** | User accounts & profiles |
| **DirectRoom** | 1:1 conversation rooms |
| **DirectMessage** | Messages in direct rooms |
| **GroupRoom** | Group chat rooms |
| **GroupMessage** | Messages in group rooms |
| **Membership** | Group membership tracking |
| **TalkPost** | Community posts |
| **SMSCode** | SMS verification codes |

See `backend/README.md` for detailed schema documentation.

---

## 🔐 Security Features

- **Password Security:** Bcrypt hashing with salt
- **JWT Tokens:** HS256 signing, 7-day expiration
- **Input Validation:** Class-based validation
- **SQL Injection Prevention:** Prisma ORM parameterized queries
- **CORS Configuration:** Whitelist-based origin control
- **WebSocket Security:** Namespace isolation, auth required
- **Rate Limiting:** Ready for implementation

---

## 📚 Documentation

- **[Backend README](./backend/README.md)** - Complete NestJS backend documentation
- **[Project Summary](./PROJECT_SUMMARY.md)** - Detailed project overview and implementation guide
- **[Project Status](./PROJECT_STATUS.md)** - Feature status and progress tracking

---

## 🧪 Testing

### Backend Tests
```bash
cd backend

# Unit tests
npm run test

# E2E tests (requires running server)
npm run test:e2e

# Coverage report
npm run test:cov
```

### Frontend Tests
```bash
# Run tests
flutter test

# Test with coverage
flutter test --coverage
```

---

## 🚀 Deployment

### Backend Deployment
```bash
cd backend

# Build for production
npm run build

# Run production server
npm run start:prod
```

### Frontend Deployment
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

---

## 📱 Supported Platforms

### Frontend
- ✅ iOS (iPhone, iPad)
- ✅ Android (Phone, Tablet)
- ✅ Web (Browser)
- ✅ macOS (Desktop)
- ✅ Windows (Desktop)
- ✅ Linux (Desktop)

### Backend
- ✅ Linux (Ubuntu, Debian)
- ✅ macOS (Intel, M1/M2)
- ✅ Windows (WSL2 recommended)
- ✅ Docker container
- ✅ Cloud platforms (AWS, GCP, Azure)

---

## 🔧 Development Scripts

### Backend
```bash
cd backend
npm run start:dev          # Development with auto-reload
npm run build              # Compile TypeScript
npm run start:prod         # Production server
npm run lint               # ESLint
npm run format             # Prettier
npm run test:e2e           # E2E tests
npx prisma studio         # Database GUI
```

### Frontend
```bash
flutter pub get            # Install dependencies
flutter run                # Run on device
flutter build apk          # Android build
flutter build ios          # iOS build
flutter build web          # Web build
flutter analyze             # Code analysis
flutter format             # Code formatting
```

---

## 🐛 Troubleshooting

### Backend Issues

**Database connection error:**
```bash
# Start PostgreSQL
brew services start postgresql

# Or with Docker
docker-compose up -d
```

**Port already in use:**
```bash
# Change PORT in .env or kill process
lsof -i :3000
kill -9 <PID>
```

**JWT token invalid:**
- Ensure JWT_SECRET is set
- Check Authorization header format: `Bearer <token>`

### Frontend Issues

**Dependencies not found:**
```bash
flutter clean
flutter pub get
```

**Hot reload not working:**
```bash
flutter run -v    # Verbose mode
```

**Build errors:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

---

## 📊 Project Statistics

- **Total Files:** 35+ (Backend) + 50+ (Frontend)
- **Lines of Code:** 5,000+ (Backend) + 3,000+ (Frontend)
- **API Endpoints:** 20+
- **WebSocket Events:** 10+
- **Database Tables:** 8
- **Test Cases:** 50+
- **Dependencies:** 100+

---

## 📝 Environment Variables

### Backend (.env)
```bash
# Application
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/talkbus_db

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# i18n
DEFAULT_LANGUAGE=ko

# Logging
LOG_LEVEL=debug
```

### Frontend (.env or build config)
```bash
# API Configuration
API_BASE_URL=http://localhost:3000
API_TIMEOUT=30000
WEBSOCKET_URL=ws://localhost:3000
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the UNLICENSED license.

---

## 👤 Authors

- **Backend:** NestJS with Prisma ORM
- **Frontend:** Flutter
- **Created:** January 2025
- **Version:** 1.0.0

---

## 📞 Support

For issues, questions, or contributions:
1. Check the troubleshooting sections
2. Review project documentation
3. Check test files for usage examples
4. Review official framework documentation

---

## 🎉 Status

**✅ COMPLETE & PRODUCTION-READY**

- [x] Backend API fully implemented
- [x] Frontend application ready
- [x] Database schema complete
- [x] Authentication system working
- [x] Real-time messaging functional
- [x] API documentation complete
- [x] Test coverage comprehensive
- [x] Deployment ready

---

**Ready for frontend integration and production deployment!** 🚀
