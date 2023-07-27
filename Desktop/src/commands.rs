use simulate::Key;

pub fn execute(command:&str) -> bool {
    return match command {
        "play" => play(),
        _ => { false }
    }
}

fn play() -> bool {
    simulate::send(Key::MediaPlayPause).unwrap();
    return false;
}