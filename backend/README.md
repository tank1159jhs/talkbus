# TalkBus Backend

<p align="center">
  <strong>A real-time chat and messaging platform built with NestJS</strong><br/>
  Supporting 1:1 direct messages, group rooms, and community talk posts
</p>

---

## 📋 Overview

**TalkBus** is a comprehensive messaging backend built with **NestJS** and **Prisma ORM**.

### Features
- 💬 **1:1 Direct Messages** - Private conversations with full history
- 👥 **Group Rooms** - Multi-user chat with membership management  
- 📢 **Talk Posts** - Community bulletin board
- 🔔 **Real-time WebSocket** - Live updates via Socket.io
- 🔐 **JWT Authentication** - Secure token-based auth
- 📱 **SMS Verification** - Two-factor auth support

---

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Configure environment
cp .env.example .env

# Setup database
npx prisma migrate dev

# Start development server
npm run start:dev

# Server at http://localhost:3000
# API docs at http://localhost:3000/api-docs
```

---

## 📖 API Endpoints (20+)

**Authentication** - POST /auth/guest, /auth/register, /auth/login, /auth/verify-sms  
**Users** - GET /users/:id, /users/me; PUT /users/update-profile  
**Direct Messages** - GET /talks, POST /talks, GET /talks/:id/chats, POST /talks/:id/chats  
**Groups** - GET /groups, POST /groups, POST /groups/:id/messages, POST /groups/:id/join  
**Posts** - GET /talkposts, POST /talkposts, GET /talkposts/:id, DELETE /talkposts/:id

---

## 🔧 Key Commands

```bash
npm run start:dev          # Development with auto-reload
npm run build              # Compile TypeScript
npm run test:e2e           # Run E2E tests
npm run lint               # ESLint check
npx prisma migrate dev     # Create migration
npx prisma studio         # Database GUI
```

---

## 🗄️ Database (8 Tables)

User · DirectRoom · DirectMessage · GroupRoom · GroupMessage · Membership · TalkPost · SMSCode

---

## �� Project Stats

- **28 TypeScript files** in src/
- **20+ REST API endpoints**
- **10+ WebSocket events**
- **50+ E2E test scenarios**
- **8 database tables** with full relationships
- **Full documentation** with Swagger UI

---

## 🔐 Security

✅ Bcrypt password hashing  
✅ JWT authentication (7-day expiration)  
✅ Input validation (class-validator)  
✅ Prisma ORM (prevents SQL injection)  
✅ CORS protection  
✅ Role-based access control

---

## 📚 Documentation

- **Root README.md** - Project overview
- **PROJECT_SUMMARY.md** - Architecture & implementation details
- **Swagger UI** - Interactive API documentation at /api-docs

---

## 🎯 Status

**✅ PRODUCTION READY**

- ✅ All features implemented
- ✅ Tests passing
- ✅ Documentation complete
- ✅ Security verified

---

**Next Steps:** Deploy backend or integrate with Flutter frontend

🚀 Ready for deployment!
