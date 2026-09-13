use macroquad::prelude::*;
use crate::game_state::{GameData, PopupState};
use crate::audio::AudioManager;

// Menggambar Tombol UI dengan Box Shadow Estetik (seperti pada Screenshot Main Menu)
pub fn draw_shadow_button(
    text: &str,
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    bg_color: Color,
    border_color: Color,
    text_color: Color,
) -> bool {
    let mouse_pos = mouse_position();
    let rect = Rect::new(x, y, w, h);
    let is_hovered = rect.contains(vec2(mouse_pos.0, mouse_pos.1));
    let clicked = is_hovered && is_mouse_button_pressed(MouseButton::Left);

    // Box Shadow
    draw_rectangle_rounded(
        Rect::new(x, y + 6.0, w, h),
        0.4,
        10,
        Color::new(0.0, 0.0, 0.0, 0.25),
    );

    // Main Button Body
    let draw_y = if clicked { y + 3.0 } else { y };
    draw_rectangle_rounded(
        Rect::new(x, draw_y, w, h),
        0.4,
        10,
        if is_hovered { bg_color } else { bg_color },
    );
    draw_rectangle_rounded_lines(
        Rect::new(x, draw_y, w, h),
        0.4,
        10,
        3.0,
        border_color,
    );

    // Button Text
    let font_size = 28.0;
    let text_dims = measure_text(text, None, font_size as u16, 1.0);
    draw_text(
        text,
        x + (w - text_dims.width) * 0.5,
        draw_y + (h + text_dims.height) * 0.5 - 2.0,
        font_size,
        text_color,
    );

    clicked
}

// Glassmorphism Header Card (seperti pada Screenshot In-Game)
pub fn draw_glass_header(game_data: &GameData, on_exit_click: impl FnOnce()) -> bool {
    let margin = 20.0;
    let card_w = screen_width() - (margin * 2.0);
    let card_h = 100.0;
    let card_y = 60.0;

    // Exit Button di atas kiri
    let exit_clicked = draw_shadow_button(
        "<- Exit",
        margin,
        15.0,
        80.0,
        36.0,
        Color::new(0.9, 0.9, 0.9, 0.9),
        WHITE,
        DARKGRAY,
    );
    if exit_clicked {
        on_exit_click();
    }

    // Badge Level
    let lvl_str = format!("Level {}", game_data.selected_level);
    let badge_w = 140.0;
    let badge_h = 40.0;
    let badge_x = (screen_width() - badge_w) * 0.5;
    draw_rectangle_rounded(
        Rect::new(badge_x, 15.0, badge_w, badge_h),
        0.5,
        8,
        WHITE,
    );
    draw_rectangle_rounded_lines(
        Rect::new(badge_x, 15.0, badge_w, badge_h),
        0.5,
        8,
        2.0,
        BLACK,
    );
    let lvl_dims = measure_text(&lvl_str, None, 22, 1.0);
    draw_text(
        &lvl_str,
        badge_x + (badge_w - lvl_dims.width) * 0.5,
        15.0 + (badge_h + lvl_dims.height) * 0.5 - 2.0,
        22.0,
        BLACK,
    );

    // Translucent Glassmorphism Panel Body
    draw_rectangle_rounded(
        Rect::new(margin, card_y, card_w, card_h),
        0.25,
        10,
        Color::new(1.0, 1.0, 1.0, 0.65),
    );
    draw_rectangle_rounded_lines(
        Rect::new(margin, card_y, card_w, card_h),
        0.25,
        10,
        2.0,
        Color::new(1.0, 1.0, 1.0, 0.9),
    );

    // Score & Target
    let target_txt = format!("Target: {} Score", game_data.target_score);
    draw_text(&target_txt, margin + 15.0, card_y + 30.0, 20.0, Color::new(0.2, 0.3, 0.7, 1.0));

    let score_txt = format!("{} Score", game_data.current_score);
    draw_text(&score_txt, margin + 15.0, card_y + 70.0, 32.0, BLACK);

    // Time Left Counter
    draw_text("Time Left:", card_w - 90.0, card_y + 30.0, 20.0, DARKGRAY);
    let time_sec = game_data.time_left.max(0.0) as u32;
    let time_str = format!("00:{:02}", time_sec);
    draw_text(&time_str, card_w - 95.0, card_y + 70.0, 30.0, BLACK);

    exit_clicked
}

// Dialog Modal Popups (Settings, Rules, End Game)
pub fn draw_popups(game_data: &mut GameData, audio: &mut AudioManager) {
    if game_data.active_popup == PopupState::None {
        return;
    }

    // Semi-transparent Overlay Background
    draw_rectangle(0.0, 0.0, screen_width(), screen_height(), Color::new(0.0, 0.0, 0.0, 0.5));

    let dialog_w = screen_width() * 0.85;
    let dialog_h = 320.0;
    let dialog_x = (screen_width() - dialog_w) * 0.5;
    let dialog_y = (screen_height() - dialog_h) * 0.5;

    draw_rectangle_rounded(
        Rect::new(dialog_x, dialog_y, dialog_w, dialog_h),
        0.15,
        10,
        WHITE,
    );
    draw_rectangle_rounded_lines(
        Rect::new(dialog_x, dialog_y, dialog_w, dialog_h),
        0.15,
        10,
        3.0,
        DARKGRAY,
    );

    match game_data.active_popup {
        PopupState::Settings => {
            draw_text("SETTINGS", dialog_x + 30.0, dialog_y + 50.0, 28.0, BLACK);

            let bgm_label = if game_data.settings.bgm_enabled { "BGM: ON" } else { "BGM: OFF" };
            if draw_shadow_button(bgm_label, dialog_x + 30.0, dialog_y + 90.0, dialog_w - 60.0, 45.0, LIGHTGRAY, GRAY, BLACK) {
                game_data.settings.bgm_enabled = !game_data.settings.bgm_enabled;
                if game_data.settings.bgm_enabled {
                    audio.play_bgm("assets/output.m4a", true);
                } else {
                    audio.stop_bgm();
                }
            }

            let sfx_label = if game_data.settings.sfx_enabled { "SFX: ON" } else { "SFX: OFF" };
            if draw_shadow_button(sfx_label, dialog_x + 30.0, dialog_y + 150.0, dialog_w - 60.0, 45.0, LIGHTGRAY, GRAY, BLACK) {
                game_data.settings.sfx_enabled = !game_data.settings.sfx_enabled;
            }

            if draw_shadow_button("CLOSE", dialog_x + 30.0, dialog_y + 230.0, dialog_w - 60.0, 45.0, Color::new(0.8, 0.3, 0.3, 1.0), RED, WHITE) {
                audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
                game_data.active_popup = PopupState::None;
            }
        }
        PopupState::Rules => {
            draw_text("CARA BERMAIN", dialog_x + 30.0, dialog_y + 50.0, 26.0, BLACK);
            draw_text("1. Ingat posisi kartu saat timer 3 detik.", dialog_x + 30.0, dialog_y + 100.0, 18.0, DARKGRAY);
            draw_text("2. Balik 2 kartu secara berurutan.", dialog_x + 30.0, dialog_y + 130.0, 18.0, DARKGRAY);
            draw_text("3. Cocokkan semua pasang sebelum waktu habis!", dialog_x + 30.0, dialog_y + 160.0, 18.0, DARKGRAY);

            if draw_shadow_button("MENGERTI", dialog_x + 30.0, dialog_y + 230.0, dialog_w - 60.0, 45.0, Color::new(0.4, 0.7, 0.3, 1.0), GREEN, WHITE) {
                audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
                game_data.active_popup = PopupState::None;
            }
        }
        PopupState::LevelCompleted => {
            draw_text("LEVEL COMPLETED!", dialog_x + 30.0, dialog_y + 60.0, 26.0, GOLD);
            let score_msg = format!("Skor Akhir: {}", game_data.current_score);
            draw_text(&score_msg, dialog_x + 30.0, dialog_y + 110.0, 20.0, BLACK);

            if draw_shadow_button("NEXT LEVEL", dialog_x + 30.0, dialog_y + 160.0, dialog_w - 60.0, 45.0, Color::new(0.4, 0.8, 0.3, 1.0), GREEN, WHITE) {
                audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
                if game_data.selected_level < 20 {
                    game_data.selected_level += 1;
                    if game_data.selected_level > game_data.unlocked_levels {
                        game_data.unlocked_levels = game_data.selected_level;
                    }
                }
                game_data.reset_round(game_data.selected_level);
            }
            if draw_shadow_button("EXIT MENU", dialog_x + 30.0, dialog_y + 225.0, dialog_w - 60.0, 45.0, LIGHTGRAY, GRAY, BLACK) {
                audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
                game_data.current_screen = crate::game_state::CurrentScreen::MainMenu;
                game_data.active_popup = PopupState::None;
            }
        }
        PopupState::GameOver => {
            draw_text("GAME OVER!", dialog_x + 30.0, dialog_y + 60.0, 28.0, RED);
            draw_text("Waktu habis! Coba lagi?", dialog_x + 30.0, dialog_y + 110.0, 20.0, DARKGRAY);

            if draw_shadow_button("TRY AGAIN", dialog_x + 30.0, dialog_y + 160.0, dialog_w - 60.0, 45.0, Color::new(0.9, 0.6, 0.2, 1.0), ORANGE, WHITE) {
                audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
                game_data.reset_round(game_data.selected_level);
            }
            if draw_shadow_button("EXIT MENU", dialog_x + 30.0, dialog_y + 225.0, dialog_w - 60.0, 45.0, LIGHTGRAY, GRAY, BLACK) {
                audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
                game_data.current_screen = crate::game_state::CurrentScreen::MainMenu;
                game_data.active_popup = PopupState::None;
            }
        }
    }
}
