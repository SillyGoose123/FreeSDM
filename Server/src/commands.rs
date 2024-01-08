use simulate::Key;

pub fn execute(command:&str) -> bool {
    match command {
        "play" => simulate::send(Key::MediaPlayPause).unwrap(),
        "media_next" => simulate::send(Key::MediaNextTrack).unwrap(),
        "media_back" => simulate::send(Key::MediaPreviousTrack).unwrap(),
        "next" => simulate::send(Key::Right).unwrap(),
        "back" => simulate::send(Key::Left).unwrap(),
        _ => { return false }
    }

    return true;
}
