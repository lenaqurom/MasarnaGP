const express = require('express');
const router = express.Router();
const User = require('../models/user'); 

// Define the route to get notifications for a user
router.get('/notifications/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    // Find the user by ID
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Retrieve the user's notifications
    const notifications = user.notifications;

    res.status(200).json({ notifications });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.delete('/notifications/:userId/:notificationId', async (req, res) => {
  const { userId, notificationId } = req.params;

  try {
    // Find the user by ID
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Find the notification by ID in the user's notifications array
    const notificationIndex = user.notifications.findIndex(
      (notification) => notification._id.equals(notificationId)
    );

    if (notificationIndex === -1) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    // Remove the notification from the user's notifications array
    user.notifications.splice(notificationIndex, 1);

    // Save the updated user
    await user.save();

    res.status(200).json({ message: 'Notification deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

module.exports = router;
