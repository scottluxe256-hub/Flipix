package flipfix

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.flipfix.R

@Composable
fun MainMenuScreen(
    portrait: Boolean,
    audio: FlipFixAudioController,
    onNext: () -> Unit,
    onSettings: () -> Unit,
    onRules: () -> Unit,
    onExit: () -> Unit
) {
    GameViewport(portrait = portrait) {
        Box(modifier = Modifier.fillMaxSize()) {
            Image(
                painter = painterResource(if (portrait) R.drawable.bg_android else R.drawable.bg_windows),
                contentDescription = "FlipFix background",
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )

            FlipFixButton(
                text = "☰",
                color = Color(0xFF777777),
                modifier = Modifier.align(Alignment.TopStart).padding(20.dp),
                onClick = onRules
            )

            FlipFixButton(
                text = "⚙",
                color = Color(0xFF777777),
                modifier = Modifier.align(Alignment.TopEnd).padding(20.dp),
                onClick = onSettings
            )

            Column(
                modifier = Modifier
                    .align(Alignment.Center)
                    .width(if (portrait) 270.dp else 430.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(18.dp)
            ) {
                FlipFixButton(
                    text = "MULAI",
                    color = Color(0xFF99D516),
                    modifier = Modifier.fillMaxWidth(),
                    onClick = onNext
                )

                FlipFixButton(
                    text = "KELUAR",
                    color = Color(0xFFF4B63F),
                    modifier = Modifier.fillMaxWidth(),
                    onClick = onExit
                )
            }
        }
    }
}
