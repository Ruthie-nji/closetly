// functions/index.js

const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });
const express = require("express");

const app = express();
app.use(cors);
app.use(express.json());

app.post("/getOutfits", (req, res) => {
  const { images = [], category = "All" } = req.body;
  const outfits = [
    /* your two mock objects */
  ];
  res.status(200).json({ recommendations: outfits });
});

exports.api = functions.https.onRequest(app);
