package de.sillycode.sdmfree;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.google.android.material.snackbar.Snackbar;

import java.util.concurrent.atomic.AtomicBoolean;

public class Dashboard extends AppCompatActivity {

    private Requests req = MainActivity.req;

    private View.OnClickListener click = v -> {
        Button b = findViewById(v.getId());
        String command = b.getText().toString();
        new Thread(() -> {
            int commandCode = req.sendCommand(command.toLowerCase());
            if(commandCode == 0) Log.d("Normal", "Command Code: " + commandCode);
            else Log.e("Normal", "Command Code: " + commandCode);
            if(commandCode == 2){
                startActivity(new Intent(Dashboard.this, MainActivity.class));
                MainActivity.err = "Connection Lost.";
            } else if(commandCode == 1) {
                Snackbar.make(v, "Command " + command +" Failed." , 800).show();
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