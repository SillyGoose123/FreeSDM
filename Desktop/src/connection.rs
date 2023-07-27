use console::style;
use text_io::read;
use crate::{CLIENTS, READING};

pub unsafe fn ask_connect (ip: &str) -> bool{
    if READING {
        return false;
    }
    READING = true;
    println!("Wanna connect to {}? [y,n] ", style(&ip).cyan());
    print!(">");
    let line: String = read!("{}\n");
    if line.to_lowercase().contains("y") {
        if CLIENTS != None {
            CLIENTS = Some(String::from(format!("{};{}", CLIENTS.as_ref().unwrap(), ip)));
        } else {
            CLIENTS = Some(String::from(ip));
        }
        READING = false;

        return true;
    } else {
        println!("Connection from {} denied.",style(&ip).red());
        READING = false;
        return false;
    }

}

pub fn print_box(ip: &str) {
    let string = format!("Connected to {}", style(&ip).cyan());
    let mut space = String::new();
    for _ in 0..string.len() - 9 {
        space.push('-');
    }
    println!("\n{}", space);
    println!("{}", string);
    println!("{}\n", space);
}