const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const path = require('path');
const app = express();

//'uploads' directory served as a static resource
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const loginRoutes = require('./routes/login');
const signupRoutes = require('./routes/signup');
const profilepageRoutes = require('./routes/profilepage');
const friendslistRoutes = require('./routes/friendslist');
const oneplanRoutes = require('./routes/oneplan');
const groupdayplansRoutes = require('./routes/groupdayplans');
const calendarviewRoutes = require('./routes/calendarview');
const calendareventsRoutes = require('./routes/calendarevents');
const externalapiRoutes = require('./routes/externalapi');
const notificationsRoutes = require('./routes/notifications');
const rtooshRoutes = require('./routes/rtoosh');

app.use(bodyParser.json());

mongoose.connect('mongodb+srv://danalena:123@cluster0.hxhvhfi.mongodb.net/', {
  
  useNewUrlParser: true,
  useUnifiedTopology: true,
  ssl: true, 

});

app.use('/api', signupRoutes);
app.use('/api', loginRoutes);
app.use('/api', profilepageRoutes);
app.use('/api', friendslistRoutes);
app.use('/api', oneplanRoutes);
app.use('/api', groupdayplansRoutes);
app.use('/api', calendarviewRoutes);
app.use('/api', calendareventsRoutes);
app.use('/api', externalapiRoutes);
app.use('/api', notificationsRoutes);
app.use('/api', rtooshRoutes);
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`server is running on port ${port}`);
});
