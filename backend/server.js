const express = require('express');
const cors = require('cors'); // To enable CORS (Cross-Origin Resource Sharing) if needed

const app = express();
const port = 5000; // Set the port for your backend server

// Middleware
app.use(express.json()); // To parse JSON body in requests
app.use(cors()); // Enable cross-origin requests if needed (for dev only)

// Define the /api/message route
app.post('/api/message', (req, res) => {
      const { text } = req.body;

      // Simulate processing the request and send a response
      res.json({
            message: `Received message: ${text}`,
      });
});

// Start the server
app.listen(port, '0.0.0.0', () => {
      console.log(`Backend server running at http://0.0.0.0:${port}`);
});

