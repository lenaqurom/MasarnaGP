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
      return res.status(404).json({ message: 'plan not found' });
    }

    const existingMember = plan.members.find(member => member.user.equals(userId));
    if (existingMember) {
      return res.status(400).json({ message: 'user is already a member of the plan' });
    }

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'user not found' });
    }

    plan.members.push({
      user: userId,
      profilepicture: user.profilepicture,
      username: user.username,
    });

    await plan.save();

    const title = `${plan.name}`;  
    const text = `you've been added to plan`;
    
    const notification = {
      title: title,
      text: text,
      type: 'plan',
    };
    if (plan.image) {
      notification.image = plan.image;
    }
    user.notifications.push(notification);
    await user.save();

    res.status(200).json({ message: 'member added successfully', members: plan.members });
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
              return res.status(404).json({ message: 'plan not found' });
            }
        
            const memberIndex = plan.members.findIndex(member => member.user.equals(userId));
            const user = await User.findById(userId);
        
            if (memberIndex === -1) {
              return res.status(400).json({ message: 'user is not a member of the plan' });
            }
        
            plan.members.splice(memberIndex, 1);
        
            await plan.save();
            const title = `${plan.name}`;  
            const text = `you've been removed from plan`;
            const notification = {
              title: title,
              text: text,
              type: 'plan',
            };
            if (plan.image) {
              notification.image = plan.image;
            }
            user.notifications.push(notification);
                    await user.save();
        
            res.status(200).json({ message: 'member deleted successfully', members: plan.members });
          } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal Server Error' });
          }
        });

    router.get('/oneplan/:planId/members', async (req, res) => {
            const { planId } = req.params;
          
            try {
              const plan = await Plan.findById(planId);
          
              if (!plan) {
                return res.status(404).json({ message: 'plan not found' });
              }
          
              res.status(200).json({ members: plan.members });
            } catch (error) {
              console.error(error);
              res.status(500).json({ message: 'Internal Server Error' });
            }
          });

          router.get('/memberstoadd/:userid/:planid', async (req, res) => {
            const userId = req.params.userid;
            const planId = req.params.planid;
        
            try {
                console.log("User ID:", userId);
                console.log("Plan ID:", planId);
        
                const friendsList = await Friendslist.findOne({ userid: userId });
                console.log("Friends List:", friendsList);
        
                if (!friendsList) {
                    return res.status(404).json({ message: 'friends list not found' });
                }
        
                const friendIds = friendsList.friendid;
                console.log("Friend IDs:", friendIds);
        
                const existingMembers = await Plan.findOne({ _id: planId, 'members.user': userId });
                const existingMemberIds = existingMembers ? existingMembers.members.map(member => member.user.toString()) : [];
                console.log("Existing Member IDs in Plan:", existingMemberIds);
        
                const friendDetails = await User.find(
                    {
                        $and: [
                            { _id: { $in: friendIds } },
                            { _id: { $nin: existingMemberIds } },
                        ]
                    },
                    'username profilepicture'
                );
        
                console.log("Friend Details:", friendDetails);
        
                res.json(friendDetails);
            } catch (error) {
                console.error(error);
                res.status(500).json({ error: 'an error occurred while fetching friends.' });
            }
        });

module.exports = router;
