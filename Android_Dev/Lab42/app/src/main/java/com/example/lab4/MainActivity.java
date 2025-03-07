package com.example.lab4;  // Ensure this matches AndroidManifest.xml



import android.Manifest;
import android.content.pm.PackageManager;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.PickVisualMediaRequest;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.exifinterface.media.ExifInterface;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;
import com.google.android.gms.tasks.OnSuccessListener;

import java.io.IOException;
import java.io.InputStream;

public class MainActivity extends AppCompatActivity {
    private FusedLocationProviderClient fusedLocationClient;
    private double[] lastLoc = {0.0, 0.0};
    private double[] imageLoc = {0.0, 0.0};

    private TextView distanceTextView;
    private ImageView imageView;
    private Button pickImageButton, getLocationButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        imageView = findViewById(R.id.imageView);
        pickImageButton = findViewById(R.id.pickImageButton);
        getLocationButton = findViewById(R.id.getLocationButton);
        distanceTextView = findViewById(R.id.distanceTextView);

        // Request location permissions
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
        }

        pickImageButton.setOnClickListener(v -> pickImage.launch("image/*"));
        getLocationButton.setOnClickListener(v -> getLoc());
    }

    private final ActivityResultLauncher<String> pickImage = registerForActivityResult(
            new ActivityResultContracts.GetContent(),
            uri -> {
                if (uri != null) {
                    imageView.setImageURI(uri);
                    extractExifData(uri);
                }
            }
    );

    private void extractExifData(Uri uri) {
        try {
            InputStream inputStream = getContentResolver().openInputStream(uri);
            ExifInterface exifInterface = new ExifInterface(inputStream);

            float[] latLong = new float[2];
            if (exifInterface.getLatLong(latLong)) {
                imageLoc[0] = latLong[0];
                imageLoc[1] = latLong[1];
                Toast.makeText(this, "Image GPS: " + imageLoc[0] + ", " + imageLoc[1], Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(this, "No GPS data found in image", Toast.LENGTH_LONG).show();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void getLoc() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }

        fusedLocationClient.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                null
        ).addOnSuccessListener(new OnSuccessListener<Location>() {
            @Override
            public void onSuccess(Location location) {
                if (location != null) {
                    lastLoc[0] = location.getLatitude();
                    lastLoc[1] = location.getLongitude();

                    double distance = calculateHaversine(lastLoc, imageLoc);
                    distanceTextView.setText("Distance: " + String.format("%.2f", distance) + " km");
                }
            }
        });
    }

    private double calculateHaversine(double[] loc1, double[] loc2) {
        final double R = 6371; // Earth radius in km
        double dLat = Math.toRadians(loc2[0] - loc1[0]);
        double dLon = Math.toRadians(loc2[1] - loc1[1]);
        double lat1 = Math.toRadians(loc1[0]);
        double lat2 = Math.toRadians(loc2[0]);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(lat1) * Math.cos(lat2) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c;
    }
}