// no snake case warn for bin target
#![allow(non_snake_case)]

use crate::keys::{hotkey, text};
use actix_web::web::{get, post};
use actix_web::{App, get, HttpRequest, HttpServer, web};
use actix_web::guard::fn_guard;
use actix_web::http::header;

use colored::Colorize;
use console::style;
use crate::utils::{ask, print_frame};

mod utils;
mod keys;

#[get("/connect")]
async fn connect(req: HttpRequest) -> String {
    //get ip and replace 127.0.0.1 with localhost
    let ip = req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost");

    //get the ips from env var and check if the ip is in there
    let env_ips = std::env::var("Ips").unwrap_or("".to_string());
    let mut ips: Vec<&str> = if env_ips.is_empty() {
        Vec::new()
    } else {
        env_ips.split(",").collect::<Vec<&str>>()
    };

    if ips.contains(&&ip.as_str()) {
        //if the ip is in there, remove it and set the env var
        println!("Reconnected to {}\n", style(&ip).cyan());
        return "true \nreconnected".to_string();
    }

    //ask if the user wants to connect to the new ip
    if !ask(format!("Connect to {}?", style(&ip).cyan())) {
        return "false".to_string();
    }

    //apply the new ip to the env var
    ips.push(&ip);
    std::env::set_var("Ips", ips.join(","));

    //say the user and the client that the connection was successful
    println!("Connected to {}\n", style(&ip).green());
    "true".to_string()
}

fn unauthorized(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("")
            //for error
            .route("/connect", get().to(|| async {
                "Unauthorized"
            }))
            .route("/connected", get().to(|| async {
                "Unauthorized"
            }))
            .route("/hotkey", post().to(|| async {
                "Unauthorized"
            }))
            .route("/text", post().to(|| async {
                "Unauthorized"
            }))
    );
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    //get args
    let args = std::env::args().collect::<Vec<String>>();

    //check for debug arg else generate random pin and do the env stuff
    let pin = if args.contains(&"debug".to_string()) {
        std::env::set_var("Ips", "localhost");
        "0000".to_string()
    } else {
        std::env::set_var("Ips", "");
        utils::gen_random_pin(6)
    };
    std::env::set_var("Pin", &pin.as_str());

    //check for port arg else use 8000
    let port: u16 = match args.iter().filter(|&x| x.contains("port"))
        .collect::<Vec<&String>>().get(0)
        .unwrap_or(&&"8000".to_string())
        .replace("port=", "")
        .replace("-", "").parse() {
            Ok(port) => port,
            Err(_) => {
                println!("Port must be a number");
                std::process::exit(1);
            }
    };

    //check if port is free
    if !portpicker::is_free(port) {
        println!("{}{}\n{0}{}", " ".repeat((port.to_string().len() + 69 - 7)  / 2) , style("FreeSDM").cyan().bold(), "-".repeat(7));
        println!("Port {} is already in use. Change port with the program arg [{}].", style(port).red(), style("--port=").color256(8));
        ask("Press a key to exit:".to_string());
        std::process::exit(1);
    }

    //show pin and ip in frame
    print_frame(&pin, port.to_string().as_str());

    //start server
    HttpServer::new(move || {
        App::new()
            .route("/", web::get().to(|| async { "Hello, world!" }))
            .route("/version", get().to(|| async {
                env!("CARGO_PKG_VERSION")
            }))
            .service(
                web::scope("")
                    .guard(fn_guard(|req| {
                        match req.head().headers.get(header::AUTHORIZATION) {
                            None => false,
                            Some(header) => {
                                let pin = std::env::var("Pin").unwrap_or("0000".to_string());
                                let mut header = header.to_str().unwrap_or("").to_string();
                                header = header.replace("Bearer", "");
                                header = header.replace("bearer", "");
                                header = header.trim().to_string();
                                let auth = header == pin;

                                if req.head().uri.path() == "/connect" && !auth {
                                    println!("{}", style(format!("Access with Pin {} failed.", header.red())));
                                    println!("Real Login Pin: {}\n", style(pin).cyan());
                                }

                                auth
                            }
                        }
                    }))
                    .service(connect)

                    .service(
                        web::scope("")
                            .guard(fn_guard(|req| {
                                match req.head().peer_addr {
                                    None => false,
                                    Some(peer_addr) => {
                                        //get ip and replace localhost
                                        let ip = peer_addr.ip().to_string().replace("127.0.0.1", "localhost");

                                        //get the ips from env var and check if the ip is in there
                                        let env_ips = std::env::var("Ips").unwrap_or("".to_string());
                                        let ips = &mut env_ips.split(",").collect::<Vec<&str>>();
                                        ips.contains(&&ip.as_str())
                                    }
                                }

                            }))
                            .route("/connected", web::get().to(|| async {
                                "true"
                            }))
                            .service(hotkey)
                            .service(text)
                    )

                    .configure(unauthorized)
            )

            .configure(unauthorized)
    })
        .bind(("0.0.0.0", port))?
        .run()
        .await
}