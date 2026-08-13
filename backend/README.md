# AmberDesign Backend

Node.js, Express, TypeScript, PostgreSQL/Prisma, and Socket.io backend for the AmberDesign Flutter app and admin panel. Firebase remains optional for Cloud Messaging and Cloud Storage only; it is not the application database.

## Implemented foundation

- PostgreSQL relational schema and initial SQL migration
- Email/password authentication with short-lived JWT access tokens and rotating refresh tokens
- Roles: customer, designer, vendor, moderator, admin
- Profiles, favorites, catalog, approval workflow, reviews, and categories
- Transactional order creation, integer-halalah money values, stock reservation and cancellation restocking
- Community posts, likes, comments, support tickets, CMS, notifications, activities, and AI job records
- PostgreSQL-backed conversations and messages
- Authenticated Socket.io rooms, new-message events, and read receipts
- Designer profiles, portfolio entries, verified-order ratings, and experience data
- Persisted customer notifications and live order Timeline updates
- Supabase/PostgreSQL connection through Prisma

## Local setup

Requirements: Node.js 20+ and access to a PostgreSQL database (the current environment uses Supabase).

```bash
cp .env.example .env
npm install
npm run db:deploy
npm run seed
npm run dev
```

Set `DATABASE_URL` and `DIRECT_URL` in `.env` before deploying migrations. Never commit `.env` or database credentials.

Optional admin seed values:

```env
SEED_ADMIN_EMAIL=admin@example.com
SEED_ADMIN_PASSWORD=use-a-strong-password
```

## Authentication

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `GET /api/v1/auth/me`

Send the access token to REST and Socket.io:

```http
Authorization: Bearer ACCESS_TOKEN
```

```js
const socket = io(API_URL, { auth: { token: accessToken } });
socket.emit("conversation:join", conversationId, console.log);
socket.on("message:new", console.log);
socket.on("messages:read", console.log);
socket.emit("order:join", orderId, console.log);
socket.on("order:status", console.log);
```

Messages are created through `POST /api/v1/chat/conversations/:id/messages`, then broadcast through Socket.io. This keeps validation and persistence in one trusted path.

## Designer portfolio and Timeline

- `GET /api/v1/designers/:id`
- `GET /api/v1/designers/:id/portfolio`
- `GET /api/v1/designers/:id/reviews`
- `PATCH /api/v1/designers/me/profile`
- `POST /api/v1/designers/me/portfolio`
- `PATCH /api/v1/designers/me/portfolio/:itemId`
- `DELETE /api/v1/designers/me/portfolio/:itemId`
- `POST /api/v1/designers/:id/reviews` (requires a completed customer order)
- `GET /api/v1/orders/:id` returns ordered status history for the Timeline
- `GET /api/v1/notifications`
- `POST /api/v1/notifications/:id/read`

## Database commands

```bash
npm run db:generate
npm run db:migrate
npm run db:deploy
npm run db:studio
```

The initial migration is in `prisma/migrations/20260803233000_initial_postgresql/migration.sql`.

## Verification

```bash
npm run lint
npm test
npm run build
```

## Production work still required

- Connect the selected payment gateway and implement signed, idempotent webhooks/refunds.
- Add Firebase phone OTP verification or a selected SMS provider flow.
- Add API/integration tests against a disposable PostgreSQL database.
- Add cursor pagination, follow/report APIs, notification scheduling, file post-processing, backups, monitoring, and CI/CD.
- Configure Firebase credentials only when FCM or Firebase Storage are enabled.
