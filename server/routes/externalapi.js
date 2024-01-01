const express = require('express');
const router = express.Router();
const { ExternalAPI, Flight, Stay, Eatery, Activity } = require('../models/externalapi');
const puppeteer = require('puppeteer');

router.get('/flights', async (req, res) => {
  try {
    
    const externalAPIInstance = new ExternalAPI();
    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();
    const pageContent = await page.content();
    console.log('Page Content:', pageContent);

    try {
      await page.goto('https://www.google.com/travel/flights/search?tfs=CBwQAhokEgoyMDI0LTAxLTAxagcIARIDQU1Ncg0IAhIJL20vMDFfaGhwGiQSCjIwMjQtMDEtMzFqDQgCEgkvbS8wMV9oaHByBwgBEgNBTU1AAUABSAFwAYIBCwj___________8BmAEBsgELEgkvbS8wMV9oaHA&hl=en-US&curr=JOD', {
        waitUntil: 'domcontentloaded',
      });

      await page.waitForFunction(() => {
        const flights = document.querySelectorAll('.Rk10dc li.pIav2d');
        return flights && flights.length >= 2; 
      }, { timeout: 10000 }); 

      const flightData = await page.evaluate(() => {
        const flights = [];
        document.querySelectorAll('.Rk10dc li.pIav2d').forEach((element) => {
          const type = 'flights';
          const airline = element.querySelector('.sSHqwe.tPgKwe.ogfYpf').textContent;
          const priceElement = element.querySelector('.YMlIz.FpEdX span[aria-label]');
          const price = parseFloat(priceElement?.getAttribute('aria-label').replace('JOD', '').trim()) || (priceElement?.getAttribute('aria-label').replace('Jordanian dinars', '').trim()) || 0;
          const description = element.querySelector('.gvkrdb.AdWm1c.tPgKwe.ogfYpf').textContent + '. AMM-AYT. ' + element.querySelector('.BbR8Ec').textContent;
          const location= [36.9123, 30.8024];
          const image='';
          
          const startTimeText = element.querySelector('span[aria-label*="Departure time"]').textContent;
          const endTimeText = element.querySelector('span[aria-label*="Arrival time"]').textContent;

          function parseTime(timeText) {
            const match = timeText.match(/(\d{1,2}:\d{2})\s*([APMapm]{2})/);
            if (match) {
              let [_, time, period] = match;
              let hours = parseInt(time.split(':')[0], 10);

              if (period.toLowerCase() === 'pm' && hours < 12) {
                hours += 12;
              } else if (period.toLowerCase() === 'am' && hours === 12) {
                hours = 0;
              }

              return `${hours.toString().padStart(2, '0')}:${time.split(':')[1]}`;
            }

            return null;
          }

          flights.push({
            airline,
            price,
            description,
            type,
            starttime: parseTime(startTimeText),
            endtime: parseTime(endTimeText),
            location,
            image,
          });
        });
        return flights;
      });

      console.log('Extracted data:', flightData);
      const savedFlights = await Flight.create(flightData);

      externalAPIInstance.flights = savedFlights;
      await externalAPIInstance.save();

      res.json({ message: 'Flight information scraped and saved successfully!', savedFlights });
    } finally {
      await browser.close();
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error', errorMessage: error.message });
  }
});

router.get('/hotels', async (req, res) => {
  try {
    const externalAPIInstance = new ExternalAPI();
    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();

    try {
      await page.goto('https://www.google.com/travel/search?ts=CAESCAoCCAMKAggDGi4KFhIUCgkvbS8wMV9oaHA6B0FudGFseWESFBISCgcI5w8QDBgPEgcI6A8QARgfKgIKAA&ved=0CAAQ5JsGahcKEwi4zsmdjpCDAxUAAAAAHQAAAAAQBg&ictx=3&hl=en-US', {
        waitUntil: 'domcontentloaded',
      });

      await page.waitForFunction(() => {
        const hotels = document.querySelectorAll('.SJyhnc li.pQIVh');
        return hotels && hotels.length >= 5; 
      }, { timeout: 50000 }); 

        const hotelData = await page.evaluate(() => {
        const hotels = [];
        document.querySelectorAll('.SJyhnc li.pQIVh').forEach((element) => {
          const type = 'stays';
          const name = element.querySelector('.AdWm1c.AFZtd.ogfYpf.aK8acc').textContent;
          const priceElement = element.querySelector('.wBPfMc.AdWm1c');
          const price = parseFloat(priceElement?.textContent.replace('₪', '').trim()) || 0;
          const descriptionElement = element.querySelector('.ujJAIe.PxBked .nwVibc.CQYfx.ogfYpf:not(:has(.ta47le))'); 
          const description = descriptionElement ? descriptionElement.textContent.trim() : '';
          const imageElement = element.querySelector('.x7VXS.uGZqbf.PzN0s');
          const image = imageElement ? imageElement.getAttribute('src') : '';
          const ratingElement = element.querySelector('.ta47le[aria-label]');
          const text = ratingElement.getAttribute('aria-label');
          const rating = parseFloat(text.match(/([\d.]+)/)?.[0]) || 0;



          hotels.push({ name, price, description, type, image, rating });
        });
        return hotels;
      });

      console.log('Extracted hotel data:', hotelData);
      const savedHotels = await Stay.create(hotelData);

      externalAPIInstance.stays = savedHotels;
      await externalAPIInstance.save();

      res.json({ message: 'Hotel information scraped and saved successfully!', savedHotels });
    } finally {
      await browser.close();
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error', errorMessage: error.message });
  }
});


router.get('/nightlifeactivities', async (req, res) => {
  try {
    const externalAPIInstance = new ExternalAPI();
    const browser = await puppeteer.launch({ headless: 'new', args: ['--disable-http2'] });
    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

    try {
      await page.goto('https://www.hotels.com/go/turkey/best-nightlife-antalya', {
        waitUntil: 'domcontentloaded',
      });

      await page.waitForSelector('.listicle-item-wrap .listicle-item');

      const activityData = await page.evaluate(() => {
        const activities = [];
        document.querySelectorAll('.listicle-item-wrap .listicle-item').forEach((element) => {
          const type = 'activities';
          const name = element.querySelector('.header-inner-wrap h2').textContent;
          const description = element.querySelector('.description-wrap p').textContent;
          const locationElement = element.querySelector('.map-button');
          const coordinatesString = locationElement ? locationElement.getAttribute('data-coord') : null;
         // const location = coordinatesString ? coordinatesString.split(',').map(coord => Number(coord.trim())) : null;

          const location =
          coordinatesString &&
          coordinatesString.split(',').length === 2 &&
          coordinatesString.split(',').every(coord => !isNaN(Number(coord.trim())))
            ? coordinatesString.split(',').map(coord => Number(coord.trim()))
            : [0, 0];
                  const goodfor = 'nightlife'; 
        

          const imageElement = element.querySelector('.resp-image');
          const image = imageElement ? imageElement.getAttribute('data-src-mobile') : null;



          const addElement = element.querySelector('.info-bullet-wrap p strong');

if (addElement && addElement.textContent.includes('Location:')) {
  const address = addElement.nextSibling.textContent.trim();
  
  activities.push({ name, type, description, location, image, goodfor, address });
}
else{
  activities.push({ name, type, description, location, image, goodfor});

}         
        });
        return activities;
      });

      console.log('Extracted activity data:', activityData);
      const savedActivities = await Activity.create(activityData);

      externalAPIInstance.activities = savedActivities;
      await externalAPIInstance.save();

      res.json({ message: 'Activity information scraped and saved successfully!', savedActivities });
    } finally {
      await browser.close();
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error', errorMessage: error.message });
  }
});

router.get('/sightseeingactivities', async (req, res) => {
  try {
    const externalAPIInstance = new ExternalAPI();
    const browser = await puppeteer.launch({ headless: 'new', args: ['--disable-http2'] });
    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

    try {
      await page.goto('https://www.hotels.com/go/turkey/things-to-do-antalya', {
        waitUntil: 'domcontentloaded',
      });

      await page.waitForSelector('.listicle-item-wrap .listicle-item');

      const activityData = await page.evaluate(() => {
        const activities = [];
        document.querySelectorAll('.listicle-item-wrap .listicle-item').forEach((element) => {
          const type = 'activities';
          const name = element.querySelector('.header-inner-wrap h2').textContent;
          const description = element.querySelector('.description-wrap p').textContent;
          const locationElement = element.querySelector('.map-button');
          const coordinatesString = locationElement ? locationElement.getAttribute('data-coord') : null;
          const location = coordinatesString ? coordinatesString.split(',').map(coord => Number(coord.trim())) : 0.0;
          const goodfor = 'sightseeing'; 

          const imageElement = element.querySelector('.resp-image');
          const image = imageElement ? imageElement.getAttribute('data-src-mobile') : null;

          const addElement = element.querySelector('.info-bullet-wrap p strong');

          if (addElement && addElement.textContent.includes('Location:')) {
            const address = addElement.nextSibling.textContent.trim();
            
            activities.push({ name, type, description, location, image, goodfor, address });
          }
          else{
            activities.push({ name, type, description, location, image, goodfor});
          
          }    
        });
        return activities;
      });

      console.log('Extracted activity data:', activityData);
      const savedActivities = await Activity.create(activityData);

      externalAPIInstance.activities = savedActivities;
      await externalAPIInstance.save();

      res.json({ message: 'Activity information scraped and saved successfully!', savedActivities });
    } finally {
      await browser.close();
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error', errorMessage: error.message });
  }
});

router.get('/shoppingactivities', async (req, res) => {
  try {
    const externalAPIInstance = new ExternalAPI();
    const browser = await puppeteer.launch({ headless: 'new', args: ['--disable-http2'] });
    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

    try {
      await page.goto('https://www.hotels.com/go/turkey/best-places-shopping-antalya', {
        waitUntil: 'domcontentloaded',
      });

      await page.waitForSelector('.listicle-item-wrap .listicle-item');

      const activityData = await page.evaluate(() => {
        const activities = [];
        document.querySelectorAll('.listicle-item-wrap .listicle-item').forEach((element) => {
          const type = 'activities';
          const name = element.querySelector('.header-inner-wrap h2').textContent;
          const description = element.querySelector('.description-wrap p').textContent;
          const locationElement = element.querySelector('.map-button');
          const coordinatesString = locationElement ? locationElement.getAttribute('data-coord') : null;
          const location = coordinatesString ? coordinatesString.split(',').map(coord => Number(coord.trim())) : 0.0;
          const goodfor = 'shopping'; 

          const imageElement = element.querySelector('.resp-image');
          const image = imageElement ? imageElement.getAttribute('data-src-mobile') : null;

          const addElement = element.querySelector('.info-bullet-wrap p strong');

          if (addElement && addElement.textContent.includes('Location:')) {
            const address = addElement.nextSibling.textContent.trim();
            
            activities.push({ name, type, description, location, image, goodfor, address });
          }
          else{
            activities.push({ name, type, description, location, image, goodfor});
          
          }            });
        return activities;
      });

      console.log('Extracted activity data:', activityData);
      const savedActivities = await Activity.create(activityData);

      externalAPIInstance.activities = savedActivities;
      await externalAPIInstance.save();

      res.json({ message: 'Activity information scraped and saved successfully!', savedActivities });
    } finally {
      await browser.close();
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error', errorMessage: error.message });
  }
});

router.get('/eateries', async (req, res) => {
  try {
    const externalAPIInstance = new ExternalAPI();
    const browser = await puppeteer.launch({ headless: 'new', args: ['--disable-http2'] });
    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

    try {
      await page.goto('https://www.hotels.com/go/turkey/great-restaurants-antalya', {
        waitUntil: 'domcontentloaded',
      });

      await page.waitForSelector('.listicle-item-wrap .listicle-item');

      const eateryData = await page.evaluate(() => {
        const eateries = [];
        document.querySelectorAll('.listicle-item-wrap .listicle-item').forEach((element) => {
          const type = 'eateries';
          const name = element.querySelector('.header-inner-wrap h2').textContent;
          const description = element.querySelector('.description-wrap p').textContent;
          const locationElement = element.querySelector('.map-button');
          const coordinatesString = locationElement ? locationElement.getAttribute('data-coord') : null;
          const location = coordinatesString ? coordinatesString.split(',').map(coord => Number(coord.trim())) : null;

          const imageElement = element.querySelector('.resp-image');
          const image = imageElement ? imageElement.getAttribute('data-src-mobile') : null;

          const addElement = element.querySelector('.info-bullet-wrap p strong');

          if (addElement && addElement.textContent.includes('Location:')) {
            const address = addElement.nextSibling.textContent.trim();
            
            eateries.push({ name, type, description, location, image, address });
          }
          else{
            eateries.push({ name, type, description, location, image});
          
          }            });
        return eateries;
      });

      console.log('Extracted eatery data:', eateryData);
      const savedEateries = await Eatery.create(eateryData);

      externalAPIInstance.eateries = savedEateries;
      await externalAPIInstance.save();

      res.json({ message: 'Eatery information scraped and saved successfully!', savedEateries });
    } finally {
      await browser.close();
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error', errorMessage: error.message });
  }
});

////////////////////////////////////////////////////////////////////////////////////////

router.get('/getflights', async (req, res) => {
  try {
    const flights = await Flight.find();
    res.json(flights);
  } catch (error) {
    console.error('Error fetching flights:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/getstays', async (req, res) => {
  try {
    const stays = await Stay.find();
    res.json(stays);
  } catch (error) {
    console.error('Error fetching stays:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/geteateries', async (req, res) => {
  try {
    const eateries = await Eatery.find();
    res.json(eateries);
  } catch (error) {
    console.error('Error fetching eateries:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/getactivities', async (req, res) => {
  try {
    const activities = await Activity.find();
    res.json(activities);
  } catch (error) {
    console.error('Error fetching activities:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
