const express = require('express');
const router = express.Router();
const Plan = require('../models/plan'); // Update the path based on your file structure
const User = require('../models/user'); // Update the path based on your file structure
const mongoose = require('mongoose');

// create personal plan 
router.post('/:planId/personalplan/:userId', async (req, res) => {
    try {
      const {name, date, price, starttime, endtime} = req.body;
      const { longitude, latitude } = req.body.location;
      const { userId, planId} = req.params;
  
      if (!userId || !planId || !date) {
        return res.status(400).json({ error: 'missing required fields' });
      }
  
      // Check if the user and plan exist
      const userExists = await User.findById(userId);
      const planExists = await Plan.findById(planId);
  
      if (!userExists || !planExists) {
        return res.status(404).json({ error: 'User or plan not found' });
      }
      
    const parsedStartTime = new Date(`${date}T${starttime}:00.000Z`);
    const parsedEndTime = new Date(`${date}T${endtime}:00.000Z`);
    
console.log('Received Time Strings:', starttime, endtime, date);


console.log('Parsed Start Time:', parsedStartTime);
console.log('Parsed End Time:', parsedEndTime);

    // Find the user's calendar in the plan's calendars array
let userCalendar = planExists.calendars.find((calendar) => calendar.user.equals(userId));

if (!userCalendar) {
  // If the user's calendar doesn't exist, create it
  userCalendar = {
    user: userId,
    calendarevents: [],
  };
  planExists.calendars.push(userCalendar);
}


    // Create a new personal calendar event
    const newEvent = {
      type: 'personal',
      sectionname: '',
      user: userId,
      name: name,
      date: new Date(date),
      price: price || null,
      location: [longitude, latitude], 
      starttime: parsedStartTime,
      endtime: parsedEndTime,
    };

    // Add the new event to the user's calendar
    userCalendar.calendarevents.push(newEvent);

    // Save the updated plan
    await planExists.save();
    console.log('User Calendar:', userCalendar);
    console.log('Updated Plan:', planExists);

    res.status(201).json({ message: 'New personal plan added successfully', plan: planExists });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

  
//add a new groupday event is in the groupdayplans.js 

//get all of the user's calendar events (shared and personal)

router.get('/:planId/:userId/calendarevents', async (req, res) => {
  try {
    const { planId, userId } = req.params;
    const existingPlan = await Plan.findById(planId);

    if (!existingPlan) {
      return res.status(404).json({ error: 'Plan not found' });
    }

    // Find the user's calendar within the calendarevents array
    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'User calendar not found' });
    }

    const userCalendarevents = userCalendar.calendarevents;

    const groupDayPlans = existingPlan.groupdayplans.map((groupDayPlan) => ({
      id: groupDayPlan._id,
      date: groupDayPlan.date,
    }));

    res.status(200).json({ calendarevents: userCalendarevents , groupDayPlans: groupDayPlans  });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});


// get user's schedule
router.get('/:planId/:userId/calendarevents/:date', async (req, res) => {
  try {
    const { planId, userId, date } = req.params;

    const targetDate = new Date(date);

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      return res.status(404).json({ error: 'Plan not found' });
    }

    // Find the user's calendar within the calendarevents array
    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'User calendar not found' });
    }

    // Filter events for the specific date from the user's calendar
    const eventsForDate = userCalendar.calendarevents.filter(event =>
      event.date.toISOString().split('T')[0] === targetDate.toISOString().split('T')[0]
    );

      // Find group day plans on the specific date
    const groupDayPlansForDate = existingPlan.groupdayplans.filter((groupDayPlan) =>
    groupDayPlan.date.toISOString().split('T')[0] === targetDate.toISOString().split('T')[0]
  );

    res.status(200).json({ events: eventsForDate , groupDayPlans: groupDayPlansForDate });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});


//delete personal event off calendar 
router.delete('/:planId/:userId/calendarevents/:eventId', async (req, res) => {
  try {
    const { planId, userId, eventId } = req.params;

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      return res.status(404).json({ error: 'Plan not found' });
    }

    // Find the user's calendar within the calendarevents array
    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'User calendar not found' });
    }

    // Find the event to delete in the user's calendar
    const targetEventIndex = userCalendar.calendarevents.findIndex(event => event._id.toString() === eventId);

    if (targetEventIndex === -1) {
      return res.status(404).json({ error: 'Calendar event not found in user calendar' });
    }

    // Remove the event from the user's calendar
    userCalendar.calendarevents.splice(targetEventIndex, 1);

    // Save the updated plan with the deleted event
    await existingPlan.save();

    res.status(200).json({ message: 'Calendar event deleted successfully from user calendar' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});


//edit personal event on calendar 

router.put('/:planId/:userId/calendarevents/:eventId', async (req, res) => {
  try {
    const { planId, userId, eventId } = req.params;
    const { name, price, starttime, endtime } = req.body;

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      return res.status(404).json({ error: 'Plan not found' });
    }

    // Find the user's calendar within the calendarevents array
    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'User calendar not found' });
    }

    // Find the event to edit in the user's calendar
    const targetEvent = userCalendar.calendarevents.find(event => event._id.toString() === eventId);

    if (!targetEvent) {
      return res.status(404).json({ error: 'Calendar event not found in user calendar' });
    }

    // Check if the event is of type 'personal'
    if (targetEvent.type !== 'personal') {
      return res.status(403).json({ error: 'Permission denied. Can only edit personal calendar events.' });
    }

    // Update the event properties if provided
    if (name) targetEvent.name = name;
    if (price !== undefined) targetEvent.price = price;
    if (starttime) targetEvent.starttime = starttime;
    if (endtime) targetEvent.endtime = endtime;

    // Save the updated plan with the edited event
    await existingPlan.save();

    res.status(200).json({ message: 'Calendar event edited successfully', editedEvent: targetEvent });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
