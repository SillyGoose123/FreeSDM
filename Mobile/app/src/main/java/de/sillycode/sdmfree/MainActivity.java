package de.sillycode.sdmfree;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.TestLooperManager;
import android.text.format.Formatter;
import android.widget.EditText;
import android.widget.TextView;

import com.google.android.material.snackbar.Snackbar;

public class MainActivity extends AppCompatActivity {
    public static Requests req = new Requests();
    public static String err = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        WifiManager wifiManager = (WifiManager)this.getSystemService(WIFI_SERVICE);

        TextView ipView =  findViewById(R.id.showIP);
        ipView.setText("Your IP: " + Formatter.formatIpAddress(wifiManager.getConnectionInfo().getIpAddress()));

        if(!err.isEmpty()) {
            Snackbar.make(findViewById(R.id.connect), err, 800).show();
        }

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