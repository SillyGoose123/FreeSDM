package de.sillycode.sdmfree;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.google.android.material.snackbar.Snackbar;

import java.util.concurrent.atomic.AtomicBoolean;

public class Dashboard extends AppCompatActivity {

    private Requests req = MainActivity.req;

    private View.OnClickListener click = v -> {
        Button b = findViewById(v.getId());
        new Thread(() -> {
            int commandCode = req.sendCommand(b.getText().toString().toLowerCase());
            if(commandCode == 3){
                startActivity(new Intent(Dashboard.this, MainActivity.class));
                Snackbar.make(findViewById(R.id.connect), "Connection lost." , 800).show();
            } else if(commandCode == 2) {
                Snackbar.make(v, "Command " + b +" Failed." , 800).show();
            }
        }).start();

    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);

        findViewById(R.id.playBtn).setOnClickListener(click);

    }

    private void commandMsg(boolean successful, String b, View v){
        if (!successful) Snackbar.make(v, "Command " + b +" Failed " , 800).show();
    }

}