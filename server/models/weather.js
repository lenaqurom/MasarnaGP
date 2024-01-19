const mongoose = require('mongoose');

const weatherSchema = new mongoose.Schema({
    date: String,
    temperature: Number,
    conditions: String,
  });
  
  const WeatherModel = mongoose.model('WeatherData', weatherSchema);
  
  module.exports = WeatherModel;