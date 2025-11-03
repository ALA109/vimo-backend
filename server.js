const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Import local ZEGO assistant (bundled from official repo)
const { generateToken04 } = require('./zego_server_assistant/server/zegoServerAssistant');

const app = express();
app.use(cors());
app.use(express.json());

const APP_ID = Number(process.env.ZEGO_APP_ID || 0);
const SERVER_SECRET = process.env.ZEGO_SERVER_SECRET || '';
const PORT = Number(process.env.PORT || 8080);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.get('/zegotoken', (req, res) => {
  try {
    if (!APP_ID || !SERVER_SECRET) {
      return res.status(400).json({
        error: 'Missing ZEGO_APP_ID or ZEGO_SERVER_SECRET in .env'
      });
    }
    const userID = String(req.query.userID || '').trim();
    if (!userID) {
      return res.status(400).json({ error: 'Query param "userID" is required' });
    }

    const token = generateToken04(APP_ID, userID, SERVER_SECRET, 3600, '');
    res.json({ token });
  } catch (e) {
    console.error('Token error:', e);
    res.status(500).json({ error: 'Failed to generate token' });
  }
});

app.listen(PORT, () => {
  console.log(`ZEGO token server on ${PORT}`);
});
