const express = require('express');
const router = express.Router();
const User = require('../models/user');
const FriendsList = require('../models/friendslist');



router.post('/signup', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ error: 'username, email, and password are required' });
    }
    if (username.toLowerCase().includes('admin')) {
      return res.status(400).json({ error: 'username cannot contain the word "admin"' });
    }

    if (password.length<6) {
      return res.status(400).json({ error: 'password must be at least 6 characters' });
    }

    const existingUser = await User.findOne({ $or: [{ username }, { email }] });
    if (existingUser) {
      return res.status(400).json({ error: 'username or email already in use' });
    }

    const newUser = new User({
      username,
      email,
      password,
      name: '', 
      profilepicture: '', 
    });
    await newUser.save();

    const usersfl = new FriendsList({
      userid: newUser._id,
      friendid: [],
    });
    await usersfl.save();

    res.status(201).json({ message: 'user registered successfully', user: newUser, list: usersfl });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
