const mongoose = require('mongoose');

const notifSchema = new mongoose.Schema({
  title: String,
  text: String,
  type: String,
  from: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  image: String,
});

const requestSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
});

const userSchema = new mongoose.Schema({
  username: String,
  email: String,
  password: String,
  profilepicture: String,
  name: String,
  notifications: [notifSchema],
  reports: { type: Number, default: 0 },
  requests: [requestSchema],
});

const User = mongoose.model('User', userSchema);

module.exports = User;
