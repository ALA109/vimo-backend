ZEGO Token Server (Ready-to-run)

This is a minimal token server for ZEGOCLOUD using Express and the official zego_server_assistant code (bundled locally, no npm package needed).

It serves as the backend companion for the Vimo live streaming app, exposing a minimal HTTP API that generates ZEGO Cloud tokens using the official zego_server_assistant library.

Endpoints
----------
GET /health → { "status": "ok" }

GET /zegotoken?userID=<id> → { "token": "..." }

POST /token → { "token": "..." }
Body (JSON): { "userId": "<viewer_or_host_id>", "roomId": "<live_room_id>" }

Setup
-----
npm install
cp .env.example .env
Then open .env and fill in:
ZEGO_APP_ID=YOUR_APP_ID
ZEGO_SERVER_SECRET=YOUR_SERVER_SECRET
PORT=8080

Do not commit .env (it is ignored by Git).

Run
---
npm start              (uses server.js legacy GET endpoint)
npm run start:zego     (uses src/server/zego-server.js POST /token endpoint)

Testing
-------
Health:  http://localhost:8080/health
Token via cURL:
curl -X POST http://localhost:8080/token -H "Content-Type: application/json" -d '{"userId":"viewer_1","roomId":"test_live"}'

Android Notes
--------------
Emulator: http://10.0.2.2:8080
Real device on same Wi-Fi: http://<PC_IP>:8080
If using HTTP, add inside <application> in AndroidManifest.xml:
android:usesCleartextTraffic="true"

Notes
------
Do not commit .env.
The zego_server_assistant directory is included locally from the official ZEGOCLOUD repository.
Rotate your ZEGO secrets periodically and revoke compromised tokens immediately.
Backend tested and optimized for Node.js 18+.
"# vimo-backend" 
"# vimo-backend" 
"# vimo-backend" 
"# vimo-backend" 
"# vimo-backend" 
"# vimo-backend" 
"# vimo-backend" 
"# vimo-backend" 
"# vimo-backend" 
