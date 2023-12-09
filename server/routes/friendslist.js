const express = require('express');
const router = express.Router();


const Friendslist = require('../models/friendslist');
const User = require('../models/user');

router.get('/friendslist/:userid', async (req, res) => {
  const userId = req.params.userid;

  try {
    // Find the friends list by user ID
    const friendsList = await Friendslist.findOne({ userid: userId });

    if (!friendsList) {
      return res.status(404).json({ message: 'Friends list not found' });
    }

    // Extract friend IDs from the friends list
    const friendIds = friendsList.friendid;

    // Fetch user details for each friend
    const friendDetails = await User.find({ _id: { $in: friendIds } }, 'username profilepicture');

    res.json(friendDetails);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'An error occurred while fetching friends.' });
  }
});

module.exports = router;

