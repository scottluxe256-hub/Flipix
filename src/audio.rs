use std::fs::File;
use std::io::BufReader;
use rodio::{Decoder, OutputStream, OutputStreamHandle, Sink};

pub struct AudioManager {
    _stream: OutputStream,
    stream_handle: OutputStreamHandle,
    bgm_sink: Option<Sink>,
}

impl AudioManager {
    pub fn new() -> Result<Self, String> {
        let (_stream, stream_handle) = OutputStream::try_default()
            .map_err(|e| format!("Gagal inisialisasi OutputStream audio: {}", e))?;
        Ok(Self {
            _stream,
            stream_handle,
            bgm_sink: None,
        })
    }

    pub fn play_bgm(&mut self, path: &str, enabled: bool) {
        if !enabled {
            self.stop_bgm();
            return;
        }
        self.stop_bgm();
        if let Ok(file) = File::open(path) {
            let buf = BufReader::new(file);
            if let Ok(source) = Decoder::new(buf) {
                if let Ok(sink) = Sink::try_new(&self.stream_handle) {
                    use rodio::Source;
                    sink.append(source.repeat_infinite());
                    sink.play();
                    self.bgm_sink = Some(sink);
                }
            }
        }
    }

    pub fn stop_bgm(&mut self) {
        if let Some(sink) = self.bgm_sink.take() {
            sink.stop();
        }
    }

    pub fn play_sfx(&self, path: &str, enabled: bool) {
        if !enabled {
            return;
        }
        if let Ok(file) = File::open(path) {
            let buf = BufReader::new(file);
            if let Ok(source) = Decoder::new(buf) {
                if let Ok(sink) = Sink::try_new(&self.stream_handle) {
                    sink.append(source);
                    sink.detach();
                }
            }
        }
    }
}
