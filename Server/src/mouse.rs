use actix_web::{HttpRequest, post};
use actix_web::web::Bytes;
use colored::Colorize;
use console::style;
use enigo::{Enigo, MouseButton, MouseControllable};

//scroll route
#[post("/scroll")]
pub(crate) async fn scroll(raw: Bytes, req: HttpRequest) -> String {
    //get ip for logging
    let ip = req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost");

    //init enigo for mouse
    let mut enigo = Enigo::new();

    //decode the raw bytes to a string
    match String::from_utf8(raw.to_vec()) {
        Ok(body) => {
            match body.parse::<i32>() {
                Ok(amount) => {
                    //scroll
                    enigo.mouse_scroll_y(amount);
                    println!("Scrolled {} from {}.", style(&amount).green(), &ip.green());
                    "true".to_string()
                },
                Err(_) => {
                    println!("Scroll failed from {}", &ip);
                    "false\ncannot parse to int".to_string()
                }
            }
        }
        Err(_) => {
            println!("Text failed from {}", &ip);
            "false\ninvalid utf8 string".to_string()
        }
    }
}

//click route
#[post("/click")]
async fn click(raw: Bytes, req: HttpRequest) -> String {
    //get ip for logging
    let ip = req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost");

    match String::from_utf8(raw.to_vec()) {
        Ok(body) => {
            send_click(body, &ip)
        }
        Err(_) => {
            println!("Text {} from {}","failed".red(), &ip.green());
            "false\ninvalid utf8 string".to_string()
        }
    }
}

fn send_click(body: String, ip: &String) -> String {
    //parse and send the click
    let mut enigo = Enigo::new();
    match body.as_str() {
        "left" => enigo.mouse_click(MouseButton::Left),
        "right" => enigo.mouse_click(MouseButton::Right),
        "middle" => enigo.mouse_click(MouseButton::Middle),
        _ => {
            println!("Click {} from {}", "failed".red() , &ip.green());
            return "false\ninvalid click type".to_string();
        }
    };

    println!("Click {} from {}", &body.green() , &ip.green());
    "true".to_string()
}

#[post("/mouse")]
async fn move_mouse(raw: Bytes, req: HttpRequest) -> String {
    //get ip for logging
    let ip = req.connection_info().peer_addr().unwrap_or("").to_string().replace("127.0.0.1", "localhost");

    match String::from_utf8(raw.to_vec()) {
        Ok(body) => {
            let split = body.split(":").collect::<Vec<&str>>();

            if split.len() != 2 {
                println!("Mouse {} from {}","failed".red(), &ip.green());
                return "false\ninvalid mouse string".to_string();
            }

            let x = split[1].trim().parse::<i32>();

            return match x {
                Ok(x) => {
                    let mut enigo = Enigo::new();
                    match split[0].trim().to_lowercase().as_str() {
                        "up" => {
                            enigo.mouse_move_relative(0, -x);
                            println!("Mouse {} from {}", &body.green() , &ip.green());
                            "true".to_string()
                        },
                        "down" => {
                            enigo.mouse_move_relative(0, x);
                            println!("Mouse {} from {}", &body.green() , &ip.green());
                            "true".to_string()
                        },
                        "left" => {
                            enigo.mouse_move_relative(-x, 0);
                            println!("Mouse {} from {}", &body.green() , &ip.green());
                            "true".to_string()
                        },
                        "right" => {
                            enigo.mouse_move_relative(x, 0);
                            println!("Mouse {} from {}", &body.green() , &ip.green());
                            "true".to_string()
                        },
                        _ => {
                            println!("Mouse {} from {}","failed".red(), &ip.green());
                            "false\ninvalid mouse string".to_string()
                        }
                    }
                },
                Err(_) => {
                    println!("Mouse {} from {}","failed".red(), &ip.green());
                    "false\ncouldn't parse int.".to_string()
                }
            }

        }
        Err(_) => {
            println!("Mouse {} from {}","failed".red(), &ip.green());
            "false\ninvalid utf8 string".to_string()
        }
    }
}

