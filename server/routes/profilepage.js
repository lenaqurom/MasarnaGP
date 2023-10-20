const express = require('express');
const router = express.Router();
const User = require('../models/user');

// Route for the user's profile page
router.get('/profilepage', async (req, res) => {
  const { email, username } = req.query; // Extract email or username from the request

  try {
    const user = await User.findOne({ $or: [{ email }, { username }] });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Return with profile data
    res.render('profile', { user });
  } catch (error) {
    // db error
    res.status(500).json({ error: 'Server error' });
  }
});

// Route to update user's profile information
router.post('/profilepage', async (req, res) => {
  const { email, username, name, profilepicture } = req.body;

  try {
    // Update user information in the database
    const user = await User.findOne({ $or: [{ email }, { username }] });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.name = name;
    user.profilepicture = profilepicture;

    await user.save();

    res.status(200).json({ message: 'Profile updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;