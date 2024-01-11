use simulate::{Event, Key, press, release};

struct Hotkey {
    key: Key,
    modifiers: Vec<Key>
}

pub fn send_hotkey(raw_hotkey: String) -> String {
    let hotkey: Hotkey = parse(raw_hotkey);

    if(hotkey.key.is_none()) {
        return "false\n No key defined.".to_string();
    }

    for modifier in &hotkey.modifiers {
        match press(modifier) {
            Ok(_) => {},
            Err(_) => {
                return format!("false\n Failed to press modifier: {:?}.", modifier);
            }
        }
    }

    press(&hotkey.key).expect("Failed to press key");
    release(hotkey.key).expect("Failed to release key");

    for modifier in &hotkey.modifiers {
            release(*modifier).expect("Failed to press modifiers");
    }

    "true".to_string()
}

fn parse(raw_hotkey: String) -> Hotkey {
    let keys = raw_hotkey.split("+").collect::<Vec<&str>>();
    let mut modifiers: Vec<Key> = Vec::new();
    let mut key:Option<Key> = None
}