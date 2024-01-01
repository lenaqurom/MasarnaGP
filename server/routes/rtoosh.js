const express = require('express');
const router = express.Router();
const User = require('../models/user');
const Rating = require('../models/rating');
const { Flight, Stay, Eatery, Activity } = require('../models/externalapi');

router.post('/faveatery/:id', async (req, res) => {
    const eateryId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const eatery = await Eatery.findById(eateryId);
  
      // If the Eatery is not found, return a 404 status
      if (!eatery) {
        return res.status(404).json({ error: 'Eatery not found' });
      }
  
      // Increment the favs property by one
      eatery.favs += 1;
  
      // Save the updated Eatery
      await eatery.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(eatery);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reporteatery/:id', async (req, res) => {
    const eateryId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const eatery = await Eatery.findById(eateryId);
  
      // If the Eatery is not found, return a 404 status
      if (!eatery) {
        return res.status(404).json({ error: 'Eatery not found' });
      }
  
      // Increment the favs property by one
      eatery.reports += 1;
  
      // Save the updated Eatery
      await eatery.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(eatery);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  

  router.post('/favstay/:id', async (req, res) => {
    const stayId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const stay = await Stay.findById(stayId);
  
      // If the Eatery is not found, return a 404 status
      if (!stay) {
        return res.status(404).json({ error: 'Stay not found' });
      }
  
      // Increment the favs property by one
      stay.favs += 1;
  
      // Save the updated Eatery
      await stay.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(stay);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportstay/:id', async (req, res) => {
    const stayId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const stay = await Stay.findById(stayId);
  
      // If the Eatery is not found, return a 404 status
      if (!stay) {
        return res.status(404).json({ error: 'Stay not found' });
      }
  
      // Increment the favs property by one
      stay.reports += 1;
  
      // Save the updated Eatery
      await stay.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(stay);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/favflight/:id', async (req, res) => {
    const flightId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const flight = await Flight.findById(flightId);
  
      // If the Eatery is not found, return a 404 status
      if (!flight) {
        return res.status(404).json({ error: 'Flight not found' });
      }
  
      // Increment the favs property by one
      flight.favs += 1;
  
      // Save the updated Eatery
      await flight.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(flight);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportflight/:id', async (req, res) => {
    const flightId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const flight = await Flight.findById(flightId);
  
      // If the Eatery is not found, return a 404 status
      if (!flight) {
        return res.status(404).json({ error: 'Flight not found' });
      }
  
      // Increment the favs property by one
      flight.reports += 1;
  
      // Save the updated Eatery
      await flight.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(flight);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/favactivity/:id', async (req, res) => {
    const activityId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const activity = await Activity.findById(activityId);
  
      // If the Eatery is not found, return a 404 status
      if (!activity) {
        return res.status(404).json({ error: 'Activity not found' });
      }
  
      // Increment the favs property by one
      activity.favs += 1;
  
      // Save the updated Eatery
      await activity.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(activity);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportactivity/:id', async (req, res) => {
    const activityId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const activity = await Activity.findById(activityId);
  
      // If the Eatery is not found, return a 404 status
      if (!activity) {
        return res.status(404).json({ error: 'Activity not found' });
      }
  
      // Increment the favs property by one
      activity.reports += 1;
  
      // Save the updated Eatery
      await activity.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(activity);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.post('/reportuser/:id', async (req, res) => {
    const userId = req.params.id;
  
    try {
      // Find the Eatery by ID
      const user = await User.findById(userId);
  
      // If the Eatery is not found, return a 404 status
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
  
      // Increment the favs property by one
      user.reports += 1;
  
      // Save the updated Eatery
      await user.save();
  
      // Return the updated Eatery with the incremented favs
      res.json(user);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

 router.post('/rate', async (req, res) => {
    const { userId, stars, comment } = req.body;
  
    try {
      // Create a new Rating instance
      const newRating = new Rating({
        user: userId,
        stars,
        comment,
      });
  
      // Save the Rating to the database
      await newRating.save();
  
      // Return the new Rating
      res.json(newRating);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.get('/ratings', async (req, res) => {
    try {
      // Fetch all ratings from the database
      const ratings = await Rating.find();
  
      // Return the fetched ratings in the response
      res.json(ratings);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.get('/users', async (req, res) => {
    try {
      // Fetch all ratings from the database
      const users = await User.find();
  
      // Return the fetched ratings in the response
      res.json(users);
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/user/:id', async (req, res) => {
    const userId = req.params.id;
  
    try {
      // Find the user by ID and delete it
      const deletedUser = await User.findByIdAndDelete(userId);
  
      // If the user is not found, return a 404 status
      if (!deletedUser) {
        return res.status(404).json({ error: 'User not found' });
      }
  
      // Return the deleted user in the response
      res.json({ message: 'User deleted successfully', deletedUser });
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/flight/:id', async (req, res) => {
    const flightId = req.params.id;
  
    try {
      // Find the user by ID and delete it
      const deletedFlight = await Flight.findByIdAndDelete(flightId);
  
      // If the user is not found, return a 404 status
      if (!deletedFlight) {
        return res.status(404).json({ error: 'Flight not found' });
      }
  
      // Return the deleted user in the response
      res.json({ message: 'Flight deleted successfully', deletedFlight });
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/eatery/:id', async (req, res) => {
    const eateryId = req.params.id;
  
    try {
      // Find the user by ID and delete it
      const deletedEatery = await Eatery.findByIdAndDelete(eateryId);
  
      // If the user is not found, return a 404 status
      if (!deletedEatery) {
        return res.status(404).json({ error: 'Eatery not found' });
      }
  
      // Return the deleted user in the response
      res.json({ message: 'Eatery deleted successfully', deletedEatery });
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  
  router.delete('/stay/:id', async (req, res) => {
    const stayId = req.params.id;
  
    try {
      // Find the user by ID and delete it
      const deletedStay = await Stay.findByIdAndDelete(stayId);
  
      // If the user is not found, return a 404 status
      if (!deletedStay) {
        return res.status(404).json({ error: 'Stay not found' });
      }
  
      // Return the deleted user in the response
      res.json({ message: 'Stay deleted successfully', deletedStay });
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  router.delete('/activity/:id', async (req, res) => {
    const activityId = req.params.id;
  
    try {
      // Find the user by ID and delete it
      const deletedActivity = await Activity.findByIdAndDelete(activityId);
  
      // If the user is not found, return a 404 status
      if (!deletedActivity) {
        return res.status(404).json({ error: 'Activity not found' });
      }
  
      // Return the deleted user in the response
      res.json({ message: 'Activity deleted successfully', deletedActivity });
    } catch (error) {
      // Handle errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

  module.exports = router;
