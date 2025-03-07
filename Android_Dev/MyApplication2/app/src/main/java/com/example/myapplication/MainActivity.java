import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import android.Manifest;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.location.Location;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;
import androidx.exifinterface.media.ExifInterface;
import java.io.IOException;
import java.io.InputStream;

public class MainActivity extends AppCompatActivity {

    private floattargetLoc = new float[2];
    private FusedLocationProviderClient fusedLocationClient;
    private ImageView findImage;
    private Button updateBut;
    private TextView outView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Initialize UI elements
        findImage = findViewById(R.id.image_id);
        updateBut = findViewById(R.id.button_id);
        outView = findViewById(R.id.textview_id);

        // Initialize fusedLocationClient
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        // Set up file picker
        ActivityResultLauncher<PickVisualMediaRequest> pickMedia =
                registerForActivityResult(new ActivityResultContracts.PickVisualMedia(), uri -> {
                    if (uri != null) {
                        try {
                            InputStream stream = this.getContentResolver().openInputStream(uri);
                            Bitmap bitmap = BitmapFactory.decodeStream(stream);
                            findImage.setImageBitmap(bitmap);

                            ExifInterface exifInterface = new ExifInterface(stream);
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                exifInterface.getLatLong(targetLoc);
                            }
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                    } else {
                        Log.d("PhotoPicker", "No media selected");
                    }
                });

        // Set up onClickListeners
        findImage.setOnClickListener(view -> {
            pickMedia.launch(new PickVisualMediaRequest.Builder()
                    .setMediaType((ActivityResultContracts.PickVisualMedia.VisualMediaType)
                            ActivityResultContracts.PickVisualMedia.ImageOnly.INSTANCE)
                    .build());
        });

        updateBut.setOnClickListener(view -> getLoc());

        // Request location permissions
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String{Manifest.permission.ACCESS_FINE_LOCATION}, 8);
        }
    }

    // getLoc method
    public void getLoc() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) !=
                PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) !=
                        PackageManager.PERMISSION_GRANTED) {
            return;
        }

        fusedLocationClient.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, null)
                .addOnSuccessListener(this, location -> {
                    if (location != null) {
                        doublelastLoc = new double[2];
                        lastLoc[0] = location.getLatitude();
                        lastLoc[1] = location.getLongitude();

                        // Calculate distance using Haversine formula
                        final int radii = 6371;
                        double latDistance = Math.toRadians(lastLoc[0] - targetLoc[0]);
                        double lonDistance = Math.toRadians(lastLoc[1] - targetLoc[1]);
                        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2) +
                                Math.cos(Math.toRadians(targetLoc[0])) * Math.cos(Math.toRadians(lastLoc[0])) *
                                        Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
                        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                        double distance = radii * c;

                        // Display distance
                        outView.setText("The distance between you and the photo location is: " + String.valueOf(distance) + " km.");
                    }
                });
    }
}