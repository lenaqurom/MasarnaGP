const express = require('express');
const router = express.Router();
const User = require('../models/user');
const Rating = require('../models/rating');
const { Flight, Stay, Eatery, Activity } = require('../models/externalapi');

router.post('/faveatery/:id', async (req, res) => {
    const eateryId = req.params.id;
  
    try {
      const eatery = await Eatery.findById(eateryId);
  
      if (!eatery) {
        return res.status(404).json({ error: 'eatery not found' });
      }
  
      eatery.favs += 1;
  
      await eatery.save();
  
      res.json(eatery);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/unfaveatery/:id', async (req, res) => {
    const eateryId = req.params.id;
  
    try {
      const eatery = await Eatery.findById(eateryId);
  
      if (!eatery) {
        return res.status(404).json({ error: 'eatery not found' });
      }
  
      eatery.favs -= 1;
  
      await eatery.save();
  
      res.json(eatery);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reporteatery/:id', async (req, res) => {
    const eateryId = req.params.id;
  
    try {
      const eatery = await Eatery.findById(eateryId);
  
      if (!eatery) {
        return res.status(404).json({ error: 'eatery not found' });
      }
  
      eatery.reports += 1;
  
      await eatery.save();

       
       const notification = {
        title: `${eatery.name}`,
        text: `suggestion was reported`,
        type: 'sug', 
        image: `${eatery.image}`,
    };

    const adminId = '65941707201100b4af08d8ea'; 
    const admin = await User.findById(adminId);
    if (admin) {
        admin.notifications.push(notification);
        await admin.save();
    }
  
      
      res.json(eatery);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  

  router.post('/favstay/:id', async (req, res) => {
    const stayId = req.params.id;
  
    try {
      const stay = await Stay.findById(stayId);
  
      if (!stay) {
        return res.status(404).json({ error: 'stay not found' });
      }
  
      stay.favs += 1;
  
      await stay.save();
  
      res.json(stay);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/unfavstay/:id', async (req, res) => {
    const stayId = req.params.id;
  
    try {
      const stay = await Stay.findById(stayId);
  
      if (!stay) {
        return res.status(404).json({ error: 'stay not found' });
      }
  
      stay.favs -= 1;
  
      await stay.save();
  
      res.json(stay);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportstay/:id', async (req, res) => {
    const stayId = req.params.id;
  
    try {
      const stay = await Stay.findById(stayId);
  
      if (!stay) {
        return res.status(404).json({ error: 'stay not found' });
      }
  
      stay.reports += 1;
  
      await stay.save();

      const notification = {
        title: `${stay.name}`,
        text: `suggestion was reported`,
        type: 'sug', 
        image: `${stay.image}`,
    };

    const adminId = '65941707201100b4af08d8ea'; 
    const admin = await User.findById(adminId);
    if (admin) {
        admin.notifications.push(notification);
        await admin.save();
    }
  
      res.json(stay);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/favflight/:id', async (req, res) => {
    const flightId = req.params.id;
  
    try {
      const flight = await Flight.findById(flightId);
  
      if (!flight) {
        return res.status(404).json({ error: 'flight not found' });
      }
  
      flight.favs += 1;
  
      await flight.save();
  
      res.json(flight);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/unfavflight/:id', async (req, res) => {
    const flightId = req.params.id;
  
    try {
      const flight = await Flight.findById(flightId);
  
      if (!flight) {
        return res.status(404).json({ error: 'flight not found' });
      }
  
      flight.favs -= 1;
  
      await flight.save();
  
      res.json(flight);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportflight/:id', async (req, res) => {
    const flightId = req.params.id;
  
    try {
      const flight = await Flight.findById(flightId);
  
      if (!flight) {
        return res.status(404).json({ error: 'flight not found' });
      }
  
      flight.reports += 1;
  
      await flight.save();

      const notification = {
        title: `${flight.airline}`,
        image: `${flight.image}`,
        text: `suggestion was reported`,
        type: 'sug', 
    };

    const adminId = '65941707201100b4af08d8ea'; 
    const admin = await User.findById(adminId);
    if (admin) {
        admin.notifications.push(notification);
        await admin.save();
    }
  
      res.json(flight);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/favactivity/:id', async (req, res) => {
    const activityId = req.params.id;
  
    try {
      const activity = await Activity.findById(activityId);
  
      if (!activity) {
        return res.status(404).json({ error: 'activity not found' });
      }
  
      activity.favs += 1;
        await activity.save();
  
      res.json(activity);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/unfavactivity/:id', async (req, res) => {
    const activityId = req.params.id;
  
    try {
      const activity = await Activity.findById(activityId);
  
      if (!activity) {
        return res.status(404).json({ error: 'activity not found' });
      }
  
      activity.favs -= 1;
        await activity.save();
  
      res.json(activity);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportactivity/:id', async (req, res) => {
    const activityId = req.params.id;
  
    try {
      const activity = await Activity.findById(activityId);
  
      if (!activity) {
        return res.status(404).json({ error: 'activity not found' });
      }
  
      activity.reports += 1;
        await activity.save();
      console.log(activity);

      const notification = {
        title: `${activity.name}`,
        text: `suggestion was reported`,
        type: 'sug', 
        image: `${activity.image}`,
    };
    console.log(notification);
    const adminId = '65941707201100b4af08d8ea'; 
    const admin = await User.findById(adminId);
    if (admin) {
        admin.notifications.push(notification);
        await admin.save();
    }
  
      res.json(activity);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportuser/:id', async (req, res) => {
    const userId = req.params.id;
  
    try {
      const user = await User.findById(userId);
  
      if (!user) {
        return res.status(404).json({ error: 'user not found' });
      }
  
      user.reports += 1;
        await user.save();

      const notification = {
        title: `${user.username}`,
        text: `was reported`,
        type: 'user', 
        image: `${user.profilepicture}`,
    };

    const adminId = '65941707201100b4af08d8ea'; 
    const admin = await User.findById(adminId);
    if (admin) {
        admin.notifications.push(notification);
        await admin.save();
    }
  
      res.json(user);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

 router.post('/rate', async (req, res) => {
    const { userId, stars, comment } = req.body;
  
    try {
      const newRating = new Rating({
        user: userId,
        stars,
        comment,
      });
  
      await newRating.save();

      const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({ error: 'user not found' });
        }

        const notification = {
            title: `${user.username}`,
            text: `submitted a new rating`,
            type: 'rating',
            image: `${user.profilepicture}`,
        };

        const adminId = '65941707201100b4af08d8ea';
        const admin = await User.findById(adminId);

        if (admin) {
            admin.notifications.push(notification);
            await admin.save();
        }
  
      res.json(newRating);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.get('/ratings', async (req, res) => {
    try {
        const ratings = await Rating.find().populate('user', 'username profilepicture');

        res.json(ratings);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

  router.get('/users', async (req, res) => {
    try {
      const users = await User.find();
  
      res.json(users);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/user/:id', async (req, res) => {
    const userId = req.params.id;
  
    try {
      const deletedUser = await User.findByIdAndDelete(userId);
  
      if (!deletedUser) {
        return res.status(404).json({ error: 'user not found' });
      }
  
      res.json({ message: 'user deleted successfully', deletedUser });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/flights/:id', async (req, res) => {
    const flightId = req.params.id;
  
    try {
      const deletedFlight = await Flight.findByIdAndDelete(flightId);
  
      if (!deletedFlight) {
        return res.status(404).json({ error: 'flight not found' });
      }
  
      res.json({ message: 'flight deleted successfully', deletedFlight });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/eateries/:id', async (req, res) => {
    const eateryId = req.params.id;
  
    try {
      const deletedEatery = await Eatery.findByIdAndDelete(eateryId);
  
      if (!deletedEatery) {
        return res.status(404).json({ error: 'eatery not found' });
      }
  
      res.json({ message: 'eatery deleted successfully', deletedEatery });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  
  router.delete('/stays/:id', async (req, res) => {
    const stayId = req.params.id;
  
    try {
      const deletedStay = await Stay.findByIdAndDelete(stayId);
  
      if (!deletedStay) {
        return res.status(404).json({ error: 'stay not found' });
      }
  
      res.json({ message: 'stay deleted successfully', deletedStay });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/activities/:id', async (req, res) => {
    const activityId = req.params.id;
  
    try {
      const deletedActivity = await Activity.findByIdAndDelete(activityId);
  
      if (!deletedActivity) {
        return res.status(404).json({ error: 'activity not found' });
      }
  
      res.json({ message: 'activity deleted successfully', deletedActivity });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  module.exports = router;
