const express = require('express');
const router = express.Router();
const User = require('../models/user');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' }); 
const path = require('path');


// Route for the user's profile page
router.get('/profilepage', async (req, res) => {
  const { email, username } = req.query; // Extract email or username from the request

  try {
    const user = await User.findOne({ $or: [{ email }, { username }] });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json({ user });
  } catch (error) {
    // db error
    console.error(error); // Log the error to the console for debugging
    res.status(500).json({ error: 'Server error' });
  }
});

// Route to update user's profile information
router.post('/profilepage', upload.single('profilepicture'), async (req, res) => {
  const { email, username, name } = req.body;

  try {
    // Update user information in the database
    const user = await User.findOne({ $or: [{ email }, { username }] });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.name = name;

    if (req.file) {
      const imagePath = req.file.path.replace(/\\/g, '/');
  user.profilepicture = path.join('uploads', path.basename(imagePath));
    }

    await user.save();

    res.status(200).json({ message: 'Profile updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;