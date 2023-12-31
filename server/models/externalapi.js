const mongoose = require('mongoose');

const flightSchema = new mongoose.Schema({
  airline: String,
  price: Number,
  location: {
    type: [Number], // [longitude, latitude]
    index: '2dsphere', 
  },
  starttime: String,
  endtime: String,
  description: String,
  type: String,
  image: String, 
  favs: { type: Number, default: 0 },
  reports: { type: Number, default: 0 },
});

const staySchema = new mongoose.Schema({
    name: String,
    price: Number,
    location: {
      type: [Number], // [longitude, latitude]
      index: '2dsphere', 
    },
    starttime: String,
    endtime: String,
    description: String,
    type: String,
    image: String,
    rating: String, 
    favs: { type: Number, default: 0 },
    reports: { type: Number, default: 0 }, 
  });

const eaterySchema = new mongoose.Schema({
    name: String,
    price: Number,
    location: {
      type: [Number], // [longitude, latitude]
      index: '2dsphere', 
    },
    starttime: String,
    endtime: String,
    description: String,
    type: String,
    image: String,
    address: String,
    favs: { type: Number, default: 0 },
    reports: { type: Number, default: 0 },
  });

  const activitySchema = new mongoose.Schema({
    name: String,
    price: Number,
    location: {
      type: [Number], // [longitude, latitude]
      index: '2dsphere', 
    },
    starttime: String,
    endtime: String,
    description: String,
    type: String,
    image: String,
    goodfor: String, 
    address: String,
    favs: { type: Number, default: 0 },
    reports: { type: Number, default: 0 },
  });


  const externalapiSchema = new mongoose.Schema({
    flights: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Flight' }],
    stays: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Stay' }],
    eateries: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Eatery' }],
    activities: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Activity' }],
  });
  
  const ExternalAPI = mongoose.model('ExternalAPI', externalapiSchema);
  
  module.exports = {
    Flight: mongoose.model('Flight', flightSchema),
    Stay: mongoose.model('Stay', staySchema),
    Eatery: mongoose.model('Eatery', eaterySchema),
    Activity: mongoose.model('Activity', activitySchema),
    ExternalAPI,
  };