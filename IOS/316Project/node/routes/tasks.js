// routes/tasks.js - API routes for task operations
const express = require("express");
const router = express.Router();
const Task = require("../models/task");
const mongoose = require("mongoose");

// GET tasks for a specific user
router.get("/", async (req, res) => {
  try {
    const { userId } = req.query;
    
    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    // Validate userId format
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: "Invalid userId format" });
    }
    
    const tasks = await Task.find({ userId }).sort({ createdAt: -1 });
    console.log("🚀 ~ router.get ~ tasks:", tasks)
    res.status(200).json(tasks);
  } catch (error) {
    console.error("Error fetching tasks:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// GET a single task by ID (with user verification)
router.get("/:id", async (req, res) => {
  try {
    const { userId } = req.query;
    
    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const task = await Task.findOne({ 
      _id: req.params.id,
      userId
    });

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
  try {
    const { title, description, userId, dueDate, priority } = req.body;

    if (!title) {
      return res.status(400).json({ message: "Title is required" });
    }

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    // Validate userId format
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: "Invalid userId format" });
    }

    const newTask = new Task({
      title,
      description: description || "",
      isDone: false,
      userId,
      dueDate: dueDate || null,
      priority: priority || "Medium"
    });

    const savedTask = await newTask.save();
    res.status(201).json(savedTask);
  } catch (error) {
    console.error("Error creating task:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// UPDATE a task by ID (with user verification)
router.put("/:id", async (req, res) => {
  try {
    const { title, description, isDone, dueDate, priority, userId } = req.body;
    
    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const updatedTask = await Task.findOneAndUpdate(
      { _id: req.params.id, userId },
      { title, description, isDone, dueDate, priority },
      { new: true, runValidators: true }
    );

    if (!updatedTask) {
      return res.status(404).json({ message: "Task not found or not authorized" });
    }

    res.status(200).json(updatedTask);
  } catch (error) {
    console.error("Error updating task:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// TOGGLE task completion status (with user verification)
router.patch("/:id/toggle", async (req, res) => {
  try {
    const { userId } = req.body;
    
    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const task = await Task.findOne({ _id: req.params.id, userId });

    if (!task) {
      return res.status(404).json({ message: "Task not found or not authorized" });
    }

    task.isDone = !task.isDone;
    const updatedTask = await task.save();

    res.status(200).json(updatedTask);
  } catch (error) {
    console.error("Error toggling task status:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// DELETE a task by ID (with user verification)
router.delete("/:id", async (req, res) => {
  try {
    const { userId } = req.query;
    
    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const deletedTask = await Task.findOneAndDelete({ 
      _id: req.params.id,
      userId 
    });

    if (!deletedTask) {
      return res.status(404).json({ message: "Task not found or not authorized" });
    }

    res.status(200).json({ message: "Task deleted successfully" });
  } catch (error) {
    console.error("Error deleting task:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

module.exports = router;