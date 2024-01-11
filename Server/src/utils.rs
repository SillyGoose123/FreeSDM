use std::io::Write;
use colored::Colorize;
use console::style;
use local_ip_address::local_ip;
use rand::Rng;

pub fn gen_random_pin(i: i32) -> String {
    let mut string: String = String::new();

    for _ in 0..i {
        string = string + rand::thread_rng().gen_range(0..10).to_string().as_str();
    }

    string
}

pub fn ask(message: String) -> bool {
    println!("{} ", message);
    // for ux (user experience)
    print!("> ");

    //clear the tests buffer so the print combined with the input above works
    std::io::stdout().flush().unwrap();

    //create a string for the input
    let mut input = String::new();

    //read the input
    std::io::stdin().read_line(&mut input).expect("Failed to read from stdin");

    input.trim() == "y"
}

pub fn print_frame(pin: &str, port: &str){
    //nice launch box
    let ip = local_ip().unwrap().to_string();
    let mut frame = String::new();


    frame.push_str(&*"-".repeat(ip.len() + 19 + 5));

    let app_name = "FreeSDM".to_string();
    winconsole::console::set_title(&app_name).unwrap();

    println!("{}{}", frame.replace("-", " ").get(0..frame.len() / 2 - app_name.len() / 2).unwrap(), style(app_name).cyan().bold());

    println!("{}", &frame);

    println!("| Connection Ip: {}:{} |",  style(&ip).green(), style(&port).blue());

    if &pin == &"0000" {
        println!("|{}{}|", style(" Debug MODE").red(), frame.replace("-", " ").get(0..frame.len() - 13).unwrap());
    } else {
        let mut space = String::new();

        space.push_str(" ".repeat( 19 + ip.len() + port.len() - (13 + pin.len())).as_str());
        println!("| Login Pin: {}{}|", style(&pin.cyan()), space);
    }

        println!("{}\n", frame);
}