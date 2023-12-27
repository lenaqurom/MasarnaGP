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
  location: {
    type: [Number], // [longitude, latitude]
    index: '2dsphere', // Index for geospatial queries
  },
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
  sectionname: String, 
  name: String,
  date: Date,
  starttime: Date,
  endtime: Date,
  location: {
    type: [Number], // [longitude, latitude]
    index: '2dsphere', // Index for geospatial queries
  },
  price: Number,
  user: String,
});

const calendarSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  calendarevents: [calendareventSchema],
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
  calendars: [calendarSchema],
  groupdayplans: [groupdayplanSchema],
});



const Plan = mongoose.model('Plan', oneplanSchema);

module.exports = Plan;
