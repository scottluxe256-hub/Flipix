package flipfix

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun MainMenuScreen(
    portrait: Boolean,
    audio: FlipFixAudioController,
    onNext: () -> Unit,
    onSettings: () -> Unit,
    onRules: () -> Unit,
    onExit: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF1E1E2C))
            .padding(24.dp)
    ) {
        Column(
            modifier = Modifier.align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(text = "FlipFix Game", fontSize = 32.sp, color = Color.White)

            Button(
                onClick = onNext,
                modifier = Modifier.fillMaxWidth().height(50.dp)
            ) {
                Text("MULAI", fontSize = 18.sp)
            }

            Button(
                onClick = onExit,
                modifier = Modifier.fillMaxWidth().height(50.dp)
            ) {
                Text("KELUAR", fontSize = 18.sp)
            }
        }
    }
}
