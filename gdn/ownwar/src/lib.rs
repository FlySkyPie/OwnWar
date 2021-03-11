#![feature(map_into_keys_values)]
#![feature(destructuring_assignment)]
#![feature(step_trait)]

// Shuttt the fuckkkkkk upppp please
#![cfg(debug_assertions)]
#![allow(dead_code)]

mod block;
mod editor;
mod util;
mod vehicle;

use gdnative::prelude::*;

// Function that registers all exposed classes to Godot
fn init(handle: InitHandle) {
	godot_print!("Initializing OwnWar native library");
	vehicle::init(handle);
	block::init(handle);
}

// Macro that creates the entry-points of the dynamic library.
godot_init!(init);
