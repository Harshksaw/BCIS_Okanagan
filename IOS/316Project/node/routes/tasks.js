// routes/tasks.js - API routes for task operations
const express = require("express");
const router = express.Router();
const Task = require("../models/task");

// GET all tasks
router.get("/", async (req, res) => {
  try {
    const tasks = await Task.find().sort({ createdAt: -1 });
    const tasksWithTimestamps = tasks.map(task => ({
      ...task.toObject(),
      createdAt: task.createdAt.getTime(), // Convert `createdAt` to a timestamp
    }));
    res.status(200).json(tasksWithTimestamps);
  } catch (error) {
    console.error("Error fetching tasks:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});
// GET a single task by ID
router.get("/:id", async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ message: "Task not found" });
    }

    res.status(200).json(task);
  } catch (error) {
    console.error("Error fetching task:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// CREATE a new task
router.post("/", async (req, res) => {

  console.log("Request body:", req.body); // Log the request body
  try {
    const { title, description } = req.body;

    if (!title) {
      return res.status(400).json({ message: "Title is required" });
    }

    const newTask = new Task({
      title,
      description: description || "",
      isDone: false,
    });

    const savedTask = await newTask.save();
    res.status(201).json(savedTask);
  } catch (error) {
    console.error("Error creating task:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// UPDATE a task by ID
router.put("/:id", async (req, res) => {
  try {
    const { title, description, isDone } = req.body;
    const updatedTask = await Task.findByIdAndUpdate(
      req.params.id,
      { title, description, isDone },
      { new: true, runValidators: true }
    );

    if (!updatedTask) {
      return res.status(404).json({ message: "Task not found" });
    }

    res.status(200).json(updatedTask);
  } catch (error) {
    console.error("Error updating task:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// TOGGLE task completion status
router.patch("/:id/toggle", async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ message: "Task not found" });
    }

    task.isDone = !task.isDone;
    const updatedTask = await task.save();

    res.status(200).json(updatedTask);
  } catch (error) {
    console.error("Error toggling task status:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// DELETE a task by ID
router.delete("/:id", async (req, res) => {
  try {
    const deletedTask = await Task.findByIdAndDelete(req.params.id);

    if (!deletedTask) {
      return res.status(404).json({ message: "Task not found" });
    }

    res.status(200).json({ message: "Task deleted successfully" });
  } catch (error) {
    console.error("Error deleting task:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

module.exports = router;
