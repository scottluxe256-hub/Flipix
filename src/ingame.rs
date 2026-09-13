use macroquad::prelude::*;
use crate::game_state::{GameData, PopupState};
use crate::audio::AudioManager;
use crate::ui::draw_glass_header;

#[derive(Clone)]
pub struct MemoryCard {
    pub id: usize,
    pub asset_index: usize, // 1..=11 (sesuai card_1.webp sampai card_11.webp)
    pub is_flipped: bool,
    pub is_matched: bool,
}

pub struct InGameManager {
    pub cards: Vec<MemoryCard>,
    pub selected_indices: Vec<usize>,
    pub peek_timer: f32, // Timer hitung mundur 3, 2, 1
    pub mismatch_timer: f32,
}

impl InGameManager {
    pub fn new(level: usize) -> Self {
        let pair_count = (level + 1).min(8); // Pasang kartu bertambah sesuai level
        let mut card_pairs = Vec::new();

        for i in 0..pair_count {
            let asset_idx = (i % 11) + 1;
            card_pairs.push(asset_idx);
            card_pairs.push(asset_idx);
        }

        // Acak kartu
        use macroquad::rand::gen_range;
        for i in 0..card_pairs.len() {
            let target = gen_range(0, card_pairs.len());
            card_pairs.swap(i, target);
        }

        let cards = card_pairs
            .into_iter()
            .enumerate()
            .map(|(idx, asset_idx)| MemoryCard {
                id: idx,
                asset_index: asset_idx,
                is_flipped: true, // Terbuka saat fase intip 3 detik
                is_matched: false,
            })
            .collect();

        Self {
            cards,
            selected_indices: Vec::new(),
            peek_timer: 3.0,
            mismatch_timer: 0.0,
        }
    }

    pub fn update(&mut self, dt: f32, game_data: &mut GameData, audio: &mut AudioManager) {
        if game_data.active_popup != PopupState::None {
            return;
        }

        // 1. Fase Intip Kartu (3 Detik di Awal)
        if self.peek_timer > 0.0 {
            self.peek_timer -= dt;
            if self.peek_timer <= 0.0 {
                audio.play_sfx("assets/game-start.opus", game_data.settings.sfx_enabled);
                for card in &mut self.cards {
                    card.is_flipped = false;
                }
            }
            return;
        }

        // 2. Gameplay Timer Hitung Mundur
        game_data.time_left -= dt;
        if game_data.time_left <= 0.0 {
            audio.play_sfx("assets/game-over.opus", game_data.settings.sfx_enabled);
            game_data.active_popup = PopupState::GameOver;
            return;
        }

        // 3. Delay Pembalikan Kartu jika Tebakan Salah
        if self.mismatch_timer > 0.0 {
            self.mismatch_timer -= dt;
            if self.mismatch_timer <= 0.0 {
                for &idx in &self.selected_indices {
                    self.cards[idx].is_flipped = false;
                }
                self.selected_indices.clear();
            }
        }
    }

    pub fn draw(
        &mut self,
        game_data: &mut GameData,
        audio: &mut AudioManager,
        card_back: Option<&Texture2D>,
        card_fronts: &[Texture2D],
    ) {
        // Render Header Glassmorphism (Sesuai Screenshot In-Game)
        draw_glass_header(game_data, || {
            audio.play_sfx("assets/click.opus", game_data.settings.sfx_enabled);
            game_data.current_screen = crate::game_state::CurrentScreen::MainMenu;
        });

        // Countdown Text Peek Mode (3, 2, 1)
        if self.peek_timer > 0.0 {
            let count_txt = format!("{}", (self.peek_timer.ceil() as u32));
            draw_text(
                &count_txt,
                screen_width() * 0.5 - 20.0,
                190.0,
                50.0,
                ORANGE,
            );
        }

        // Grid Kartu Memory
        let cols = 2;
        let margin = 40.0;
        let start_y = 230.0;
        let card_w = (screen_width() - (margin * 3.0)) / 2.0;
        let card_h = card_w * 1.3;

        for (i, card) in self.cards.iter_mut().enumerate() {
            let col = i % cols;
            let row = i / cols;

            let x = margin + (col as f32 * (card_w + margin));
            let y = start_y + (row as f32 * (card_h + 20.0));

            let rect = Rect::new(x, y, card_w, card_h);
            let mouse_pos = mouse_position();

            // Handle Klik Kartu
            if self.peek_timer <= 0.0
                && self.mismatch_timer <= 0.0
                && self.selected_indices.len() < 2
                && !card.is_flipped
                && !card.is_matched
                && rect.contains(vec2(mouse_pos.0, mouse_pos.1))
                && is_mouse_button_pressed(MouseButton::Left)
            {
                card.is_flipped = true;
                audio.play_sfx("assets/flip.opus", game_data.settings.sfx_enabled);
                self.selected_indices.push(i);

                // Jika 2 kartu terbuka, cocokkan logika
                if self.selected_indices.len() == 2 {
                    let idx1 = self.selected_indices[0];
                    let idx2 = self.selected_indices[1];

                    if self.cards[idx1].asset_index == self.cards[idx2].asset_index {
                        // TEBAKAN BENAR
                        self.cards[idx1].is_matched = true;
                        self.cards[idx2].is_matched = true;
                        self.selected_indices.clear();
                        game_data.current_score += 50;
                        audio.play_sfx("assets/benar.opus", game_data.settings.sfx_enabled);

                        // Cek Menang
                        if self.cards.iter().all(|c| c.is_matched) {
                            audio.play_sfx("assets/level-completed.opus", game_data.settings.sfx_enabled);
                            game_data.active_popup = PopupState::LevelCompleted;
                        }
                    } else {
                        // TEBAKAN SALAH
                        audio.play_sfx("assets/salah.opus", game_data.settings.sfx_enabled);
                        self.mismatch_timer = 0.8;
                    }
                }
            }

            // Draw Card Frame & Texture
            draw_rectangle_rounded(rect, 0.15, 8, WHITE);
            draw_rectangle_rounded_lines(rect, 0.15, 8, 2.0, GRAY);

            if card.is_flipped {
                let tex_idx = card.asset_index.saturating_sub(1);
                if let Some(tex) = card_fronts.get(tex_idx) {
                    draw_texture_ex(
                        tex,
                        x + 10.0,
                        y + 10.0,
                        WHITE,
                        DrawTextureParams {
                            dest_size: Some(vec2(card_w - 20.0, card_h - 20.0)),
                            ..Default::default()
                        },
                    );
                }
            } else if let Some(tex_back) = card_back {
                draw_texture_ex(
                    tex_back,
                    x + 10.0,
                    y + 10.0,
                    WHITE,
                    DrawTextureParams {
                        dest_size: Some(vec2(card_w - 20.0, card_h - 20.0)),
                        ..Default::default()
                    },
                );
            } else {
                draw_text("FlipFix", x + 20.0, y + card_h * 0.5, 20.0, DARKGRAY);
            }
        }
    }
}
