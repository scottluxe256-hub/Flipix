use dav1d::Decoder;
use macroquad::prelude::*;

pub struct SplashVideoPlayer {
    decoder: Decoder,
    texture: Option<Texture2D>,
    pub elapsed_time: f32,
    pub duration: f32,
    pub is_finished: bool,
}

impl SplashVideoPlayer {
    pub fn new() -> Self {
        let decoder = Decoder::new().expect("Gagal membuat dekoder Dav1d AV1");
        Self {
            decoder,
            texture: None,
            elapsed_time: 0.0,
            duration: 7.0, // Video splash 7 detik
            is_finished: false,
        }
    }

    pub fn update(&mut self, dt: f32) {
        self.elapsed_time += dt;
        if self.elapsed_time >= self.duration {
            self.is_finished = true;
        }
    }

    pub fn draw(&mut self) {
        // Render dummy/video frame surface
        if let Some(ref tex) = self.texture {
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
            // Fallback animasi visual saat dekoder memuat stream video
            clear_background(BLACK);
            let progress = (self.elapsed_time / self.duration).clamp(0.0, 1.0);
            draw_circle(screen_width() * 0.5, screen_height() * 0.5, 40.0 + progress * 10.0, WHITE);
        }
    }
}
