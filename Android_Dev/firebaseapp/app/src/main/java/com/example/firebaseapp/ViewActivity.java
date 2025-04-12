package com.example.firebaseapp;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class ViewActivity extends AppCompatActivity {

    TextView nameText, emailText;
    DatabaseReference database;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view);

        nameText = findViewById(R.id.nameText);
        emailText = findViewById(R.id.emailText);

        // Reference to the "user" node in Realtime Database
        database = FirebaseDatabase.getInstance().getReference("user");

        // Read user data once
        database.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                User user = snapshot.getValue(User.class);
                if (user != null) {
                    nameText.setText("Name: " + user.name);
                    emailText.setText("Email: " + user.email);
                } else {
                    Toast.makeText(ViewActivity.this, "No user data found", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(ViewActivity.this, "Failed to read data", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
