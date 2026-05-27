const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
// Increase JSON payload limit to handle multiple base64 images
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Initialize Google Generative AI
const getGenAIInstance = (apiKey) => {
  const key = apiKey || process.env.GEMINI_API_KEY;
  if (!key) {
    throw new Error('API Key is missing. Please set GEMINI_API_KEY environment variable.');
  }
  return new GoogleGenerativeAI(key);
};

// Convert base64 string to Gemini Part object
function base64ToGenerativePart(base64Str, mimeType = 'image/jpeg') {
  return {
    inlineData: {
      data: base64Str,
      mimeType
    },
  };
}

// Health Check Endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    apiConfigured: !!process.env.GEMINI_API_KEY
  });
});

// 1. Analyze Vehicle Images Endpoint
app.post('/api/analyze', async (req, res) => {
  try {
    const { images, prompt, customApiKey } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: 'Prompt is required.' });
    }
    if (!images || !Array.isArray(images) || images.length === 0) {
      return res.status(400).json({ error: 'At least one base64 image is required.' });
    }

    const genAI = getGenAIInstance(customApiKey);
    const imageParts = images.map(img => base64ToGenerativePart(img));
    
    let textResult = '';
    let attemptError = null;

    // Attempt 1: Gemini 2.5 Flash
    try {
      console.log('Attempting vehicle analysis using gemini-2.5-flash...');
      const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
      const result = await model.generateContent([prompt, ...imageParts]);
      const response = await result.response;
      textResult = response.text();
    } catch (e) {
      console.warn('gemini-2.5-flash failed, falling back to gemini-1.5-flash. Error:', e.message);
      attemptError = e;

      // Fallback: Gemini 1.5 Flash (higher RPM/RPD limits)
      try {
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        const result = await model.generateContent([prompt, ...imageParts]);
        const response = await result.response;
        textResult = response.text();
      } catch (fallbackError) {
        console.error('All models failed. Fallback error:', fallbackError.message);
        throw new Error(`Failed to generate content: ${fallbackError.message} (Original: ${attemptError.message})`);
      }
    }

    res.json({ result: textResult });
  } catch (error) {
    console.error('Analysis error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// 2. Chat Assistant Endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const { prompt, customApiKey } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: 'Prompt is required.' });
    }

    const genAI = getGenAIInstance(customApiKey);
    let textResult = '';
    let attemptError = null;

    // Attempt 1: Gemini 2.5 Flash
    try {
      console.log('Attempting chat assistant response using gemini-2.5-flash...');
      const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
      const result = await model.generateContent([prompt]);
      const response = await result.response;
      textResult = response.text();
    } catch (e) {
      console.warn('gemini-2.5-flash chat failed, falling back to gemini-1.5-flash. Error:', e.message);
      attemptError = e;

      // Fallback: Gemini 1.5 Flash
      try {
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        const result = await model.generateContent([prompt]);
        const response = await result.response;
        textResult = response.text();
      } catch (fallbackError) {
        console.error('All models failed for chat. Fallback error:', fallbackError.message);
        throw new Error(`Failed to generate chat content: ${fallbackError.message} (Original: ${attemptError.message})`);
      }
    }

    res.json({ result: textResult });
  } catch (error) {
    console.error('Chat error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// Start Server
app.listen(port, () => {
  console.log(`Gemini Proxy Server is running on port ${port}`);
});
