const express = require('express');
const router = express.Router();


const Friendslist = require('../models/friendslist');

// Define the route to get a user's friends
router.get('/friendslist/:username', async (req, res) => {
  const username = req.params.username;

  
  try {
    const friendslist = await Friendslist.find({ userName: username });
    res.json(friendslist);
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while fetching friends.' });
  }
});

module.exports = router;
