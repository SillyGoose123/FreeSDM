
pub fn send_key(command:&str) -> bool {
    println!("{}", command);
    let input: Vec<&str> = command.split("\n").collect();

    println!("input : {}", input[0]);

    let pressed = true;

    pressed
}