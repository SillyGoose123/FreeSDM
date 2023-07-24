package de.sillycode.sdmfree;

import android.util.Log;

import java.io.IOException;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class Requests {
    private String url_base = "";
    private String auth_pin = "";

    private OkHttpClient okHttpClient = null;

    private OkHttpClient getClient(){
        if(okHttpClient == null)  okHttpClient = new OkHttpClient();
        return okHttpClient;
    }

    public boolean connect(String ip, String pin){
        //prepare
        OkHttpClient client = getClient();
        url_base = "http://" + ip + ":1234";
        Log.i("TAG", "connect: " + url_base);
        auth_pin = pin;

        // build request
        Request request = new Request.Builder()
                .url(url_base + "/connect")
                .addHeader("Authorization", auth_pin)
                .build();

        // send request
        try (Response response = client.newCall(request).execute()) {
            assert response.body() != null;
            if(response.body().string().contains("connected")) return true;
        } catch (IOException e) {
            Log.e("Err", e.toString());
        }
        return false;
    }

    public boolean sendCommand(String command){
        //prepare
        OkHttpClient client = getClient();

        // build request
        Request request = new Request.Builder()
                .url(url_base + "/connect")
                .addHeader("Authorization", auth_pin)
                .post(RequestBody.create(
                        MediaType.parse("text/x-markdown"), command))
                .build();

        // send request
        try (Response response = client.newCall(request).execute()) {
            assert response.body() != null;
            if(response.body().string().contains("true")) return true;
        } catch (IOException e) {
            Log.e("Err", e.toString());
        }
        return false;
    }
}
