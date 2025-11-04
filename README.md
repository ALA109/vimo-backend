# ZEGO Token Server

Backend companion for the Vimo live streaming app. It exposes a minimal HTTP API that generates ZEGO Cloud tokens using the official `zego_server_assistant`.

## Endpoints

- `GET /health` → `{ "status": "ok" }`
- `POST /token` → `{ "token": "..." }`
  - Body (JSON): `{ "userId": "<viewer_or_host_id>", "roomId": "<live_room_id>" }`

## Setup

```bash
npm install
cp .env.example .env   # fill ZEGO_APP_ID, ZEGO_SERVER_SECRET, optional callback values
```

## Run

```bash
npm start              # uses server.js (legacy GET endpoint)
# or
npm run start:zego     # uses src/server/zego-server.js (POST /token endpoint)
```

## Testing

- Health:  `http://localhost:8080/health`
- Token:   `curl -X POST http://localhost:8080/token -H "Content-Type: application/json" -d '{"userId":"viewer_1","roomId":"test_live"}'`

### Android notes

- Emulator: `http://10.0.2.2:8080`
- Real device on same Wi‑Fi: `http://<PC_IP>:8080`
- If using plain HTTP, add inside `<application>` in `AndroidManifest.xml`:
  ```xml
  android:usesCleartextTraffic="true"
  ```

## Notes

- Do **not** commit `.env` (already ignored).
- The `zego_server_assistant` directory is bundled locally from the official GitHub repository.
