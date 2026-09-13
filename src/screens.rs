use macroquad::prelude::*;
use crate::game_state::{CurrentScreen, GameData, PopupState};
use crate::audio::AudioManager;
use crate::ui::draw_shadow_button;

// Render Main Menu (Sesuai Screenshot Main Menu)
pub fn draw_main_menu(
    game_data: &mut GameData,
    audio: &mut AudioManager,
    bg_texture: Option<&Texture2D>,
) {
    if let Some(tex) = bg_texture {
        draw_texture_ex(
            tex,
            0.0,
            0.0,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(screen_width(), screen_height())),
                ..Default::default()
            },
        );
    } else {
        clear_background(SKYBLUE);
        draw_text("FlipFix", screen_width() * 0.3, screen_height() * 0.2, 50.0, WHITE);
    }

    // Top Bar Buttons (Hamburger Menu & Settings Gear)
    if draw_shadow_button("=", 20.0, 30.0, 45.0, 45.0, LIGHTGRAY, WHITE, BLACK) {
        audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
        game_data.active_popup = PopupState::Rules;
    }
    if draw_shadow_button("*", screen_width() - 65.0, 30.0, 45.0, 45.0, LIGHTGRAY, WHITE, BLACK) {
        audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
        game_data.active_popup = PopupState::Settings;
    }

    // Centered Main Action Buttons (Mulai & Keluar)
    let btn_w = screen_width() * 0.65;
    let btn_h = 55.0;
    let btn_x = (screen_width() - btn_w) * 0.5;
    let start_y = screen_height() * 0.65;

    if draw_shadow_button("MULAI", btn_x, start_y, btn_w, btn_h, Color::new(0.6, 0.8, 0.2, 1.0), WHITE, WHITE) {
        audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
        game_data.current_screen = CurrentScreen::LevelSelect;
    }

    if draw_shadow_button("KELUAR", btn_x, start_y + 75.0, btn_w, btn_h, Color::new(0.95, 0.6, 0.2, 1.0), WHITE, WHITE) {
        audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
        std::process::exit(0);
    }
}

// Render Level Selection (Animasi Procedural Aurora Soft Blue + Grid 20 Level)
pub fn draw_level_select(game_data: &mut GameData, audio: &mut AudioManager, time: f32) {
    // Procedural Aurora Background Sweep
    let shift = (time * 0.5).sin() * 0.1;
    let bg_color = Color::new(0.65 + shift, 0.85, 0.95 - shift, 1.0);
    clear_background(bg_color);

    // Header & Back Button
    if draw_shadow_button("<- Back", 20.0, 20.0, 80.0, 36.0, WHITE, GRAY, BLACK) {
        audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
        game_data.current_screen = CurrentScreen::MainMenu;
    }
    let title_dims = measure_text("SELECT LEVEL", None, 32, 1.0);
    draw_text("SELECT LEVEL", (screen_width() - title_dims.width) * 0.5, 50.0, 32.0, DARKBLUE);

    // 4x5 Level Grid (Total 20 Level)
    let cols = 4;
    let grid_margin = 30.0;
    let cell_size = (screen_width() - (grid_margin * 2.0) - (15.0 * 3.0)) / 4.0;
    let start_y = 120.0;

    for i in 0..20 {
        let level_num = i + 1;
        let col = i % cols;
        let row = i / cols;

        let x = grid_margin + (col as f32 * (cell_size + 15.0));
        let y = start_y + (row as f32 * (cell_size + 15.0));

        let is_unlocked = level_num <= game_data.unlocked_levels;
        let btn_color = if is_unlocked { WHITE } else { LIGHTGRAY };
        let text_str = if is_unlocked { format!("{}", level_num) } else { "L" };

        if draw_shadow_button(&text_str, x, y, cell_size, cell_size, btn_color, GRAY, BLACK) {
            if is_unlocked {
                audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
                audio.play_bgm("assets/ingame.m4a", game_data.settings.bgm_enabled);
                game_data.reset_round(level_num);
                game_data.current_screen = CurrentScreen::InGame;
            }
        }
    }
}
