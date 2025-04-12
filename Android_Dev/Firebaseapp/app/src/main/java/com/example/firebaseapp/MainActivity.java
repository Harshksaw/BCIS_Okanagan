package com.example.firebaseapp;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

    EditText nameInput, emailInput;
    DatabaseReference database;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        nameInput = findViewById(R.id.nameInput);
        emailInput = findViewById(R.id.emailInput);
        Button saveBtn = findViewById(R.id.saveBtn);
        Button viewBtn = findViewById(R.id.viewBtn);

        database = FirebaseDatabase.getInstance().getReference("user");

        saveBtn.setOnClickListener(v -> {
            String name = nameInput.getText().toString();
            String email = emailInput.getText().toString();

            User user = new User(name, email);
            database.setValue(user).addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    Toast.makeText(this, "Data Saved", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(this, "Save Failed", Toast.LENGTH_SHORT).show();
                }
            });
        });

        viewBtn.setOnClickListener(v -> startActivity(new Intent(MainActivity.this, ViewActivity.class)));
    }
}
