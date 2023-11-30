const express = require('express');
const router = express.Router();
const Plan = require('../models/plan');
const User = require('../models/user');
const mongoose = require('mongoose');

//this is the calendar prompt after choosing to add a group plan/event. formerly the 'homesection' 
router.post('/oneplan/:planId/groupdayplan', async (req, res) => {
  try {
    const planId = req.params.planId;

    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    // Extract the date from the request body
    const { date } = req.body;

    // Create a new group day plan with the provided date and empty sections
    const groupDayPlan = {
      date: date,
      sections: [
        { name: 'eateries', poll: { options: [] }, comments: [] },
        { name: 'flights', poll: { options: [] }, comments: [] },
        { name: 'activities', poll: { options: [] }, comments: [] },
        { name: 'stays', poll: { options: [] }, comments: [] },
      ],
    };

    // Add the new group day plan to the existing plan
    existingPlan.groupdayplans.push(groupDayPlan);

    // Save the updated plan
    await existingPlan.save();

    res.status(201).json({ message: 'Group day plan added successfully', plan: existingPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});


router.post('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/poll-option', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const groupDayPlanId = req.params.groupDayPlanId;
    const { name, starttime, endtime, location, price } = req.body;

    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    // Find the section within the group day plan
    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }

    // Add the poll option
    targetSection.poll.options.push({
      name: name,
      starttime:starttime,
      endtime: endtime,
      location: location, 
      price: price, 
      votes: 0,
    });

    await existingPlan.save();

    res.status(201).json({ message: 'Poll option added successfully', plan: existingPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});
///if we were to implement editing poll options 
//router.put('/oneplan/:planId/section/:sectionName/poll-option/:optionId', async (req, res) => {
//  try {
 //   const planId = req.params.planId;
//    const sectionName = req.params.sectionName;
  //  const optionId = req.params.optionId;
 //   const { newOptionName } = req.body;

    // Check if the plan exists
   // const existingPlan = await Plan.findById(planId);
  //  if (!existingPlan) {
    //  console.log('Plan not found');
     // return res.status(404).json({ error: 'Plan not found' });
   // }

    // Find the section within the plan
   // const targetSection = existingPlan.sections.find((section) => section.name === sectionName);
   // if (!targetSection) {
 //     console.log('Section not found');
   //   return res.status(404).json({ error: 'Section not found' });
    //}

    // Find the poll option within the section
   // const targetOption = targetSection.poll.options.id(optionId);
   // if (!targetOption) {
     // console.log('Poll option not found');
    //  return res.status(404).json({ error: 'Poll option not found' });
   // }

    // Edit the poll option name
   // targetOption.name = newOptionName;

   // await existingPlan.save();
   // const updatedPlan = await Plan.findById(planId);

   // res.status(200).json({ message: 'Poll option edited successfully', plan: updatedPlan });
 // } catch (error) {
   // console.error(error);
   // res.status(500).json({ error: 'Server error' });
  ///}
//});

router.get('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/poll-options', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const groupDayPlanId = req.params.groupDayPlanId;

    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('Plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }
 
     // Find the section within the group day plan
     const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
     if (!targetSection) {
       console.log('Section not found');
       return res.status(404).json({ error: 'Section not found' });
     }

     const pollOptions = targetSection.poll.options.map((option) => {
      const id = option._id !== undefined ? option._id : null;
      const votes = option.votes !== undefined ? option.votes : 0;
    
      return {
        id: id,
        name: option.name,
        starttime: option.starttime,
        endtime: option.endtime,
        location: option.location,
        price: option.price,
        votes: votes,
      };
    });

    // Find the winner (option with the most votes, no winner if all votes are equal)
    //this should be moved to the vote request to check before adding to calendar events
   // const sortedPollOptions = [...pollOptions].sort((a, b) => b.votes - a.votes);
   // const winner = sortedPollOptions[0].votes === sortedPollOptions[1].votes ? null : sortedPollOptions[0];


    res.status(200).json({ pollOptions});
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

router.delete('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/poll-option/:optionId', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const optionId = req.params.optionId;
    const groupDayPlanId = req.params.groupDayPlanId;

    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('Plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    // Find the section within the group day plan
    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }

    // Find the poll option within the section
    const targetOption = targetSection.poll.options.id(optionId);
    if (!targetOption) {
      console.log('Poll option not found');
      return res.status(404).json({ error: 'Poll option not found' });
    }

    // Remove the poll option
    targetSection.poll.options.pull(targetOption);

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(200).json({ message: 'Poll option deleted successfully', plan: updatedPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});


///here auto adding winning option should be done after every vote
router.post('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/poll-option/:optionId/vote', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const optionId = req.params.optionId;
    const groupDayPlanId = req.params.groupDayPlanId;

    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('Plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    // Find the section within the group day plan
    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }

    // Find the poll option within the section
    const targetOption = targetSection.poll.options.id(optionId);
    if (!targetOption) {
      console.log('Poll option not found');
      return res.status(404).json({ error: 'Poll option not found' });
    }

    // Increase the number of votes by one
    targetOption.votes += 1;

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(200).json({ message: 'Vote recorded successfully', plan: updatedPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});



router.post('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/:userId/comment', async (req, res) => {
    try {
      const planId = req.params.planId;
      const sectionName = req.params.sectionName;
      const userId = req.params.userId;
      const { text } = req.body;
      const groupDayPlanId = req.params.groupDayPlanId;
  
      // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('Plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }
  
      const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    // Find the section within the group day plan
    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }


      const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
  
      // Add the comment
      const newComment = {
        user: user._id,
        username: user.username,  // Include the username
        profilepicture: user.profilepicture,
        text: text,
        replies: [],
      };
  
      targetSection.comments.push(newComment);
  
      await existingPlan.save();
  
      res.status(201).json({ message: 'Comment added successfully', plan: existingPlan });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  });

router.post('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/:commentId/reply', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const commentId = req.params.commentId;
    const { text, userId } = req.body;
    const groupDayPlanId = req.params.groupDayPlanId;

    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('Plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    // Find the section within the group day plan
    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }

    // Find the comment within the section
    const targetComment = targetSection.comments.id(commentId);
    if (!targetComment) {
      console.log('Comment not found');
      return res.status(404).json({ error: 'Comment not found' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Add the reply
    const newReply = {
      user: user._id,
      username: user.username,  // Include the username
      profilepicture: user.profilepicture,
      text: text,
    };

    targetComment.replies.push(newReply);

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(201).json({ message: 'Comment reply added successfully', plan: updatedPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

router.delete('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/:commentId', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const commentId = req.params.commentId;
    const groupDayPlanId = req.params.groupDayPlanId;


    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('Plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    // Find the section within the group day plan
    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }

    // Find the comment in the comments array
    const targetComment = targetSection.comments.id(commentId);
    if (targetComment) {
      // Remove the comment from the comments array
      targetSection.comments.pull(commentId);
    } else {
      // Check if the comment is a reply in any of the comments
      targetSection.comments.forEach((comment) => {
        comment.replies.pull(commentId);
      });
    }

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(200).json({ message: 'Comment deleted successfully', plan: updatedPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

router.put('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/:commentId', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const commentId = req.params.commentId;
    const { newText } = req.body;
    const groupDayPlanId = req.params.groupDayPlanId;


    // Check if the plan exists
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('Plan not found');
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    // Find the section within the group day plan
    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }

    // Find the comment in the comments array
    const targetComment = targetSection.comments.id(commentId);
    if (targetComment) {
      // Edit the comment text
      targetComment.text = newText;
    } else {
      // Check if the comment is a reply in any of the comments
      for (const comment of targetSection.comments) {
        const targetReply = comment.replies.id(commentId);
        if (targetReply) {
          // Edit the reply text
          targetReply.text = newText;
          break;
        }
      }
    }

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(200).json({ message: 'Comment edited successfully', plan: updatedPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

router.get('/oneplan/:planId/groupdayplan/:groupDayPlanId/section/:sectionName/comments', async (req, res) => {
  try {
    const planId = req.params.planId;
    const sectionName = req.params.sectionName;
    const groupDayPlanId = req.params.groupDayPlanId;

    const existingPlan = await Plan.findById(planId);

    if (!existingPlan) {
      return res.status(404).json({ error: 'Plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'Group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('Section not found');
      return res.status(404).json({ error: 'Section not found' });
    }

    const commentsWithUserDetails = await populateComments(targetSection.comments);

    res.status(200).json({ comments: commentsWithUserDetails });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});
async function populateComments(comments) {
  return Promise.all(comments.map(async (comment) => {
    const populatedComment = await populateUserDetails(comment);

    populatedComment.replies = await Promise.all(comment.replies.map(async (reply) => {
      return await populateUserDetails(reply);
    }));

    return populatedComment;
  }));
}

async function populateUserDetails(doc) {
  if (doc.user) {
    const user = await User.findById(doc.user).select('username profilepicture');
    if (user) {
      doc.user = {
        _id: user._id,
        username: user.username,
        profilepicture: user.profilepicture,
      };
    }
  }
  return doc;
}







module.exports = router;


