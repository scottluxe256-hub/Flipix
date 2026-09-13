mod game_state;
mod audio;
mod video;
mod ui;
mod screens;
mod ingame;

use macroquad::prelude::*;
use game_state::{CurrentScreen, GameData};
use audio::AudioManager;
use video::SplashVideoPlayer;
use screens::{draw_main_menu, draw_level_select};
use ingame::InGameManager;
use ui::draw_popups;

fn window_conf() -> Conf {
    Conf {
        window_title: "FlipFix".to_string(),
        window_width: 450,
        window_height: 1000, // Target Layar Potret 9:20
        high_dpi: true,
        fullscreen: false,
        ..Default::default()
    }
}

#[macroquad::main(window_conf)]
async fn main() {
    let mut game_data = GameData::new();
    let mut audio_mgr = AudioManager::new().unwrap_or_else(|_| {
        eprintln!("Audio Backend Warning: Failed to open output stream");
        // Dummy fallback jika audio hardware NDK terikat
        std::mem::forget(()); 
        panic!()
    });
    let mut splash_player = SplashVideoPlayer::new();
    let mut ingame_mgr = InGameManager::new(game_data.selected_level);

    // Load WebP Assets
    let bg_main = load_texture("assets/bg_android.webp").await.ok();
    let card_back = load_texture("assets/card_back.webp").await.ok();
    
    let mut card_fronts = Vec::new();
    for i in 1..=11 {
        let path = format!("assets/card_{}.webp", i);
        if let Ok(tex) = load_texture(&path).await {
            card_fronts.push(tex);
        }
    }

    // Play Main Menu BGM secara default
    audio_mgr.play_bgm("assets/output.m4a", game_data.settings.bgm_enabled);

    loop {
        let dt = get_frame_time();

        match game_data.current_screen {
            CurrentScreen::Splash => {
                splash_player.update(dt);
                splash_player.draw();
                if splash_player.is_finished {
                    game_data.current_screen = CurrentScreen::MainMenu;
                }
            }
            CurrentScreen::MainMenu => {
                draw_main_menu(&mut game_data, &mut audio_mgr, bg_main.as_ref());
            }
            CurrentScreen::LevelSelect => {
                draw_level_select(&mut game_data, &mut audio_mgr, get_time() as f32);
            }
            CurrentScreen::InGame => {
                clear_background(Color::new(0.85, 0.93, 1.0, 1.0));
                ingame_mgr.update(dt, &mut game_data, &mut audio_mgr);
                ingame_mgr.draw(&mut game_data, &mut audio_mgr, card_back.as_ref(), &card_fronts);
            }
        }

        // Overlay Modal Popups (Settings, Rules, End Game)
        draw_popups(&mut game_data, &mut audio_mgr);

        next_frame().await;
    }
}
