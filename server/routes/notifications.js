const express = require('express');
const router = express.Router();
const User = require('../models/user'); 

router.get('/notifications/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'user not found' });
    }

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
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'user not found' });
    }

    const notificationIndex = user.notifications.findIndex(
      (notification) => notification._id.equals(notificationId)
    );

    if (notificationIndex === -1) {
      return res.status(404).json({ message: 'notification not found' });
    }

    user.notifications.splice(notificationIndex, 1);

    await user.save();

    res.status(200).json({ message: 'notification deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

module.exports = router;
