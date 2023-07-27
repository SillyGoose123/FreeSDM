package de.sillycode.sdmfree;

import android.util.Log;
import android.view.View;

import com.google.android.material.snackbar.Snackbar;

import java.io.IOException;
import java.net.SocketTimeoutException;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class Requests {
    private String url_base = "";
    private String auth_pin = "";

    private OkHttpClient okHttpClient = null;

    private OkHttpClient getClient(){
        if(okHttpClient == null)  okHttpClient = new OkHttpClient().newBuilder().build();
        return okHttpClient;
    }

    public boolean connect(String ip, String pin){
        //prepare
        OkHttpClient client = getClient();
        url_base = "http://" + ip + ":8000";
        Log.i("TAG", "connect: " + url_base + "/connect");
        auth_pin = pin;

        // build request
        Request request = new Request.Builder()
                .url(url_base + "/connect")
                .addHeader("Authorization", auth_pin)
                .build();

        // send request
        try (Response response = client.newCall(request).execute()) {
            ResponseBody res = response.body();
            assert res != null;
            String resS = new String(res.bytes(), StandardCharsets.UTF_8);
            Log.d("Data", "connect-content: " + resS);

            return resS.contains("true");
        } catch (IOException e) {
            Log.e("Err", e.toString() + "<= Test" + e.getStackTrace().toString());
        }
        return false;
    }

    public int sendCommand(String command){
        //prepare
        OkHttpClient client = getClient();
        Log.d("Debug", "sendCommand: " + command);
        // build request
        Request request = new Request.Builder()
                .url(url_base + "/command")
                .addHeader("Authorization", auth_pin)
                .post(RequestBody.create(command,
                        MediaType.parse("text/plain")))
                .build();

        // send request
        try (Response response = client.newCall(request).execute()) {
            ResponseBody res = response.body();
            assert res != null;
            String resS = new String(res.bytes(), StandardCharsets.UTF_8);
            if(resS.equals("true")) return 0;
            else if (resS.equals("Wrong auth.")) return 2;
        } catch (Exception e) {
            if (e.toString().contains("java.net.SocketTimeoutException")) return 2;
            Log.e("Err", e.toString());
        }

        return 1;
    }

}
