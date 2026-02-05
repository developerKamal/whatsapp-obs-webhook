import express from "express";
import bodyParser from "body-parser";
import OBSWebSocket from "obs-websocket-js";

const app = express();
app.use(bodyParser.urlencoded({ extended: false }));

// ===== CONFIG =====
const OBS_TAILSCALE_IP = process.env.OBS_IP;        // 100.x.x.x
const OBS_PASSWORD = process.env.OBS_PASSWORD;     // OBS websocket wachtwoord

const ALLOWED = new Set([
  "whatsapp:+316XXXXXXXX"
]);

const MAP = {
  taraweeh: "Taraweeh",
  juz: "Juz",
  imam: "Imam Taraweeh",
  r1: "Reciteur 1",
  r2: "Reciteur 2",
  witr: "Reciteur Witr"
};
// ==================

const obs = new OBSWebSocket();

async function connectObs() {
  if (!obs.identified) {
    await obs.connect(`ws://${OBS_TAILSCALE_IP}:4455`, OBS_PASSWORD);
  }
}

app.post("/twilio", async (req, res) => {
  try {
    const from = req.body.From;
    const body = (req.body.Body || "").trim();

    if (!ALLOWED.has(from)) return res.send("Not allowed");

    const m = body.match(/^(\w+)\s*:\s*(.+)$/i);
    if (!m) return res.send("Gebruik: taraweeh: ...");

    const key = m[1].toLowerCase();
    const value = m[2];

    if (!MAP[key]) return res.send("Onbekende key");

    await connectObs();
    await obs.call("SetInputSettings", {
      inputName: MAP[key],
      inputSettings: { text: value },
      overlay: true
    });

    res.send("OK");
  } catch (e) {
    console.error(e);
    res.send("ERR");
  }
});

app.get("/", (_req, res) => res.send("OK"));
app.listen(3000);
