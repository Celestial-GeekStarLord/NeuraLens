const functions = require("firebase-functions");
const fetch = require("node-fetch");

exports.analyzeImage = functions.https.onRequest(async (req, res) => {
  try {
    const { query, base64Image, mode } = req.body;

    if (!base64Image || !query) {
      return res.status(400).json({ error: "Invalid request" });
    }

    const instruction =
      mode === "list"
        ? "ONLY list visible items/objects in a bullet list. No extra text."
        : "Describe the scene clearly and concisely for voice narration.";

    const body = {
      contents: [
        {
          role: "user",
          parts: [
            { text: `${instruction}\n\nUser request: ${query}` },
            {
              inline_data: {
                mime_type: "image/jpeg",
                data: base64Image,
              },
            },
          ],
        },
      ],
    };

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${functions.config().gemini.key}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      }
    );

    const data = await response.json();
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: error.toString() });
  }
});
