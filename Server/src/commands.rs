use console::style;
use simulate::Key;

pub fn execute(command:&str, ip: &str) -> bool {
     match command {
        "play" => {simulate::send(Key::MediaPlayPause).unwrap();},
        "media_next" => { simulate::send(Key::MediaNextTrack).unwrap() },
        "media_back" => { simulate::send(Key::MediaPreviousTrack).unwrap() },
        _ => {
            println!("command: {} from {} failed.", style(command).red(), style(&ip).green());
            return false;
        }
    }

    println!("command: {} from {}", style(command).yellow(), style(&ip).green());
    return true;
}

