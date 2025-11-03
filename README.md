# ZEGO Token Server (Ready-to-run)

This is a minimal token server for **ZEGOCLOUD** using Express and the official `zego_server_assistant` code
(bundled locally, no npm package needed). It exposes:

- `GET /health` → `{ "status": "ok" }`
- `GET /zegotoken?userID=<id>` → `{ "token": "..." }`

## 1) Setup
```bash
npm install
copy .env.example .env   # then fill ZEGO_APP_ID and ZEGO_SERVER_SECRET
```

## 2) Run
```bash
npm start
# or: node server.js
```

## 3) Test
- Health:  http://localhost:8080/health
- Token:   http://localhost:8080/zegotoken?userID=test

### Android notes
- On an **emulator**, use:   http://10.0.2.2:8080
- On a **real device** on the same Wi‑Fi, use the PC IP:  http://<PC_IP>:8080
- If using HTTP on Android, add to AndroidManifest inside `<application>`:
  ```xml
  android:usesCleartextTraffic="true"
  ```

## Notes
- Do **not** commit `.env`.
- The `zego_server_assistant` folder is included locally (taken from the official repo).
