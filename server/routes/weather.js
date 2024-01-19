const express = require('express');
const router = express.Router();
const axios = require('axios');
const WeatherModel = require('../models/weather'); 

router.get('/fnsweather', async (req, res) => {
  try {
    const apiUrl = 'http://api.weatherbit.io/v2.0/forecast/daily';
    const apiKey = 'e86d0d85dbaf454c969d27bd271d356c'; 
    const lat = 36.8969;
    const lon = 30.7133;

    const response = await axios.get(apiUrl, {
      params: {
        key: apiKey,
        lat,
        lon,
      },
    });

    const weatherDataList = response.data.data.map((dayData) => ({
      date: dayData.valid_date,
      temperature: dayData.temp,
      conditions: dayData.weather.description,
    }));

    await WeatherModel.insertMany(weatherDataList);

    res.json({ message: 'weather data saved successfully', weatherDataList });
  } catch (error) {
    console.error('error fetching and saving weather data:', error.message);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
