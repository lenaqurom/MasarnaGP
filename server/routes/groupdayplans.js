const express = require('express');
const router = express.Router();
const Plan = require('../models/plan');
const User = require('../models/user');
const mongoose = require('mongoose');

//this is the calendar prompt after choosing to add a group plan/event. formerly the 'homesection' 
router.post('/oneplan/:planId/groupdayplan', async (req, res) => {
  try {
    const planId = req.params.planId;
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }
    const { date } = req.body;

    const existingGroupDayPlan = existingPlan.groupdayplans.find(
      (plan) => plan.date && plan.date.toISOString() === new Date(date).toISOString()
    );

    if (existingGroupDayPlan) {
      return res.status(400).json({ error: 'group day plan already exists for this date' });
    }

    const groupDayPlan = {
      date: new Date(date), 
      sections: [
        { name: 'eateries', poll: { options: [] }, comments: [] },
        { name: 'flights', poll: { options: [] }, comments: [] },
        { name: 'activities', poll: { options: [] }, comments: [] },
        { name: 'stays', poll: { options: [] }, comments: [] },
      ],
    };

    existingPlan.groupdayplans.push(groupDayPlan);
    await existingPlan.save();

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

    existingPlan.members.forEach((member) => {
      const memberCalendar = existingPlan.calendars.find(
        (cal) => cal.user.toString() === member.user.toString()
      );

      if (!memberCalendar) {
        existingPlan.calendars.push({
          user: member.user,
          calendarevents: [],
        });
      }

      const updatedMemberCalendar = existingPlan.calendars.find(
        (cal) => cal.user.toString() === member.user.toString()
      );

      updatedMemberCalendar.calendarevents.push(newEvent);
    });

    await existingPlan.save();

    res.status(201).json({ message: 'group day plan added successfully', plan: groupDayPlan });
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

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('Group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
    }

    const parsedStartTime = new Date(`${date}T${starttime}:00.000Z`);
    const parsedEndTime = new Date(`${date}T${endtime}:00.000Z`);

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

    res.status(201).json({ message: 'poll option added successfully', plan: existingPlan });
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

   // const existingPlan = await Plan.findById(planId);
  //  if (!existingPlan) {
    //  console.log('plan not found');
     // return res.status(404).json({ error: 'plan not found' });
   // }

   // const targetSection = existingPlan.sections.find((section) => section.name === sectionName);
   // if (!targetSection) {
 //     console.log('section not found');
   //   return res.status(404).json({ error: 'section not found' });
    //}

   // const targetOption = targetSection.poll.options.id(optionId);
   // if (!targetOption) {
     // console.log('poll option not found');
    //  return res.status(404).json({ error: 'poll option not found' });
   // }

   // targetOption.name = newOptionName;

   // await existingPlan.save();
   // const updatedPlan = await Plan.findById(planId);

   // res.status(200).json({ message: 'poll option edited successfully', plan: updatedPlan });
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

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
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

    // find the winner (option with the most votes, no winner if all votes are equal)
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

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
    }

    const targetOption = targetSection.poll.options.id(optionId);
    if (!targetOption) {
      console.log('poll option not found');
      return res.status(404).json({ error: 'poll option not found' });
    }

     existingPlan.members.forEach((member) => {
      const memberCalendar = existingPlan.calendars.find((cal) => cal.user.toString() === member.user.toString());

      if (memberCalendar) {
        memberCalendar.calendarevents = memberCalendar.calendarevents.filter(
          (event) =>
            !(event.type === 'group' &&
            event.sectionname === targetSection.name &&
            event.date.toISOString() === targetGroupDayPlan.date.toISOString() &&
            event.name === targetOption.name) 
        );
      }
    });

    targetSection.poll.options.pull(targetOption);

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(200).json({ message: 'poll option deleted successfully', plan: updatedPlan });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

function hasConflict(event1, event2) {
  const start1 = new Date(event1.starttime);
  const end1 = new Date(event1.endtime);
  const start2 = new Date(event2.starttime);
  const end2 = new Date(event2.endtime);

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

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
    }

    const targetOption = targetSection.poll.options.id(optionId);
    if (!targetOption) {
      console.log('poll option not found');
      return res.status(404).json({ error: 'poll option not found' });
    }

    targetOption.votes += 1;

    await existingPlan.save();


const winningOption = targetSection.poll.options.reduce((winner, option) => (option.votes > winner.votes ? option : winner), targetSection.poll.options[0]);

const isClearWinner = targetSection.poll.options.filter(option => option.votes === winningOption.votes).length === 1;

if (isClearWinner) {
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
              return !shouldRemove; 
            });
        }
      });

      

  const newEvent = {
    type: 'group',
    user: 1, // replace with actual user id
    name: winningOption.name,
    date: targetGroupDayPlan.date,
    starttime: winningOption.starttime,
    endtime: winningOption.endtime,
    location: winningOption.location,
    price: winningOption.price,
    sectionname: targetSection.name, 
  };
 existingPlan.members.forEach((member) => {
  const memberCalendar = existingPlan.calendars.find((cal) => cal.user.toString() === member.user.toString());

  if (memberCalendar) {
    memberCalendar.calendarevents = memberCalendar.calendarevents.filter(
      (event) => !(event.type === 'group' && hasConflict(event, newEvent))
    );

    memberCalendar.calendarevents.push(newEvent);
  }
});
  await existingPlan.save();
 const title=`${existingPlan.name}`;
 const text = `has new updates`;

    existingPlan.members.forEach(async (member) => {
      const user = await User.findById(member.user);

      if (user) {
        const notification = {
          title: title,
          text: text,
          type: 'plan',
        }
                user.notifications.push(notification);

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
  votedOption: targetOption, 
  winningOption: winningOption, 
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
  
    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }
  
      const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
    }


      const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'user not found' });
    }
  
      const newComment = {
        user: user._id,
        username: user.username,  
        profilepicture: user.profilepicture,
        text: text,
        replies: [],
      };
  
      targetSection.comments.push(newComment);
  
      await existingPlan.save();
  
      res.status(201).json({ message: 'comment added successfully', comments: targetSection.comments });
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

    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
    }

    const targetComment = targetSection.comments.id(commentId);
    if (!targetComment) {
      console.log('comment not found');
      return res.status(404).json({ error: 'comment not found' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'user not found' });
    }

    const newReply = {
      user: user._id,
      username: user.username,  
      profilepicture: user.profilepicture,
      text: text,
    };

    targetComment.replies.push(newReply);

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(201).json({ message: 'comment reply added successfully', comments: targetSection.comments });
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


    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
    }

    const targetComment = targetSection.comments.id(commentId);
    if (targetComment) {
      targetSection.comments.pull(commentId);
    } else {
      targetSection.comments.forEach((comment) => {
        comment.replies.pull(commentId);
      });
    }

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(200).json({ message: 'comment deleted successfully', plan: updatedPlan });
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


    const existingPlan = await Plan.findById(planId);
    if (!existingPlan) {
      console.log('plan not found');
      return res.status(404).json({ error: 'plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
    }

    const targetComment = targetSection.comments.id(commentId);
    if (targetComment) {
      targetComment.text = newText;
    } else {
      for (const comment of targetSection.comments) {
        const targetReply = comment.replies.id(commentId);
        if (targetReply) {
          targetReply.text = newText;
          break;
        }
      }
    }

    await existingPlan.save();
    const updatedPlan = await Plan.findById(planId);

    res.status(200).json({ message: 'comment edited successfully', plan: updatedPlan });
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
      return res.status(404).json({ error: 'plan not found' });
    }

    const targetGroupDayPlan = existingPlan.groupdayplans.find((groupDayPlan) => groupDayPlan._id.toString() === groupDayPlanId);
    if (!targetGroupDayPlan) {
      console.log('group day plan not found');
      return res.status(404).json({ error: 'group day plan not found' });
    }

    const targetSection = targetGroupDayPlan.sections.find((section) => section.name === sectionName);
    if (!targetSection) {
      console.log('section not found');
      return res.status(404).json({ error: 'section not found' });
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


