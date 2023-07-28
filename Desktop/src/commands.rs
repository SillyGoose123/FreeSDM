use simulate::Key;

pub fn execute(command:&str) -> bool {
    return match command {
        "play" => play(),
        "media_next" => media_next(),
        "media_back" => media_back(),
        _ => { false }
    }
}

fn play() -> bool {
    simulate::send(Key::MediaPlayPause).unwrap();
    return true;
}


fn media_next() -> bool{
    simulate::send(Key::MediaNextTrack).unwrap();
    return true;
}

fn media_back() -> bool{
    simulate::send(Key::MediaPreviousTrack).unwrap();
    return true;
}

