const express = require('express');
const router = express.Router();
const User = require('../models/user');
const FriendsList = require('../models/friendslist');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' }); 
const path = require('path');


router.get('/profilepage', async (req, res) => {
  const { email, username } = req.query; 

  try {
    const user = await User.findOne({ $or: [{ email }, { username }] });

    if (!user) {
      return res.status(404).json({ error: 'user not found' });
    }
    res.status(200).json({ user });
  } catch (error) {
    console.error(error); 
    res.status(500).json({ error: 'Server error' });
  }
});

router.post('/profilepage', upload.single('profilepicture'), async (req, res) => {
  const { email, username, name } = req.body;

  try {
    const user = await User.findOne({ $or: [{ email }, { username }] });

    if (!user) {
      return res.status(404).json({ error: 'user not found' });
    }

    user.name = name;

    if (req.file) {
      const imagePath = req.file.path.replace(/\\/g, '/');
  user.profilepicture = path.join('uploads', path.basename(imagePath));
    }

    await user.save();

    res.status(200).json({ message: 'profile updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

router.get('/profileview/:userId/:myuserid', async (req, res) => {
  try {
    const userId = req.params.userId;
    const loggedInUserId = req.params.myuserid;

    const friendsList = await FriendsList.findOne({ userid: loggedInUserId });
    const isFriend = friendsList && friendsList.friendid.includes(userId);

    const requestedUser = await User.findById(userId);
    const requestedthem = requestedUser && requestedUser.requests.some(request => request.user.equals(loggedInUserId));

    const me = await User.findById(loggedInUserId);
    const requestedme = me && me.requests.some(request => request.user.equals(userId));

    const user = await User.findById(userId);

    const userProfile = {
      username: user.username,
      email: user.email,
      profilepicture: user.profilepicture,
      name: user.name,
      isFriend,
      requestedthem,
      requestedme,
    };

    res.json(userProfile);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.post('/unfriend', async (req, res) => {
  const { userId, friendId } = req.body;

  try {
    await FriendsList.updateOne(
      { userid: userId },
      { $pull: { friendid: friendId } }
    );

    await FriendsList.updateOne(
      { userid: friendId },
      { $pull: { friendid: userId } }
    );

    res.status(200).json({ message: 'unfriended successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.post('/request', async (req, res) => {
  try {
    const { userId, recipientId } = req.body;

    const recipient = await User.findById(recipientId);
    const sender = await User.findById(userId);

    if (!recipient || !sender) {
      return res.status(404).json({ error: 'user not found' });
    }

    const existingRequest = recipient.requests.find(request => request.user.equals(sender._id));

    if (existingRequest) {
      return res.status(400).json({ error: 'friend request already sent' });
    }

    recipient.requests.push({ user: sender._id });
    await recipient.save();

    const notification = {
      title: `${sender.username}`,
      text: `sent you a friend request`,
      type: 'newss', 
      image: `${sender.profilepicture}`,
     // from: `${sender._id}`,
  };
  recipient.notifications.push(notification);
        await recipient.save();

    res.status(200).json({ message: 'friend request sent successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/unrequest', async (req, res) => {
  try {
    const { userId, recipientId } = req.body;

    const recipient = await User.findById(recipientId);
    const sender = await User.findById(userId);

    if (!recipient || !sender) {
      return res.status(404).json({ error: 'user not found' });
    }

    recipient.requests = recipient.requests.filter(request => !request.user.equals(sender._id));
    await recipient.save();


    res.status(200).json({ message: 'friend request cancelled successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/friend', async (req, res) => {
  try {
    const { userId, senderId } = req.body;

    const sender = await User.findById(senderId);
    const receiver = await User.findById(userId);

    if (!sender || !receiver) {
      return res.status(404).json({ error: 'user not found' });
    }

    const existingRequest = receiver.requests.find(request => request.user.equals(sender._id));

    if (!existingRequest) {
      return res.status(400).json({ error: 'no friend request found from this user' });
    }

     const senderFriendsList = await FriendsList.findOne({ userid: sender._id });
     const receiverFriendsList = await FriendsList.findOne({ userid: receiver._id });
 
     senderFriendsList.friendid.push(receiver._id);
     receiverFriendsList.friendid.push(sender._id);
 
     await senderFriendsList.save();
     await receiverFriendsList.save();

    receiver.requests = receiver.requests.filter(request => !request.user.equals(sender._id));
    await receiver.save();

    const notification = {
      title: `${receiver.username}`,
      text: `accepted your friend request`,
      type: 'newss', 
      image: `${receiver.profilepicture}`,
  };
  sender.notifications.push(notification);
        await sender.save();

    res.status(200).json({ message: 'friend request accepted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/deleterequest/:param', async (req, res) => {
  try {
    const { param } = req.params;
    const { userId, requestId, senderId } = req.body;

    // Check if the receiver exists
    const receiver = await User.findById(userId);

    if (!receiver) {
      return res.status(404).json({ error: 'user not found' });
    }

    if (requestId) {
      receiver.requests = receiver.requests.filter(request => !request._id.equals(requestId));
    } else if (param === 'senderId') {
      receiver.requests = receiver.requests.filter(request => !request.user.equals(senderId));
    } else {
      return res.status(400).json({ error: 'Invalid parameters' });
    }

    await receiver.save();

    res.status(200).json({ message: 'friend request deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/requests/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'user not found' });
    }

    const friendRequests = user.requests;

   const friendRequestsInfo = await Promise.all(friendRequests.map(async (request) => {
    const sender = await User.findById(request.user);
    return {
      requestId: request._id,
      _id: sender._id,
      username: sender.username,
      profilepicture: sender.profilepicture,
    };
  }));

  res.status(200).json(friendRequestsInfo);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


module.exports = router;