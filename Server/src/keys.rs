pub fn send_string(command:&str) -> bool {
    println!("{}", command);

    match simulate::type_str("Hello, world!") {
        Ok(_) => true,
        Err(_) => false
    }
}