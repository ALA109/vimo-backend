# ZEGO Token Server (Ready-to-run)

This is a minimal token server for **ZEGOCLOUD** using Express and the official `zego_server_assistant` code (bundled locally, no npm package needed).

It serves as the backend companion for the **Vimo live streaming app**, and exposes a minimal HTTP API that generates ZEGO Cloud tokens using the official `zego_server_assistant` library.

---

## Endpoints

### Health Check
**GET** `/health`  
Response:
```json
{ "status": "ok" }
```

### Token Generation
**POST** `/token`

Body (JSON):
```json
{ "userId": "<viewer_or_host_id>", "roomId": "<live_room_id>" }
```

Response:
```json
{ "token": "<generated_token>" }
```

You can also test it via curl:
```bash
curl -X POST http://localhost:8080/token \
-H "Content-Type: application/json" \
-d '{"userId":"viewer_1","roomId":"test_live"}'
```

---

## Setup
```bash
npm install
cp .env.example .env
# Fill ZEGO_APP_ID and ZEGO_SERVER_SECRET
```

Create the `.env` with these keys:
```bash
ZEGO_APP_ID=YOUR_APP_ID
ZEGO_SERVER_SECRET=YOUR_SERVER_SECRET
PORT=8080
```

---

## Run
```bash
npm start          # legacy GET /zegotoken endpoint
npm run start:zego # hardened POST /token endpoint
```

---

## Test Locally
- http://localhost:8080/health
- curl -X POST http://localhost:8080/token -H "Content-Type: application/json" -d '{"userId":"viewer_1","roomId":"test_live"}'

---

## Android Tips
- Emulator: http://10.0.2.2:8080
- Real device on same Wi-Fi: http://<PC_IP>:8080
- If you must use cleartext HTTP, add inside `<application>` in `AndroidManifest.xml`:
  ```xml
  android:usesCleartextTraffic="true"
  ```

---

## Notes
- Do **not** commit `.env` (already ignored).
- The `zego_server_assistant` directory is bundled locally from the official GitHub repository.
- Rotate your ZEGO secrets periodically and revoke compromised tokens immediately.
