const express = require('express');
const app = express();
const port = 3000;

let count = 0;

app.get('/', (req, res) => {
  res.send('Lab 4 - Express App on Lightsail');
});

app.get('/visitor_count', (req, res) => {
  count++;
  res.send(`You are visitor number: ${count}`);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
