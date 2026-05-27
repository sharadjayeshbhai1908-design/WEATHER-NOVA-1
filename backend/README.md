# Gemini Proxy Backend Server

This is a Node.js Express server that acts as a secure API gateway/proxy for Google Gemini. It keeps your API Key safe and prevents it from being exposed in your Flutter mobile application code.

## Local Setup

1. Make sure you have [Node.js](https://nodejs.org/) installed.
2. Open your terminal and navigate to the `backend` folder:
   ```bash
   cd backend
   ```
3. Install the dependencies:
   ```bash
   npm install
   ```
4. Create a `.env` file (copied from `.env` template) and set your API key:
   ```env
   PORT=3000
   GEMINI_API_KEY=your_actual_gemini_api_key
   ```
5. Start the server:
   ```bash
   npm start
   ```
   The server will start running on `http://localhost:3000`. You can test it by opening `http://localhost:3000/health` in your browser.

---

## Free Cloud Deployment Guides

### Option A: Hosting on Render.com (Recommended for Node.js)

1. Create a free account on [Render.com](https://render.com/).
2. Push your code to a Git Repository (GitHub or GitLab). Make sure the `backend` folder is part of your repository or create a separate repository for the backend.
3. On the Render Dashboard, click **New +** and select **Web Service**.
4. Connect your GitHub/GitLab repository.
5. Configure the service settings:
   - **Name**: `gemini-vehicle-scanner-api` (or any name you like)
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
6. Scroll down, click **Advanced**, and click **Add Environment Variable**:
   - Key: `GEMINI_API_KEY`
   - Value: *Paste your Google Gemini API Key*
7. Click **Create Web Service**.
8. Once deployed, Render will provide you with a public URL (e.g., `https://gemini-vehicle-scanner-api.onrender.com`). Use this URL as the base URL in your Flutter app!

### Option B: Hosting on Vercel

To deploy on Vercel, you will need a `vercel.json` file in the root of the server directory. 
Vercel is primarily serverless, so Render is usually simpler for Express apps, but Vercel is extremely fast.

---

## How to Test Endpoints

- **Health Check:** `GET /health`
- **Vehicle Scan:** `POST /api/analyze`
  - Body:
    ```json
    {
      "prompt": "automotive analysis prompt...",
      "images": ["base64_encoded_string_1", "base64_encoded_string_2"]
    }
    ```
- **Chat Assistant:** `POST /api/chat`
  - Body:
    ```json
    {
      "prompt": "chat message..."
    }
    ```
