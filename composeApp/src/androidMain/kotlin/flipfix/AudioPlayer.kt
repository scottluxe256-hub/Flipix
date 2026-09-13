package flipfix

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext

class FlipFixAudioController(private val context: Context) {

    var bgmEnabled by mutableStateOf(true)
    var sfxEnabled by mutableStateOf(true)

    fun updateBgm(enabled: Boolean) {
        bgmEnabled = enabled
    }

    fun updateSfx(enabled: Boolean) {
        sfxEnabled = enabled
    }

    fun playBgm(resourceName: String) {}
    fun stopBgm() {}
    fun playSfx(resourceName: String) {}
    fun dispose() {}
}

@Composable
fun rememberFlipFixAudioController(): FlipFixAudioController {
    val context = LocalContext.current.applicationContext
    val controller = remember { FlipFixAudioController(context) }
    DisposableEffect(Unit) {
        onDispose { controller.dispose() }
    }
    return controller
}
