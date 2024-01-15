const express = require('express');
const router = express.Router();
const Plan = require('../models/plan'); 
const User = require('../models/user'); 
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
        return res.status(404).json({ error: 'user or plan not found' });
      }
      
    const parsedStartTime = new Date(`${date}T${starttime}:00.000Z`);
    const parsedEndTime = new Date(`${date}T${endtime}:00.000Z`);
    
console.log('Received Time Strings:', starttime, endtime, date);


console.log('Parsed Start Time:', parsedStartTime);
console.log('Parsed End Time:', parsedEndTime);

let userCalendar = planExists.calendars.find((calendar) => calendar.user.equals(userId));

if (!userCalendar) {
  userCalendar = {
    user: userId,
    calendarevents: [],
  };
  planExists.calendars.push(userCalendar);
}

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

    userCalendar.calendarevents.push(newEvent);

    await planExists.save();
    console.log('User Calendar:', userCalendar);
    console.log('Updated Plan:', planExists);

    res.status(201).json({ message: 'new personal plan added successfully', plan: planExists });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});


router.get('/:planId/:userId/calendarevents', async (req, res) => {
  try {
    const { planId, userId } = req.params;
    const existingPlan = await Plan.findById(planId);

    if (!existingPlan) {
      return res.status(404).json({ error: 'plan not found' });
    }

    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'user calendar not found' });
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
      return res.status(404).json({ error: 'plan not found' });
    }

    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'User calendar not found' });
    }

    const eventsForDate = userCalendar.calendarevents.filter(event =>
      event.date.toISOString().split('T')[0] === targetDate.toISOString().split('T')[0]
    );

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
      return res.status(404).json({ error: 'plan not found' });
    }

    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'user calendar not found' });
    }

    const targetEventIndex = userCalendar.calendarevents.findIndex(event => event._id.toString() === eventId);

    if (targetEventIndex === -1) {
      return res.status(404).json({ error: 'calendar event not found in user calendar' });
    }

    userCalendar.calendarevents.splice(targetEventIndex, 1);

    await existingPlan.save();

    res.status(200).json({ message: 'calendar event deleted successfully from user calendar' });
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
      return res.status(404).json({ error: 'plan not found' });
    }

    const userCalendar = existingPlan.calendars.find((calendar) => calendar.user.equals(userId));

    if (!userCalendar) {
      return res.status(404).json({ error: 'user calendar not found' });
    }

    const targetEvent = userCalendar.calendarevents.find(event => event._id.toString() === eventId);

    if (!targetEvent) {
      return res.status(404).json({ error: 'calendar event not found in user calendar' });
    }

    if (targetEvent.type !== 'personal') {
      return res.status(403).json({ error: 'permission denied. can only edit personal calendar events.' });
    }

    if (name) targetEvent.name = name;
    if (price !== undefined) targetEvent.price = price;
    if (starttime) targetEvent.starttime = starttime;
    if (endtime) targetEvent.endtime = endtime;

    await existingPlan.save();

    res.status(200).json({ message: 'calendar event edited successfully', editedEvent: targetEvent });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
