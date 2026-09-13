package flipfix

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import io.github.kdroidfilter.composemediaplayer.audio.AudioPlayer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive

class FlipFixAudioController {

    private val musicPlayer = AudioPlayer()
    private val sfxPlayer = AudioPlayer()

    var bgmEnabled by mutableStateOf(true)
        private set

    var sfxEnabled by mutableStateOf(true)
        private set

    fun setBgmEnabled(enabled: Boolean) {
        bgmEnabled = enabled
        if (!enabled) musicPlayer.stop()
    }

    fun setSfxEnabled(enabled: Boolean) {
        sfxEnabled = enabled
    }

    fun playBgm(uri: String) {
        if (!bgmEnabled) return
        musicPlayer.play(uri)
    }

    fun stopBgm() {
        musicPlayer.stop()
    }

    fun playSfx(uri: String) {
        if (!sfxEnabled) return
        sfxPlayer.stop()
        sfxPlayer.play(uri)
    }

    fun dispose() {
        musicPlayer.stop()
        sfxPlayer.stop()
    }

    suspend fun loopBgm(scope: CoroutineScope, uri: String) {
        if (!bgmEnabled) return
        musicPlayer.play(uri)

        while (scope.isActive && bgmEnabled) {
            delay(250)
            val duration = musicPlayer.currentDuration() ?: 0L
            val position = musicPlayer.currentPosition() ?: 0L

            if (duration > 0L && position >= (duration - 150L)) {
                musicPlayer.play(uri)
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
