const mongoose = require("mongoose");

const settingsSchema = mongoose.Schema({
  premium: { type: Boolean, required: true },
});

module.exports = {
  Settings: mongoose.model("Settings", settingsSchema),
};
