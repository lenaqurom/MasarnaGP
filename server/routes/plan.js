const express = require('express');
const router = express.Router();
const Plan = require('../models/plan');
const User = require('../models/user');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' }); 
const path = require('path');

router.post('/plan', upload.single('image'), async (req, res) => {
    try {
      console.log(req.body); 
      const { name, description, userid } = req.body;
  
      let imagePath = '';  // Define imagePath outside of the if block
  
      if (req.file) {
        imagePath = req.file.path.replace(/\\/g, '/');
      }
  
      const newPlan = new Plan({
        user: userid,
        name: name,
        image: imagePath ? path.join('uploads', path.basename(imagePath)) : '', // Use imagePath here
        description: description,
      });
  
      await newPlan.save();
  
      res.status(201).json({ message: 'Plan added successfully', plan: newPlan });
    } catch (error) {
      // Handle any errors, such as database errors
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  

router.delete('/plan/:planid', async (req, res) => {
    try {
      const planid = req.params.planid;
  
      // Check if the plan exists
      const existingPlan = await Plan.findById(planid);
      if (!existingPlan) {
        return res.status(404).json({ error: 'Plan not found' });
      }
  
      // Delete the plan
      await Plan.findByIdAndDelete(planid);
  
      res.status(200).json({ message: 'Plan deleted successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  
  router.put('/plan/:planid', upload.single('image'), async (req, res) => {
    try {
      const planid = req.params.planid;
      const { name, description } = req.body;
  
      // Check if the plan exists
      const existingPlan = await Plan.findById(planid);
      if (!existingPlan) {
        return res.status(404).json({ error: 'Plan not found' });
      }
  
      // Update the plan details
      existingPlan.name = name;
  
      // Update the image only if a new image is uploaded
      if (req.file) {
        const imagePath = req.file.path.replace(/\\/g, '/');
        existingPlan.image = path.join('uploads', path.basename(imagePath));
      }
  
      existingPlan.description = description;
  
      // Save the updated plan
      await existingPlan.save();
  
      res.status(200).json({ message: 'Plan updated successfully', plan: existingPlan });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  
  
  router.get('/plans/:userid', async (req, res) => {
    try {
        console.log(req.body);
      const userid = req.params.userid;
  
      // Check if the user exists
      const user = await User.findById(userid);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
  
      // Fetch all plans associated with the user
      const userPlans = await Plan.find({ user: userid });
  
      res.status(200).json({ plans: userPlans });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  

module.exports = router;
