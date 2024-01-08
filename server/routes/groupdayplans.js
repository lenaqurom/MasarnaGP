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

    const existingGroupDayPlan = existingPlan.groupdayplans.find(
      (plan) => plan.date && plan.date.toISOString() === new Date(date).toISOString()
    );

    if (existingGroupDayPlan) {
      return res.status(400).json({ error: 'Group day plan already exists for this date' });
    }

    // Create a new group day plan with the provided date and empty sections
    const groupDayPlan = {
      date: new Date(date), // Store as a Date object
      sections: [
        { name: 'eateries', poll: { options: [] }, comments: [] },
        { name: 'flights', poll: { options: [] }, comments: [] },
        { name: 'activities', poll: { options: [] }, comments: [] },
        { name: 'stays', poll: { options: [] }, comments: [] },
      ],
    };

    // Add the new group day plan to the existing plan
    existingPlan.groupdayplans.push(groupDayPlan);
    await existingPlan.save();

   // const currentTime = new Date();
    const newEvent = {
      type: 'group',
      sectionname: '',
      user: 1,
      name: 'dummy',
      date: groupDayPlan.date,
      price: 0,
      location: '',
      starttime: groupDayPlan.date,
      endtime: groupDayPlan.date,
    };

    // Iterate through each member's calendar and add the new event
    existingPlan.members.forEach((member) => {
      const memberCalendar = existingPlan.calendars.find(
        (cal) => cal.user.toString() === member.user.toString()
      );

      if (!memberCalendar) {
        // If the member's calendar doesn't exist, create it
        existingPlan.calendars.push({
          user: member.user,
          calendarevents: [],
        });
      }

      // Find the user's calendar again (either existing or newly created)
      const updatedMemberCalendar = existingPlan.calendars.find(
        (cal) => cal.user.toString() === member.user.toString()
      );

      // Add the new event to the member's calendar
      updatedMemberCalendar.calendarevents.push(newEvent);
    });

    // Save the updated plan
    await existingPlan.save();

    res.status(201).json({ message: 'Group day plan added successfully', plan: groupDayPlan });
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
    const { name, starttime, endtime, price, date } = req.body;
    const { longitude, latitude } = req.body.location;

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

    // Parse starttime and endtime to Date objects
    const parsedStartTime = new Date(`${date}T${starttime}:00.000Z`);
    const parsedEndTime = new Date(`${date}T${endtime}:00.000Z`);

    // Add the poll option
    targetSection.poll.options.push({
      name: name,
      date: new Date(date),
      starttime: parsedStartTime,
      endtime: parsedEndTime,
      location: [longitude, latitude], 
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
      const startTime = option.starttime ? new Date(option.starttime).toISOString() : null;
      const endTime = option.endtime ? new Date(option.endtime).toISOString() : null;

      return {
        id,
        name: option.name,
        startTime,
        endTime,
        location: option.location,
        price: option.price,
        votes,
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

     // Remove the poll option from members' personal calendars
     existingPlan.members.forEach((member) => {
      const memberCalendar = existingPlan.calendars.find((cal) => cal.user.toString() === member.user.toString());

      if (memberCalendar) {
        memberCalendar.calendarevents = memberCalendar.calendarevents.filter(
          (event) =>
            !(event.type === 'group' &&
            event.sectionname === targetSection.name &&
            event.date.toISOString() === targetGroupDayPlan.date.toISOString() &&
            event.name === targetOption.name) // Adjust the condition based on your data structure
        );
      }
    });

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

// Function to check for date conflicts between events
function hasConflict(event1, event2) {
  const start1 = new Date(event1.starttime);
  const end1 = new Date(event1.endtime);
  const start2 = new Date(event2.starttime);
  const end2 = new Date(event2.endtime);

  // Check if the events overlap
  return (
    (start1 <= start2 && end1 >= start2) || (start2 <= start1 && end2 >= start1)
  );
}

///here auto adding winning option done after every vote
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


// Check which poll option is the winner
const winningOption = targetSection.poll.options.reduce((winner, option) => (option.votes > winner.votes ? option : winner), targetSection.poll.options[0]);

// Check if there's a clear winner (no tie)
const isClearWinner = targetSection.poll.options.filter(option => option.votes === winningOption.votes).length === 1;

// Proceed only if there's a clear winner
if (isClearWinner) {
      // Remove the previously winning poll option from all members' calendars if it exists for the same sectionname and date
      existingPlan.members.forEach((member) => {
        const memberCalendar = existingPlan.calendars.find((cal) => cal.user.toString() === member.user.toString());

        if (memberCalendar) {
          memberCalendar.calendarevents = memberCalendar.calendarevents.filter(
            (event) =>{ const shouldRemove=
              event.type === 'group' &&
              event.sectionname === targetSection.name &&
              event.date.toISOString() === targetGroupDayPlan.date.toISOString();

              if(shouldRemove){
                console.log('Date comparison:', event.date.toISOString(), targetGroupDayPlan.date.toISOString());
                console.log('Section comparison:', event.sectionname, targetSection.name);
              }
              return !shouldRemove; // Return true for items that should not be removed
            });
        }
      });

      

  // Create a calendarevent based on the winning option and add it to everyone's calendars
  const newEvent = {
    type: 'group',
    user: 1, // replace with actual user id
    name: winningOption.name,
    date: targetGroupDayPlan.date,
    starttime: winningOption.starttime,
    endtime: winningOption.endtime,
    location: winningOption.location,
    price: winningOption.price,
    sectionname: targetSection.name, // Add the sectionname to the calendarevent
  };
 // Remove conflicting events and add the new event
 existingPlan.members.forEach((member) => {
  const memberCalendar = existingPlan.calendars.find((cal) => cal.user.toString() === member.user.toString());

  if (memberCalendar) {
    // Remove conflicting events
    memberCalendar.calendarevents = memberCalendar.calendarevents.filter(
      (event) => !(event.type === 'group' && hasConflict(event, newEvent))
    );

    // Add the new event
    memberCalendar.calendarevents.push(newEvent);
  }
});
  // Save the updated plan with the new calendarevent
  await existingPlan.save();
 const title=`${existingPlan.name}`;
 const text = `has new updates`;

    // Iterate through all members of the plan
    existingPlan.members.forEach(async (member) => {
      const user = await User.findById(member.user);

      if (user) {
        // Add the notification to the user's notifications array
        user.notifications.push({
          title: title,
          text: text,
          type: 'cal',
        });

        if (existingPlan.image) {
          notification.image = existingPlan.image;
        }

        // Save the updated user
        await user.save();
      }
    });
  }

res.status(200).json({
  message: 'Vote recorded successfully',
  votedOption: targetOption, // Include information about the voted option
  winningOption: winningOption, // Include information about the winning option
});
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
  
      res.status(201).json({ message: 'Comment added successfully', comments: targetSection.comments });
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

    res.status(201).json({ message: 'Comment reply added successfully', comments: targetSection.comments });
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


