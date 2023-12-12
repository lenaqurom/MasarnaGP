const express = require('express');
const router = express.Router();
const User = require('../models/user');
const FriendsList = require('../models/friendslist');

// Route for user signup


router.post('/signup', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validation: Check if the username, email, or password are null or empty
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Username, email, and password are required' });
    }

    // Validation: Check if the username contains 'admin'
    if (username.toLowerCase().includes('admin')) {
      return res.status(400).json({ error: 'Username cannot contain the word "admin"' });
    }

    // Validation: Check if the username or email already exists
    const existingUser = await User.findOne({ $or: [{ username }, { email }] });
    if (existingUser) {
      return res.status(400).json({ error: 'Username or email already in use' });
    }

    // Create a new user in the database
    const newUser = new User({
      username,
      email,
      password,
      name: '', // Set to an empty string by default
      profilepicture: '', // Set to an empty string by default
    });
    await newUser.save();

    const usersfl = new FriendsList({
      userid: newUser._id,
      friendid: [],
    });
    await usersfl.save();

    // Respond with a success message or user information
    res.status(201).json({ message: 'User registered successfully', user: newUser, list: usersfl });
  } catch (error) {
    // Handle any errors, such as database errors
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
