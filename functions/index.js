const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });

// A dummy “AI” endpoint returning static outfit suggestions.
// Later you’ll swap this for your real AI logic.
exports.getOutfits = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const { images = [], category = "All" } = req.body;
    // TODO: plug-in real AI here. For now, return some mock data:
    const outfits = [
      {
        title: `${category} Look #1`,
        images: [
          "https://via.placeholder.com/100x150.png?text=Outfit1A",
          "https://via.placeholder.com/100x150.png?text=Outfit1B"
        ]
      },
      {
        title: `${category} Look #2`,
        images: [
          "https://via.placeholder.com/100x150.png?text=Outfit2A",
          "https://via.placeholder.com/100x150.png?text=Outfit2B"
        ]
      }
    ];
    res.status(200).json(outfits);
  });
});

