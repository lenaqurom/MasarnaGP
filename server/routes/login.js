const express = require('express');
const router = express.Router();
const User = require('../models/user');


router.post('/login', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    if (!username && !email) {
      return res.status(400).json({ error: 'username or email is required' });
    }

    const user = await User.findOne({ $or: [{ username }, { email }] });

    if (!user) {
      return res.status(401).json({ error: 'invalid username or email or password' });
    }

    if (user.password !== password) {
      return res.status(401).json({ error: 'invalid username or email or password' });
    }

    res.status(200).json({ message: 'Login successful', user });
    
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
