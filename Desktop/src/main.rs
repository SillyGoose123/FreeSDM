mod commands;

//imports
#[macro_use]
extern crate rocket;

use std::error::Error;
use rand::Rng;
use std::string::ToString;
use rocket::http::hyper::body::Buf;
use rocket::request::FromRequest;
use local_ip_address::local_ip;


//structs
static mut PIN: Option<String> = None;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[get("/connect")]
fn connect() -> String {

    String::from("true")
}

#[post("/command", format = "text", data="<raw>")]
fn command(raw: String) -> String {
    commands::execute(raw.as_str()).to_string()
}

#[launch]
fn rocket() -> _ {
    println!("Connection Ip: {:?}",  local_ip().unwrap());
    unsafe {
        PIN = Some(gen_random_pin());
        println!("Login Pin: {}", &PIN.clone().unwrap())
    }

    rocket::build()
        .mount("/", routes![index, connect,command])
}


fn gen_random_pin() ->  String {
    let mut string: String = String::new();

    for _ in 0..4 {
        string = string + rand::thread_rng().gen_range(0..10).to_string().as_str();
    }

    return string;

}