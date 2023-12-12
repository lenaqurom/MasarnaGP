const mongoose = require('mongoose');

const friendslistSchema = new mongoose.Schema({
  userid: String,
  friendid: [String],
});

const FriendsList = mongoose.model('FriendsList', friendslistSchema);

module.exports = FriendsList;
