const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const dotenv = require("dotenv");
const { generateToken04 } = require("../../zego_server_assistant/server/zegoServerAssistant");

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(rateLimit({ windowMs: 60 * 1000, max: 120 }));

const PORT = process.env.PORT || 8080;
const ZEGO_APP_ID = Number(process.env.ZEGO_APP_ID);
const ZEGO_SERVER_SECRET = process.env.ZEGO_SERVER_SECRET;

app.get("/", (_, res) => res.send("ZEGO Token Server Ready"));

app.post("/token", (req, res) => {
  try {
    const { userId, roomId } = req.body;
    if (!userId || !roomId) {
      return res.status(400).json({ error: "Missing userId or roomId" });
    }

    const token = generateToken04(
      ZEGO_APP_ID,
      userId,
      ZEGO_SERVER_SECRET,
      3600, // effectiveTimeInSeconds
      ""
    );

    res.json({ token });
  } catch (err) {
    console.error("Token generation error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => console.log(`ZEGO token server running on port ${PORT}`));
