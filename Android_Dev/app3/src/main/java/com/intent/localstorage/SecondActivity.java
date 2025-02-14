package com.intent.localstorage;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import java.io.*;
import java.util.Random;

public class SecondActivity extends AppCompatActivity {
    private TextView tvMessage, tvRandomNumber, tvPreviousResult, tvSavedResult;
    private Button btnSave;
    private int randomNumber;
    private static final String FILE_NAME = "random_number.txt";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_second);

        tvMessage = findViewById(R.id.tvMessage);
        tvRandomNumber = findViewById(R.id.tvRandomNumber);
        tvPreviousResult = findViewById(R.id.tvPreviousResult);
        tvSavedResult = findViewById(R.id.tvSavedResult);
        btnSave = findViewById(R.id.btnSave);

        // Get user's name from Intent
        String userName = getIntent().getStringExtra("USER_NAME");
        tvMessage.setText(userName + ", Your lucky number is:");

        // Generate a random number (1-6)
        randomNumber = new Random().nextInt(6) + 1;
        tvRandomNumber.setText(String.valueOf(randomNumber));

        // Show previous result if available
        String previousResult = readFromFile();
        if (previousResult == null) {
            tvSavedResult.setText("No previous data");
        } else {
            tvSavedResult.setText(userName + ": " + previousResult);
        }

        // Save result on button click
        btnSave.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveToFile(randomNumber);
            }
        });
    }

    private void saveToFile(int number) {
        try (FileOutputStream fos = openFileOutput(FILE_NAME, Context.MODE_PRIVATE)) {
            fos.write(String.valueOf(number).getBytes());
            Toast.makeText(this, "Saved Successfully!", Toast.LENGTH_SHORT).show();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String readFromFile() {
        try (FileInputStream fis = openFileInput(FILE_NAME);
             BufferedReader reader = new BufferedReader(new InputStreamReader(fis))) {
            return reader.readLine();
        } catch (IOException e) {
            return null;
        }
    }
}
