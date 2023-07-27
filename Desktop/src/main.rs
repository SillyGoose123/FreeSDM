mod commands;

//imports
use rand::Rng;
use std::string::ToString;
use actix_web::{get, App, HttpServer, HttpRequest, Responder, post};
use actix_web::http::header::HeaderValue;
use local_ip_address::local_ip;
use colored::Colorize;
use text_io::read;

//structs
static mut PIN: Option<String> = None;
static mut CLIENTS: Option<String> = None;
static mut READING: bool = false;

#[get("/")]
async fn index() -> impl Responder {
    "Hello world!"
}

#[get("/connected")]
async fn connected(req: HttpRequest) -> impl Responder  {
    let ip = req.connection_info().peer_addr().unwrap().to_string();
    if check_auth(req.headers().get("Authorization")) && ip_auth(&ip){
        println!("Connected to {}", &ip);
        return "true";
    }
    return "Wrong auth.";
}

#[get("/connect")]
async fn connect(req: HttpRequest) -> impl Responder  {
    let authorized = check_auth(req.headers().get("Authorization"));
    let ip: String = req.connection_info().peer_addr().unwrap().to_string();
    unsafe {
        if authorized {
            if READING {
                return "false";
            }
            READING = true;
            println!("Wanna connect to {}? [Y,n] ", &ip);
            let line: String = read!("{}\n");
            if line.to_lowercase().contains("y") {
                unsafe {
                    if CLIENTS != None {
                        CLIENTS = Some(String::from(format!("{};{}", CLIENTS.as_ref().unwrap(), ip)));
                    } else {
                        CLIENTS = Some(String::from(&ip));
                    }
                    READING = false;
                }
                return "true";
            } else {
                println!("Connection from {} denied.", &ip);
                READING = false;
                return "false";
            }

        } else {
            println!("{}", format!("Access with Pin \"{}\" failed.", req.headers().get("Authorization").unwrap().to_str().unwrap()).red());
            unsafe {
                println!("Real Login Pin: {}", PIN.as_ref().unwrap().blue());
            }
            return "false";
        }
    }

}

#[post("/command")]
async fn command(raw: actix_web::web::Bytes, req: HttpRequest) -> impl Responder  {
    let ip: String = req.connection_info().peer_addr().unwrap().to_string();
    if check_auth(req.headers().get("Authorization"))  && ip_auth(&ip.to_string()) {
        return "true";
    } else {
        println!("Command with wrong auth from IP:{}",  &ip);
        return "Wrong auth.";
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    unsafe {
        PIN = Some(gen_random_pin(5));
    }

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

    println!("{}", frame);
    println!("| Connection Ip: {} |",  ip.green());

    unsafe {
        if std::env::args().last().unwrap() == "Test".to_string() {
            // Case of TEST
            PIN = Some("0000".to_string());
            println!("|{}{}|", " Debug MODE".red(), frame.replace("-", " ").get(0..frame.len() - 13).unwrap());
        } else {
            println!("| Login Pin: {} {}|", PIN.as_ref().unwrap().blue(), space);
        }

    }



    println!("{}", frame);

    HttpServer::new(|| {
        App::new()
            .service(index)
            .service(connect)
            .service(connected)
            .service(command)
    })
        .bind(("0.0.0.0", 8000))?
        .run()
        .await
}



fn gen_random_pin(i: i32) ->  String {
    let mut string: String = String::new();

    for _ in 0..i {
        string = string + rand::thread_rng().gen_range(0..10).to_string().as_str();
    }

    return string;

}

fn check_auth(token:Option<&HeaderValue> ) -> bool{
    let auth: &str = token.unwrap().to_str().unwrap().split(" ").last().unwrap();
    unsafe {
        return PIN.as_ref().map(|inner_str| inner_str.as_str() == auth).unwrap_or(false);
    }
}

fn ip_auth(ip: &String) -> bool {
    unsafe {
        let clients = CLIENTS.as_ref().unwrap().split(";");
        for cli in clients {
            if cli == ip.as_str() {
                return true;
            }
        }
    }

    return false;
}

