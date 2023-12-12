const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const Plan = require('../models/plan');
const User = require('../models/user');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' }); 
const path = require('path');


/////this is from the user's pov, all of this is in the 'your plans' screen, homescreen in the navbar

router.post('/oneplan', upload.single('image'), async (req, res) => {
  try {
    const { name, description, userid } = req.body;

    let imagePath = '';

    if (req.file) {
      imagePath = req.file.path.replace(/\\/g, '/');
    }

    // Fetch user details from the User model
    const user = await User.findById(userid);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const newPlan = new Plan({
      members: [{
        user: userid,
        profilepicture: user.profilepicture,
        username: user.username,
      }],
      name: name,
      image: imagePath ? path.join('uploads', path.basename(imagePath)) : '',
      description: description,
      calendarevents: [],
      groupdayplans: [],
    });

    await newPlan.save();
    
    const populatedPlan = await Plan.findById(newPlan._id)
      .populate({
        path: 'members.user',
        select: 'profilepicture username',
      })
      .exec();

    res.status(201).json({ message: 'Plan added successfully', plan: populatedPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});


  

router.delete('/oneplan/:planid', async (req, res) => {
    try {
      const planid = req.params.planid;
  
      const existingPlan = await Plan.findById(planid);
      if (!existingPlan) {
        return res.status(404).json({ error: 'Plan not found' });
      }
  
      await Plan.findByIdAndDelete(planid);
  
      res.status(200).json({ message: 'Plan deleted successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  
  ////////here comes adding a member, a cal event and a groupday event i believe, idk tho, not done yet
  router.put('/oneplan/:planid', upload.single('image'), async (req, res) => {
    try {
      const planid = req.params.planid;
      const { name, description } = req.body;
  
      const existingPlan = await Plan.findById(planid);
      if (!existingPlan) {
        return res.status(404).json({ error: 'Plan not found' });
      }
  
      existingPlan.name = name;
  
      if (req.file) {
        const imagePath = req.file.path.replace(/\\/g, '/');
        existingPlan.image = path.join('uploads', path.basename(imagePath));
      }
  
      existingPlan.description = description;
  
      await existingPlan.save();
  
      res.status(200).json({ message: 'Plan updated successfully', plan: existingPlan });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  
  
  router.get('/userplans/:userid', async (req, res) => {
    try {
      const userid = req.params.userid;
  
      // Check if the user exists
      const user = await User.findById(userid);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
  
      // Fetch all plans associated with the user
      const userPlans = await Plan.find({ 'members.user': userid });
  
      res.status(200).json({ plans: userPlans });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  
  
  

module.exports = router;
