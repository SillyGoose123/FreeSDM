mod commands;

#[macro_use]
extern crate rocket;

use std::error::Error;
use rand::Rng;
use std::string::ToString;
use rocket::{Data, Request};
use rocket::fairing::AdHoc;
use rocket::figment::providers::Env;
use rocket::response::stream::TextStream;
use rocket::tokio::io::AsyncReadExt;
use rocket::form::Form;
use rocket::response::content::RawText;

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
    unsafe {
        PIN = Some(gen_random_pin());
        println!("{}",&PIN.clone().unwrap() )
    }

    std::env::set_var("ROCKET_ADDRESS", "0.0.0.0");

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