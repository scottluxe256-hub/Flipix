package com.flipfix.game

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun LevelSelectScreen(gameState: GameState, audioPlayer: AudioPlayer) {
    // Animasi Aurora Soft Blue
    val infiniteTransition = rememberInfiniteTransition(label = "aurora")
    val offset by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1000f,
        animationSpec = infiniteRepeatable(
            animation = tween(8000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "auroraOffset"
    )

    Box(modifier = Modifier.fillMaxSize()) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val brush = Brush.sweepGradient(
                colors = listOf(
                    Color(0xFFE0F7FA),
                    Color(0xFFB2EBF2),
                    Color(0xFF80DEEA),
                    Color(0xFFE0F7FA)
                ),
                center = androidx.compose.ui.geometry.Offset(offset, offset)
            )
            drawRect(brush = brush)
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                StyledButton(
                    text = "Kembali",
                    backgroundColor = Color.White,
                    textColor = Color.Black
                ) {
                    audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                    gameState.currentScreen.value = Screen.MAIN_MENU
                }
                Spacer(modifier = Modifier.width(16.dp))
                Text(
                    text = "Pilih Level",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF006064)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            LazyVerticalGrid(
                columns = GridCells.Fixed(4),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(20) { index ->
                    val level = index + 1
                    val isUnlocked = level <= gameState.unlockedLevel.value

                    Box(
                        modifier = Modifier
                            .aspectRatio(1f)
                            .clip(RoundedCornerShape(12.dp))
                            .background(
                                if (isUnlocked) Color(0xFF4DD0E1) else Color(0xFFB0BEC5)
                            )
                            .clickable(enabled = isUnlocked) {
                                audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                                gameState.loadLevel(level)
                                gameState.currentScreen.value = Screen.IN_GAME
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = if (isUnlocked) "$level" else "🔒",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }
            }
        }
    }
}
