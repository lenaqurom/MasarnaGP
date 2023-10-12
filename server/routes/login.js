const express = require('express');
const router = express.Router();
const User = require('../models/user');

// Route for user login
router.post('/login', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validation: Check if either username or email is provided
    if (!username && !email) {
      return res.status(400).json({ error: 'Username or email is required' });
    }

    // Find the user in the database using username or email
    const user = await User.findOne({ $or: [{ username }, { email }] });

    // Check if the user exists
    if (!user) {
      return res.status(401).json({ error: 'Invalid username or email or password' });
    }

    // Check the password (You should use a password hashing library like bcrypt)
    if (user.password !== password) {
      return res.status(401).json({ error: 'Invalid username or email or password' });
    }

    // Respond with a success message or user information
    res.status(200).json({ message: 'Login successful', user });
  } catch (error) {
    // Handle any errors, such as database errors
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
