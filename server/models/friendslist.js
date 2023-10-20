const mongoose = require('mongoose');

const friendslistSchema = new mongoose.Schema({
  userName: String,
  friendName: String,
});

const FriendsList = mongoose.model('FriendsList', friendslistSchema);

module.exports = FriendsList;
