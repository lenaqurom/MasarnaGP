const mongoose = require('mongoose');

const planSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: String,
    image: String,
    description: String,
  },
);

const Plan = mongoose.model('Plan', planSchema);

module.exports = Plan;
