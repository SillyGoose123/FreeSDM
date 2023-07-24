#![no_main]

use rocket::{get};

#[get("/")]
fn hello() -> String {
    String::from("Hello from rusts")
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![hello])
}