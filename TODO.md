# TODO: Fix Zego Token Timeout Error

## Steps to Complete
- [x] Add POST /token endpoint to backend/server.js to handle JSON requests from LiveTokenService
- [x] Update lib/constants/app_config.dart to use localhost URL (http://localhost:8080/token) for local testing
- [x] Ensure backend/.env has ZEGO_APP_ID and ZEGO_SERVER_SECRET configured (server started successfully, so likely configured)
- [x] Run the backend server locally (cd backend && npm start)
- [x] Test the new POST /token endpoint manually (e.g., using curl or Postman)
- [x] Run the Flutter app and test live session start to confirm token fetching works (tested locally, but deployed server still times out)
- [x] Revert app_config.dart to deployed URL (https://vimo-backend-ctgd.onrender.com/token) and test again
