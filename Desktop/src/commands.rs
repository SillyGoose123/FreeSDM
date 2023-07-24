pub fn execute(command:&str) -> bool {
    return match command {
        "play" => play(),
        _ => { false }
    }
}

fn play() -> bool{
    return true;
}