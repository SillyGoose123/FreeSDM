package de.sillycode.sdmfree;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.widget.EditText;

import com.google.android.material.snackbar.Snackbar;

public class MainActivity extends AppCompatActivity {
    public static Requests req = new Requests();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViewById(R.id.connect).setOnClickListener(v -> {
            EditText t = findViewById(R.id.ip);
            EditText e = findViewById(R.id.connect_pin);

            new Thread(() -> {
                if(!t.getText().toString().equals("") && !e.getText().toString().equals("") && req.connect(t.getText().toString(), e.getText().toString())) startActivity(new Intent(MainActivity.this, Dashboard.class));
                else {
                    Snackbar.make(findViewById(R.id.ip), "Connection failed.", 800).show();
                }
            }).start();

        });

        findViewById(R.id.clearBtn).setOnClickListener(v -> {
            EditText t = findViewById(R.id.ip);
            EditText e = findViewById(R.id.connect_pin);
            t.setText("");
            e.setText("");
        });

    }
}