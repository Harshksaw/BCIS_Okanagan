package com.example.cosc326lab1;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import android.os.Bundle;
import android.widget.Button;
import android.widget.CheckBox;
import android.view.View;

public class SettingsActivity extends AppCompatActivity {

    private CheckBox darkModeCheckBox;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        darkModeCheckBox = findViewById(R.id.dark_mode_checkbox);
        Button backButton = findViewById(R.id.back_button);

        // Set initial checkbox state based on current night mode
        int currentNightMode = AppCompatDelegate.getDefaultNightMode();
        if (currentNightMode == AppCompatDelegate.MODE_NIGHT_YES) {
            darkModeCheckBox.setChecked(true);
        }

        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish(); // Close the SettingsActivity
            }
        });
    }


    public void myClickMethod(View view) {
        boolean isChecked = darkModeCheckBox.isChecked();
        if (isChecked) {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
        }
    }
}