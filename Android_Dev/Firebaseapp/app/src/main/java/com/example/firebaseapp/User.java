package com.example.firebaseapp;

public class User {
    public String name;
    public String email;

    public User() {
        // Default constructor required for Firebase
    }

    public User(String name, String email) {
        this.name = name;
        this.email = email;
    }
}
