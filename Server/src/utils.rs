use console::style;
use local_ip_address::local_ip;
use rand::Rng;

pub fn gen_random_pin(i: i32) ->  String {
    let mut string: String = String::new();

    for _ in 0..i {
        string = string + rand::thread_rng().gen_range(0..10).to_string().as_str();
    }

    return string;
}

pub fn print_frame(debug: bool, pin: &String) {
    //nice launch box
    let ip = local_ip().unwrap().to_string();
    let mut frame = String::new();
    let mut space = String::new();

    for _ in 0..ip.len() + 19 + 5 {
        frame.push('-');
    }

    for _ in 0..ip.len() + 5 {
        space.push(' ');
    }
    let app_name = "FreeSDM".to_string();
    winconsole::console::set_title(&app_name).unwrap();

    println!("{}{}", frame.replace("-", " ").get(0..frame.len() / 2 - app_name.len() / 2).unwrap(), style(app_name).cyan().bold());

    println!("{}", frame);
    println!("| Connection Ip: {}:{} |",  style(ip).green(), style("8000").blue());

    if debug {
        println!("|{}{}|", style(" Debug MODE").red(), frame.replace("-", " ").get(0..frame.len() - 13).unwrap());
    } else {
        println!("| Login Pin: {}{}|", style(pin).cyan(), space);
    }

    println!("{}", frame);
}


pub fn print_box(string: String) {
    let mut space = String::new();
    for _ in 0..string.len() - 9 {
        space.push('-');
    }
    println!("\n{}", space);
    println!("{}", string);
    println!("{}\n", space);
}