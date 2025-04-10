// models/Task.js - Mongoose model for tasks
const mongoose = require("mongoose");

const TaskSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, default: "" },
  isDone: {
    type: Boolean,
    default: false,
  },


},
{ timestamps: true });

module.exports = mongoose.model("Task", TaskSchema);
