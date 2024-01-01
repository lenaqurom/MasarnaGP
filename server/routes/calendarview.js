const express = require('express');
const router = express.Router();
const Plan = require('../models/plan');
const User = require('../models/user');
const Friendslist = require('../models/friendslist');
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

    const title = `${plan.name}`;  
    const text = `you've been added to plan`;
    
    const notification = {
      title: title,
      text: text,
      type: 'news',
    };
    if (plan.image) {
      notification.image = plan.image;
    }
    // Add the notification to the user's notifications array
    user.notifications.push(notification);

    // Save the updated user
    await user.save();

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
            const user = await User.findById(userId);
        
            if (memberIndex === -1) {
              return res.status(400).json({ message: 'User is not a member of the plan' });
            }
        
            // Remove the member from the plan
            plan.members.splice(memberIndex, 1);
        
            // Save the updated plan
            await plan.save();
            const title = `${plan.name}`;  
            const text = `you've been removed from plan`;
            const notification = {
              title: title,
              text: text,
              type: 'news',
            };
            if (plan.image) {
              notification.image = plan.image;
            }
            // Add the notification to the user's notifications array
            user.notifications.push(notification);
        
            // Save the updated user
            await user.save();
        
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

  //fetch friendslist 
  router.get('/memberstoadd/:userid', async (req, res) => {
    const userId = req.params.userid;
  
    try {
      // Find the friends list by user ID
      const friendsList = await Friendslist.findOne({ userid: userId });
  
      if (!friendsList) {
        return res.status(404).json({ message: 'Friends list not found' });
      }
  
      // Extract friend IDs from the friends list
      const friendIds = friendsList.friendid;
  
      // Fetch user details for each friend, excluding existing members
      const existingMembers = await Plan.findOne({ 'members.user': userId });
      const existingMemberIds = existingMembers ? existingMembers.members.map(member => member.user.toString()) : [];
  
      const friendDetails = await User.find(
        {
          _id: { $in: friendIds },
          _id: { $nin: existingMemberIds }, // Exclude existing members
        },
        'username profilepicture'
      );
  
      res.json(friendDetails);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'An error occurred while fetching friends.' });
    }
  });
  

module.exports = router;
