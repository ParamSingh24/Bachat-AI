const express = require('express');
const cors = require('cors');
const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Chat route proxy
app.post('/api/chat', async (req, res) => {
    try {
        const { text } = req.body;
        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`;
        
        const response = await axios.post(url, {
            contents: [{ parts: [{ text }] }]
        });
        
        res.json(response.data);
    } catch (error) {
        console.error("Gemini Chat Error:", error?.response?.data || error.message);
        res.status(500).json({ error: error?.response?.data || 'Failed to communicate with Gemini API' });
    }
});

// OCR route proxy
app.post('/api/ocr', async (req, res) => {
    try {
        const { prompt } = req.body;
        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`;
        
        const response = await axios.post(url, {
            contents: [{"parts":[{"text": prompt}]}]
        });
        
        res.json(response.data);
    } catch (error) {
        console.error("Gemini OCR Error:", error?.response?.data || error.message);
        res.status(500).json({ error: error?.response?.data || 'Failed to communicate with Gemini API' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Bachat AI Proxy Backend running on port ${PORT}`);
});
