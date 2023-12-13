use std::io::Write;
use std::{panic};
use std::process::exit;
use crossterm::{
    event::{read, Event, KeyEvent},
    terminal::{enable_raw_mode}
};

use crossterm::event::KeyEventKind;
use crossterm::terminal::disable_raw_mode;

static mut PIN: Option<String> = None;
static mut URL: Option<String> = None;

#[tokio::main]
async fn main() {

    //custom error handling
    panic::set_hook(Box::new(|info| {
        //print the error
        eprintln!("Error: {}", &info.to_string().split("'").collect::<Vec<_>>()[1]);

        disable_raw_mode().unwrap();
        read_string("Enter to exit");

        // kill the program with exit code 1
        exit(1);
    }));

    let client = reqwest::Client::new();
    loop {
        //some connection establishment
        let url = format!("http://{}:8000", read_string("Connection ip?"));
        let pin = read_string("Connection Pin?");
        let res = client.get(format!("{}/connect", &url))
            .body("")
            .bearer_auth(&pin)
            .send()
            .await;


        if res.is_ok() && res.unwrap().text().await.unwrap().as_str() == "true" {

            let res = client.get(format!("{}/connected", &url))
                .body("")
                .bearer_auth(&pin)
                .send()
                .await;


            if res.is_ok() && res.unwrap().text().await.unwrap().as_str() == "true"  {
                unsafe {
                    PIN = Some(pin);
                    URL = Some(url);
                }
                break;
            }

        }
        println!("Failed");
    }

    //show that you are connected
    println!("---------");
    println!("Connected");
    println!("---------");
    

    get_key().await;
}

async fn get_key(){
    enable_raw_mode().unwrap();
    loop {
        match read().unwrap() {
            Event::Key(KeyEvent { code, modifiers, kind, .. }) => {
                if kind == KeyEventKind::Press {
                    let code = code;
                    send_key(format!("{:?}", code), format!("{:?}", modifiers)).await;
                }
            }
            _ => {}
        }
    }
}

async fn send_key(key: String, modifiers: String) {
    let  mut key = key;
    if key != "Enter" || key != "Backspace"{
        let temp = key.chars().nth(6);
        if temp == None {
            return;
        }
        key = temp.unwrap().to_string().to_lowercase();
    }

    let req_body;
    let modifiers = modifiers[13..modifiers.len()-1].to_string();
    if modifiers == "0x0" {
        println!("{}", &key);
        req_body = key;
    } else {
        println!("{} + {} ", &modifiers, &key);
        req_body = format!("{}\n{}\n{}", &modifiers, &key, &modifiers);
    }

    send_request(req_body, "key").await;
}

fn read_string(message: &str) -> String {
    println!("{} ", message);

    // for ux (user experience)
    print!("> ");

    //clear the tests buffer so the print combined with the input above works
    std::io::stdout().flush().unwrap();

    //create a string for the input
    let mut input = String::new();

    //read the input
    std::io::stdin().read_line(&mut input).expect("Failed to read from stdin");

    input.trim().to_string()
}

async fn send_request(req_body: String, route: &str) -> bool {
    unsafe {
        let res = reqwest::Client::new().post(format!("{}/{}", URL.as_ref().unwrap(), route))
            .body(req_body)
            .bearer_auth(PIN.as_ref().unwrap())
            .send()
            .await;


        if res.is_ok() {
            let text = res.unwrap().text().await.unwrap();
            if text == "true".to_string() {
                return true;
            }
            panic!("Request failed, because {}", text);
        }
        panic!("Request failed.");
    }
}
