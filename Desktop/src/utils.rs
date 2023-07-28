use actix_web::http::header::HeaderValue;
use console::style;
use local_ip_address::local_ip;
use rand::Rng;
use crate::{CLIENTS, IP_AUTH, PIN};

pub fn gen_random_pin(i: i32) ->  String {
    let mut string: String = String::new();

    for _ in 0..i {
        string = string + rand::thread_rng().gen_range(0..10).to_string().as_str();
    }

    return string;

}

pub fn check_auth(token:Option<&HeaderValue> ) -> bool{
    let auth: &str = token.unwrap().to_str().unwrap().split(" ").last().unwrap();
    unsafe {
        return PIN.as_ref().map(|inner_str| inner_str.as_str() == auth).unwrap_or(false);
    }
}

pub fn ip_auth(ip: &String) -> bool {
    unsafe {
        if !IP_AUTH { return true;}
        if CLIENTS == None {
            return false;
        }
        let clients = CLIENTS.as_ref().unwrap().split(";");
        for cli in clients {
            if cli == ip.as_str() {
                return true;
            }
        }
    }

    return false;
}

pub unsafe fn print_frame(debug: bool){
    //nice launch box
    let ip = local_ip().unwrap().to_string();
    let mut frame = String::new();
    let mut space = String::new();

    for _ in 0..ip.len() + 19{
        frame.push('-');
    }

    for _ in 0..ip.len() {
        space.push(' ');
    }
    let app_name = format!("FreeSDM");
    winconsole::console::set_title(&app_name).unwrap();

    println!("{}{}", frame.replace("-", " ").get(0..frame.len() / 2 - app_name.len() / 2).unwrap(), style(app_name).cyan().bold());

    println!("{}", frame);
    println!("| Connection Ip: {} |",  style(ip).green());

    if debug {
        println!("|{}{}|", style(" Debug MODE").red(), frame.replace("-", " ").get(0..frame.len() - 13).unwrap());
    } else {
        println!("| Login Pin: {}{}|", style(PIN.as_ref().unwrap()).cyan(), space);
    }

    println!("{}", frame);
}