package de.sillycode.sdmfree;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class Dashboard extends AppCompatActivity {

    private Requests req = new Requests();

    private View.OnClickListener click = v -> {
        Button b = findViewById(v.getId());
        req.sendCommand(b.getText().toString().toLowerCase());
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);

        findViewById(R.id.playBtn).setOnClickListener(click);

    }
}