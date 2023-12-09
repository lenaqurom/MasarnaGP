const express = require('express');
const router = express.Router();
const Plan = require('../models/plan');
const User = require('../models/user');
const mongoose = require('mongoose');

// add member 
router.post('/oneplan/:planId/members/:userId', async (req, res) => {
  const { planId } = req.params;
  const { userId } = req.params;

  try {
    // Find the plan by ID
    const plan = await Plan.findById(planId);

    if (!plan) {
      return res.status(404).json({ message: 'Plan not found' });
    }

    // Check if the user is already a member
    const existingMember = plan.members.find(member => member.user.equals(userId));
    if (existingMember) {
      return res.status(400).json({ message: 'User is already a member of the plan' });
    }

    // Fetch user details from the User model
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Add the new member with user details
    plan.members.push({
      user: userId,
      profilepicture: user.profilepicture,
      username: user.username,
    });

    // Save the updated plan
    await plan.save();

    res.status(200).json({ message: 'Member added successfully', members: plan.members });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});


router.delete('/oneplan/:planId/members/:userId', async (req, res) => {
   
        const { planId } = req.params;
        const { userId } = req.params;
        try {
            // Find the plan by ID
            const plan = await Plan.findById(planId);
        
            if (!plan) {
              return res.status(404).json({ message: 'Plan not found' });
            }
        
            // Check if the user is a member of the plan
            const memberIndex = plan.members.findIndex(member => member.user.equals(userId));
        
            if (memberIndex === -1) {
              return res.status(400).json({ message: 'User is not a member of the plan' });
            }
        
            // Remove the member from the plan
            plan.members.splice(memberIndex, 1);
        
            // Save the updated plan
            await plan.save();
        
            res.status(200).json({ message: 'Member deleted successfully', members: plan.members });
          } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal Server Error' });
          }
        });

    router.get('/oneplan/:planId/members', async (req, res) => {
            const { planId } = req.params;
          
            try {
              // Find the plan by ID
              const plan = await Plan.findById(planId);
          
              if (!plan) {
                return res.status(404).json({ message: 'Plan not found' });
              }
          
              // Return the members array
              res.status(200).json({ members: plan.members });
            } catch (error) {
              console.error(error);
              res.status(500).json({ message: 'Internal Server Error' });
            }
          });

module.exports = router;
