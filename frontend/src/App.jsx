import React, { useState } from 'react';
import './App.css';  // Import the CSS

const App = () => {
  const [message, setMessage] = useState(null);

  const handleButtonClick = async () => {
    try {
      const response = await fetch('/api/message', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ text: 'Hello from frontend' }),
      });

      if (!response.ok) {
        throw new Error('Failed to send request');
      }

      const result = await response.json();
      setMessage(result.message);
    } catch (error) {
      console.error('Error:', error);
      setMessage('Error sending request');
    }
  };

  return (
    <div>
      <h1>Send Request to Backend</h1>
      <button onClick={handleButtonClick}>Send Request</button>
      {message && <p>Response: {message}</p>}
    </div>
  );
};

export default App;
