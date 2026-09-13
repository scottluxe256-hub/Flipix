// Temporary video stub module to bypass C-dependency issues on Android cross-builds
pub struct VideoPlayer;

impl VideoPlayer {
    pub fn new() -> Self {
        Self
    }
    pub fn update(&mut self) {}
    pub fn render(&self) {}
}
