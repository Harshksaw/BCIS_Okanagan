package com.example.myapplication

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.compose.rememberAsyncImagePainter
import com.example.myapplication.ui.theme.MyApplicationTheme
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.rememberPermissionState
import com.google.android.gms.location.*
import kotlin.math.*

class MainActivity : ComponentActivity() {
    private lateinit var fusedLocationClient: FusedLocationProviderClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        setContent {
            MyApplicationTheme {
                MainScreen(fusedLocationClient)
            }
        }
    }
}

@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun MainScreen(fusedLocationClient: FusedLocationProviderClient) {
    var imageUri by remember { mutableStateOf<Uri?>(null) }
    var locationText by remember { mutableStateOf("Location not fetched") }
    val context = LocalContext.current

    // Request Location Permission
    val locationPermissionState = rememberPermissionState(Manifest.permission.ACCESS_FINE_LOCATION)

    val pickImageLauncher = rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        if (uri != null) {
            imageUri = uri
        }
    }

    Scaffold(
        topBar = { TopAppBar(title = { Text("Permissions & File Picker") }) }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Image Preview
            imageUri?.let {
                Image(
                    painter = rememberAsyncImagePainter(it),
                    contentDescription = "Selected Image",
                    modifier = Modifier.size(200.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Pick Image Button
            Button(onClick = { pickImageLauncher.launch("image/*") }) {
                Text("Pick Image")
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Location Button
            Button(onClick = {
                if (locationPermissionState.hasPermission) {
                    getLocation(context, fusedLocationClient) { lat, lon ->
                        locationText = "Latitude: $lat\nLongitude: $lon"
                    }
                } else {
                    locationPermissionState.launchPermissionRequest()
                }
            }) {
                Text("Get Location")
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Display Location
            Text(locationText)

            Spacer(modifier = Modifier.height(16.dp))

            // Open App Settings if Permission Denied
            if (!locationPermissionState.hasPermission) {
                Button(onClick = {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    intent.data = Uri.parse("package:${context.packageName}")
                    context.startActivity(intent)
                }) {
                    Text("Grant Permission in Settings")
                }
            }
        }
    }
}

// Function to Fetch Location
private fun getLocation(
    context: android.content.Context,
    fusedLocationClient: FusedLocationProviderClient,
    onResult: (Double, Double) -> Unit
) {
    if (androidx.core.content.ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) != android.content.pm.PackageManager.PERMISSION_GRANTED
    ) {
        return
    }

    fusedLocationClient.lastLocation.addOnSuccessListener { location ->
        if (location != null) {
            onResult(location.latitude, location.longitude)
        }
    }
}
