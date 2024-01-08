mod commands;
mod utils;
mod keys;

//imports
use std::string::ToString;
use actix_web::{App, HttpServer, HttpRequest, guard, HttpResponse, post};
use actix_web::guard::{GuardContext};
use actix_web::web::{get};
use console::style;
use text_io::read;

use utils::{gen_random_pin, print_frame};
use crate::utils::print_box;

#[post("/command")]
async fn command(req: HttpRequest, body: String) -> HttpResponse {
    let ip = req.head().peer_addr.unwrap().ip().to_string();
    let command = body.trim().to_string();

    if !commands::execute(&command, &ip) {
        return HttpResponse::Ok().body("false");
    }

    return HttpResponse::Ok().body("true");
}




#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let mut pin = gen_random_pin(5);
    let mut ips = Vec::<String>::new();

    let debug = std::env::args().last().unwrap() == "Test".to_string();
    if debug {
        pin = "0000".to_string();
    }

    let mut ip = "";

    print_frame(debug, &pin);

    HttpServer::new(|| {
        App::new()
            .service(
                actix_web::web::scope("/")
                    .route("/", get().to(|| async { HttpResponse::Ok().body("Hello, world!") }))
                    .service(
                        actix_web::web::scope("/")
                            .guard(guard::fn_guard(|req: &GuardContext| {
                                ip = &req.head().peer_addr.unwrap().ip().to_string();
                                if &req.head().headers.get("Authorization").unwrap().to_str().unwrap().trim() != &&pin {
                                    println!("Command with wrong auth from IP: {}", style(&ip).red());
                                    return false;
                                }

                                return true;
                            }))
                            .route("/connect", get().to(|| async {
                                if ips.contains(&ip.to_string()) {
                                    print_box(format!("Reconnected to {}.", style(&ip).green()));
                                    return HttpResponse::Ok().body("true");
                                }

                                println!("Wanna connect to {}? [y,n] ", style(&ip).cyan());
                                print!(">");
                                let line: String = read!("{}\n");

                                if line.to_lowercase().contains("y") {
                                    return HttpResponse::Ok().body("true");
                                }

                                println!("Connection from {} denied.", style(&ip).red());
                                HttpResponse::Ok().body("false")
                            }))
                            .service(
                                actix_web::web::scope("/")
                                    .guard(guard::fn_guard(|req: &GuardContext| {
                                        let ip = &req.head().peer_addr.unwrap().ip().to_string();
                                        if !ips.contains(&ip) {
                                            println!("Command from not connected IP: {}", style(&ip).red());
                                            return false;
                                        }

                                        return true;
                                    }))
                            )
                            //get ip and body and gives it to commands::execute
                            .service(command)

                            //true while authorized
                            .route("/connected", get().to(|| async { HttpResponse::Ok().body("true") }))
                    ),
            )
    })
        .bind(("0.0.0.0", 8000))?
        .run()
        .await
}


