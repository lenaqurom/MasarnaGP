const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  text: String,
  username: String, 
  profilepicture: String,
  replies: [
    {
      user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      text: String,
      username: String, 
      profilepicture: String,
    },
  ],
});

const pollOptionSchema = new mongoose.Schema({
  name: String,
  starttime: Date,
  endtime: Date,
  location: String,
  price: Number,
  votes: { type: Number, default: 0 },
});

const sectionSchema = new mongoose.Schema({
  name: {
    type: String,
    enum: ['eateries', 'flights', 'activities', 'stays'],
  },
  poll: {
    options: [pollOptionSchema],
  },
  comments: [commentSchema],
});

const groupdayplanSchema = new mongoose.Schema({
  date: Date,
  sections: [sectionSchema],
});

const calendareventSchema = new mongoose.Schema({
  type: String,
  name: String,
  date: Date,
  starttime: Date,
  endtime: Date,
  location: String,
  price: Number,
  user: String,
});

const planmembersSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  profilepicture: String,
  username: String,
});

const oneplanSchema = new mongoose.Schema({
  members: [planmembersSchema],
  name: String,
  image: String,
  description: String,
  calendarevents: [calendareventSchema],
  groupdayplans: [groupdayplanSchema],
});



const Plan = mongoose.model('Plan', oneplanSchema);

module.exports = Plan;
