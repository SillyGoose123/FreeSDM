use actix_web::{HttpRequest, post, web};
use console::style;
use enigo::{Key, KeyboardControllable};
use crate::keys;

struct Hotkey {
    keys: Vec<Key>,
    modifiers: Vec<Key>,
}

//routes
#[post("/hotkey")]
async fn hotkey(raw: web::Bytes, req: HttpRequest) -> String {
    //get ip for logging
    let ip = req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost");

    //send the hotkey
    match String::from_utf8(raw.to_vec()) {
        Ok(string_hotkey) => {
            let result = keys::send_hotkey(&string_hotkey);
            if result.contains("true") {
                println!("Hotkey {} from {}.", style(&string_hotkey.replace("\n", ",")).green(), style(&ip).green());
            } else {
                println!("Hotkey {} from {} failed.", style(&string_hotkey).red(), style(&ip).green());
            }

            result
        },
        Err(_) => {
            println!("Hotkey failed from {}", req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost"));
            "false\ninvalid utf8 string".to_string()
        }
    }
}

#[post("/text")]
async fn text(raw: web::Bytes, req: HttpRequest) -> String {
    //get ip for logging
    let ip = req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost");

    //send the hotkey
    match String::from_utf8(raw.to_vec()) {
        Ok(text) => {
            let result = send_text(&text);
            if result.contains("true") {
                println!("Text \"{}\" from {}.", style(&text).green(), style(&ip).green());
            } else {
                println!("Text \"{}\" from {} failed.", style(&text).red(), style(&ip).green());
            }

            result
        }
        Err(_) => {
            println!("Text failed from {}", req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost"));
            "false\ninvalid utf8 string".to_string()
        }
    }
}

pub fn send_hotkey(raw_hotkey: &String) -> String {
    // parse hotkey && create enigo instance
    let mut enigo = enigo::Enigo::new();

    for raw in raw_hotkey.split("\n") {
        let parsed_hotkey: Hotkey = parse(raw);

        // Press all modifiers
        for modifier in &parsed_hotkey.modifiers {
            enigo.key_down(*modifier);
        }

        // click main key
        for key in &parsed_hotkey.keys {
            enigo.key_click(*key);
        }

        // Release all modifiers
        for modifier in &parsed_hotkey.modifiers {
            enigo.key_up(*modifier);
        }
    }

    // Return true because no error
    "true".to_string()
}

pub fn send_text(other_text: &String) -> String {
    // parse hotkey && create enigo instance
    let mut enigo = enigo::Enigo::new();

    enigo.key_sequence(other_text);

    // Return true because no error
    "true".to_string()
}

fn parse(raw_hotkey: &str) -> Hotkey {
    // Split hotkey into keys and init variables for parsing
    let raw_keys = raw_hotkey.split("+").collect::<Vec<&str>>();
    let mut modifiers: Vec<Key> = Vec::new();
    let mut keys: Vec<Key> = Vec::new();

    // Parse keys
    for key_str in raw_keys {
        match key_str.to_lowercase().trim() {
            "ctrl" => modifiers.push(Key::Control),
            "alt" => modifiers.push(Key::Alt),
            "shift" => modifiers.push(Key::Shift),
            "win" => modifiers.push(Key::LWin),
            "esc" => keys.push(Key::Escape),
            "tab" => keys.push(Key::Tab),
            "space" => keys.push(Key::Space),
            "enter" => keys.push(Key::Return),
            "f1" => keys.push(Key::F1),
            "f2" => keys.push(Key::F2),
            "f3" => keys.push(Key::F3),
            "f4" => keys.push(Key::F4),
            "f5" => keys.push(Key::F5),
            "f6" => keys.push(Key::F6),
            "f7" => keys.push(Key::F7),
            "f8" => keys.push(Key::F8),
            "f9" => keys.push(Key::F9),
            "f10" => keys.push(Key::F10),
            "f11" => keys.push(Key::F11),
            "f12" => keys.push(Key::F12),
            key => {
                for key_char in key.chars() {
                    keys.push(Key::Layout(key_char));
                }
            }
        }
    }

    Hotkey {
        keys,
        modifiers,
    }
}