mod commands;
mod utils;
mod connection;

//imports
use std::string::ToString;
use actix_web::{get, App, HttpServer, HttpRequest, Responder, post};
use console::style;

use commands::execute;
use utils::{gen_random_pin, ip_auth, check_auth, print_frame};
use crate::connection::{ask_connect, print_box};

//structs
static mut PIN: Option<String> = None;
static mut CLIENTS: Option<String> = None;
static mut READING: bool = false;
static mut IP_AUTH: bool = true;

#[get("/")]
async fn index() -> impl Responder {
    "Hello world!"
}

#[get("/connected")]
async fn connected(req: HttpRequest) -> impl Responder  {
    let ip = req.connection_info().peer_addr().unwrap().to_string();
    if check_auth(req.headers().get("Authorization")) && ip_auth(&ip){
        print_box(&ip);
        return "true";
    }
    return "Wrong auth.";
}

#[get("/connect")]
async fn connect(req: HttpRequest) -> impl Responder  {
    let authorized = check_auth(req.headers().get("Authorization"));
    unsafe {
        if authorized {
            return ask_connect(req.connection_info().peer_addr().unwrap()).to_string();
        } else {
            println!("{}", style(format!("Access with Pin \"{}\" failed.", req.headers().get("Authorization").unwrap().to_str().unwrap())).red());
            println!("Real Login Pin: {}", style(PIN.as_ref().unwrap()).cyan());

            return "false".to_string();
        }
    }

}

#[post("/command")]
async fn command(raw: actix_web::web::Bytes, req: HttpRequest) -> impl Responder  {
    let ip: String = req.connection_info().peer_addr().unwrap().to_string();
    if check_auth(req.headers().get("Authorization"))  && ip_auth(&ip.to_string()) {
        let command = std::str::from_utf8(&raw).unwrap();

        let worked: bool = execute(command);
        if worked {
            println!("command: {} from {}", style(command).yellow(), style(&ip).green());
            return "true";
        }
        println!("command: {} from {} failed.", style(command).red(), style(&ip).green());

        return "false";

    } else {
        println!("Command with wrong auth from IP: {}",  style(&ip).red());
        return "Wrong auth.";
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    unsafe {
        PIN = Some(gen_random_pin(5));

        let debug=  std::env::args().last().unwrap() == "Test".to_string();
        if debug {
            PIN = Some("0000".to_string());
        }

        print_frame(debug);

    }


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