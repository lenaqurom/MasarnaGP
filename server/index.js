const express = require('express');
const app = express();
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const loginRoutes = require('./routes/login');
const signupRoutes = require('./routes/signup');
app.use(bodyParser.json());

// MongoDB Atlas connection
mongoose.connect('mongodb+srv://danalena:123@cluster0.hxhvhfi.mongodb.net/', {
  
  useNewUrlParser: true,
  useUnifiedTopology: true,
  ssl: true, // Enable SSL

});

// Include your authentication routes
app.use('/api', signupRoutes);
app.use('/api', loginRoutes);

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
