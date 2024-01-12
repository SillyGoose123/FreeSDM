 use enigo::{Key, KeyboardControllable};

 struct Hotkey {
    keys: Vec<Key>,
    modifiers: Vec<Key>
}

pub fn send_hotkey(raw_hotkey: &String) -> String {
    // parse hotkey && create enigo instance
    let hotkey: Hotkey = parse(&raw_hotkey);
    let mut enigo = enigo::Enigo::new();

    //check if there is a key
    if hotkey.keys.len() == 0 {
        return "false\nNo key to click provided".to_string();
    }

    // Press all modifiers
    for modifier in &hotkey.modifiers {
        enigo.key_down(*modifier);
    }

    // click main key
    for key in &hotkey.keys {
        enigo.key_click(*key);
    }

    // Release all modifiers
    for modifier in &hotkey.modifiers {
        enigo.key_up(*modifier);
    }

    // Return true because no error
    "true".to_string()
}

fn parse(raw_hotkey: &String) -> Hotkey {
    // Split hotkey into keys and init variables for parsing
    let raw_keys = raw_hotkey.split("+").collect::<Vec<&str>>();
    let mut modifiers: Vec<Key> = Vec::new();
    let mut keys:Vec<Key> = Vec::new();

    // Parse keys
    for key_str in raw_keys {
        match key_str.trim() {
            "ctrl" => modifiers.push(Key::Control),
            "alt" => modifiers.push(Key::Alt),
            "shift" => modifiers.push(Key::Shift),
            "win" => modifiers.push(Key::LWin),
            "esc" => keys.push(Key::Escape),
            "tab" => keys.push(Key::Tab),
            "space" => keys.push(Key::Space),
            "enter" => keys.push(Key::Return),
            key => {
                for key_char in key.chars() {
                    keys.push(Key::Layout(key_char));
                }
            }
        }
    }

     Hotkey {
          keys,
          modifiers
     }
}