#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CurrentScreen {
    Splash,
    MainMenu,
    LevelSelect,
    InGame,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PopupState {
    None,
    Settings,
    Rules,
    LevelCompleted,
    GameOver,
}

pub struct UserSettings {
    pub bgm_enabled: bool,
    pub sfx_enabled: bool,
}

impl Default for UserSettings {
    fn default() -> Self {
        Self {
            bgm_enabled: true,
            sfx_enabled: true,
        }
    }
}

pub struct GameData {
    pub current_screen: CurrentScreen,
    pub active_popup: PopupState,
    pub settings: UserSettings,
    pub unlocked_levels: usize, // 1 sampai 20
    pub selected_level: usize,
    pub current_score: u32,
    pub target_score: u32,
    pub time_left: f32,
}

impl GameData {
    pub fn new() -> Self {
        Self {
            current_screen: CurrentScreen::Splash,
            active_popup: PopupState::None,
            settings: UserSettings::default(),
            unlocked_levels: 1, // Level 1 terbuka secara default
            selected_level: 1,
            current_score: 0,
            target_score: 100,
            time_left: 30.0,
        }
    }

    pub fn reset_round(&mut self, level: usize) {
        self.selected_level = level;
        self.current_score = 0;
        self.target_score = (level as u32) * 100;
        self.time_left = (35 - level.min(15)) as f32; // waktu fleksibel per level
        self.active_popup = PopupState::None;
    }
}
