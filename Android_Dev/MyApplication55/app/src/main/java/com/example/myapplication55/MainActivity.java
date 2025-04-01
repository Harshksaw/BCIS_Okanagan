package com.example.myapplication55;

import android.graphics.drawable.shapes.Shape;
import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class MainActivity extends AppCompatActivity {

    GridView gridView;
    List<Shape> shapes;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        gridView = findViewById(R.id.gridView);
        gridView.setNumColumns(2); // Optional if already in XML

        shapes = new ArrayList<>();
        shapes.add(new Shape("Sphere", R.drawable.sphere));
        shapes.add(new Shape("Cube", R.drawable.cube));
        shapes.add(new Shape("Cone", R.drawable.cone));
        shapes.add(new Shape("Cylinder", R.drawable.cylinder));

        ShapeAdapter adapter = new ShapeAdapter(this, shapes);
        gridView.setAdapter(adapter);

        gridView.setOnItemClickListener((parent, view, position, id) -> {
            String shapeName = shapes.get(position).getName();
            Intent intent = new Intent(MainActivity.this, SphereActivity.class);
            intent.putExtra("shape", shapeName);
            startActivity(intent);
        });
    }
}

