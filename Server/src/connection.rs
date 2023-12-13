use console::style;
use text_io::read;
use crate::{CLIENTS, READING};
use crate::utils::ip_auth;

static mut RE_CON: Option<String> = None;

pub unsafe fn ask_connect (ip: &str) -> bool{
    if ip_auth(&ip.to_string()) {
        unsafe {
            if RE_CON == None {
                RE_CON = Some(ip.to_string());
            } else {
                RE_CON = Some(format!("{};{}", RE_CON.as_ref().unwrap(), &ip))
            }
        }

        return true;
    }
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
    let mut string = format!("Connected to {}", style(&ip).cyan());

    unsafe {
            if RE_CON.as_ref() != None {
                for i in RE_CON.as_ref().unwrap().split(";") {
                    if &i == &ip {
                        string = format!("Reconnected to {}", style(&ip).cyan());
                        break;
                    }
                }
        }
    }

    let mut space = String::new();
    for _ in 0..string.len() - 9 {
        space.push('-');
    }
    println!("\n{}", space);
    println!("{}", string);
    println!("{}\n", space);
}