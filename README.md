# Secure Token Backend (VideoSDK + ZEGOCLOUD)

A hardened Express backend that issues access tokens for **VideoSDK** and **ZEGOCLOUD**, with best practices:
- Strict **CORS allowlist**
- **Helmet** for secure headers
- **Rate limiting**
- **JSON size limits**
- **Input validation (zod)**
- **Environment validation (envalid)**
- No secrets in repo; `.env.example` provided only

---

## Quick Start

```bash
npm ci
# Videosdk server
node src/server/videosdk-server.js
# Zego server
node src/server/zego-server.js
```

Or use package scripts:

```bash
npm run start:videosdk
npm run start:zego
```

## Environment

Copy `.env.example` to your deployment as environment variables (do **not** commit `.env`).

Required keys:
- `VIDEOSDK_API_KEY`, `VIDEOSDK_SECRET`
- `ZEGO_APP_ID`, `ZEGO_SERVER_SECRET`

Optional:
- `CORS_ORIGINS` — comma separated allowlist
- `VIDEOSDK_PORT` (default 9090), `ZEGO_PORT` (default 8080)
- `*_TOKEN_TTL_SECONDS` defaults provided

## Endpoints

### VideoSDK
- `GET /health` → `{ ok: true }`
- `POST /videosdk/token`
  - Body:
    ```json
    {
      "permissions": ["allow_join"],
      "ttl": 3600
    }
    ```
  - Response: `{ "token": "..." }`

### ZEGOCLOUD
- `GET /health` → `{ ok: true }`
- `POST /zego/token`
  - Body:
    ```json
    {
      "userId": "user-123",
      "roomId": "room-xyz",
      "ttl": 7200,
      "privilege": { "joinRoom": 1, "publishStream": 1 }
    }
    ```

## Security Notes

- Ensure **CORS_ORIGINS** only lists your front-end origins.
- Tokens are time-bound; requests exceeding max TTL are clamped.
- Rotate secrets periodically.
- Consider WAF / IP allowlists for extra protection.

## License

MIT
