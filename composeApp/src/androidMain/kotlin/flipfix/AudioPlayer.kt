package flipfix

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import io.github.kdroidfilter.composemediaplayer.audio.AudioPlayer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive

class FlipFixAudioController {

    private var musicPlayer: AudioPlayer? = null
    private var sfxPlayer: AudioPlayer? = null

    var bgmEnabled by mutableStateOf(true)
    var sfxEnabled by mutableStateOf(true)

    init {
        try {
            musicPlayer = AudioPlayer()
            sfxPlayer = AudioPlayer()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun setBgmEnabled(enabled: Boolean) {
        bgmEnabled = enabled
        if (!enabled) musicPlayer?.stop()
    }

    fun setSfxEnabled(enabled: Boolean) {
        sfxEnabled = enabled
    }

    fun playBgm(uri: String) {
        if (!bgmEnabled) return
        try { musicPlayer?.play(uri) } catch (_: Exception) {}
    }

    fun stopBgm() {
        try { musicPlayer?.stop() } catch (_: Exception) {}
    }

    fun playSfx(uri: String) {
        if (!sfxEnabled) return
        try {
            sfxPlayer?.stop()
            sfxPlayer?.play(uri)
        } catch (_: Exception) {}
    }

    fun dispose() {
        try {
            musicPlayer?.stop()
            sfxPlayer?.stop()
        } catch (_: Exception) {}
    }

    suspend fun loopBgm(scope: CoroutineScope, uri: String) {
        if (!bgmEnabled) return
        try { musicPlayer?.play(uri) } catch (_: Exception) {}

        while (scope.isActive && bgmEnabled) {
            delay(250)
            val duration = try { musicPlayer?.currentDuration() ?: 0L } catch (_: Exception) { 0L }
            val position = try { musicPlayer?.currentPosition() ?: 0L } catch (_: Exception) { 0L }

            if (duration > 0L && position >= (duration - 150L)) {
                try { musicPlayer?.play(uri) } catch (_: Exception) {}
            }
        }
    }
}

@Composable
fun rememberFlipFixAudioController(): FlipFixAudioController {
    val controller = remember { FlipFixAudioController() }
    DisposableEffect(Unit) {
        onDispose { controller.dispose() }
    }
    return controller
}

@Composable
fun MusicEffect(
    controller: FlipFixAudioController,
    uri: String?,
    enabled: Boolean
) {
    LaunchedEffect(uri, enabled) {
        if (uri == null || !enabled) {
            controller.stopBgm()
            return@LaunchedEffect
        }
        controller.loopBgm(this, uri)
    }
}
