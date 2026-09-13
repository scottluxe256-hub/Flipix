package com.flipfix.game

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import kotlinx.coroutines.delay

@Composable
fun InGameScreen(gameState: GameState, audioPlayer: AudioPlayer) {
    LaunchedEffect(Unit) {
        audioPlayer.playBgm("ingame.m4a", gameState.isBgmEnabled.value)
    }

    // Timer Countdown di awal
    LaunchedEffect(gameState.isCountdownActive.value) {
        if (gameState.isCountdownActive.value) {
            while (gameState.countdownTime.value > 0) {
                delay(1000L)
                gameState.countdownTime.value--
            }
            audioPlayer.playSfx("game-start.opus", gameState.isSfxEnabled.value)
            gameState.isCountdownActive.value = false
            // Sembunyikan semua kartu setelah timer awal habis
            gameState.cards.indices.forEach { idx ->
                gameState.cards[idx] = gameState.cards[idx].copy(isFlipped = false)
            }
        }
    }

    // Timer Game Utama
    LaunchedEffect(gameState.isCountdownActive.value, gameState.isGameOver.value, gameState.isLevelCompleted.value) {
        if (!gameState.isCountdownActive.value && !gameState.isGameOver.value && !gameState.isLevelCompleted.value) {
            while (gameState.timeRemaining.value > 0) {
                delay(1000L)
                gameState.timeRemaining.value--
            }
            if (!gameState.isLevelCompleted.value) {
                gameState.isGameOver.value = true
                audioPlayer.playSfx("game-over.opus", gameState.isSfxEnabled.value)
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFE0F7FA))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header Glassmorphism
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(Color.White.copy(alpha = 0.45f))
                    .border(1.dp, Color.White.copy(alpha = 0.7f), RoundedCornerShape(16.dp))
                    .padding(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "Level ${gameState.selectedLevel.value}",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(text = "Target: ${gameState.targetScore.value}")
                    }
                    Column(horizontalAlignment = Alignment.End) {
                        Text(
                            text = "Skor: ${gameState.currentScore.value}",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Waktu: 00:${if (gameState.timeRemaining.value < 10) "0" else ""}${gameState.timeRemaining.value}",
                            color = Color.Red,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Grid Kartu Game
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.weight(1f)
            ) {
                itemsIndexed(gameState.cards) { index, card ->
                    val assetName = if (card.isFlipped || card.isMatched) {
                        card.imageAsset
                    } else {
                        "card_back.webp"
                    }

                    val cardBitmap = rememberAssetBitmap(assetName)

                    Card(
                        modifier = Modifier
                            .aspectRatio(0.75f)
                            .clickable(enabled = !gameState.isCountdownActive.value) {
                                audioPlayer.playSfx("flip.opus", gameState.isSfxEnabled.value)
                                gameState.flipCard(
                                    index = index,
                                    onMatch = {
                                        audioPlayer.playSfx("benar.opus", gameState.isSfxEnabled.value)
                                    },
                                    onMismatch = {
                                        audioPlayer.playSfx("salah.opus", gameState.isSfxEnabled.value)
                                    }
                                )
                            },
                        shape = RoundedCornerShape(12.dp),
                        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
                    ) {
                        cardBitmap?.let { bitmap ->
                            Image(
                                bitmap = bitmap,
                                contentDescription = "Card Image",
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    }
                }
            }
        }

        // Overlay Countdown awal
        if (gameState.isCountdownActive.value) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.4f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "${gameState.countdownTime.value}",
                    fontSize = 72.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }
    }

    // Dialog Menang
    if (gameState.isLevelCompleted.value) {
        LaunchedEffect(Unit) {
            audioPlayer.playSfx("level-completed.opus", gameState.isSfxEnabled.value)
        }
        Dialog(onDismissRequest = {}) {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text("Level Selesai!", fontSize = 22.sp, fontWeight = FontWeight.Bold)
                    Text("Skor Akhir: ${gameState.currentScore.value}")

                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        StyledButton(text = "NEXT", backgroundColor = Color(0xFF8BC34A)) {
                            audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                            gameState.loadLevel(gameState.selectedLevel.value + 1)
                        }
                        StyledButton(text = "MENU", backgroundColor = Color(0xFFFFB74D)) {
                            audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                            gameState.currentScreen.value = Screen.MAIN_MENU
                        }
                    }
                }
            }
        }
    }

    // Dialog Kalah
    if (gameState.isGameOver.value) {
        Dialog(onDismissRequest = {}) {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text("Game Over", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.Red)
                    Text("Waktu kamu habis!")

                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        StyledButton(text = "ULANGI", backgroundColor = Color(0xFF4DD0E1)) {
                            audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                            gameState.loadLevel(gameState.selectedLevel.value)
                        }
                        StyledButton(text = "MENU", backgroundColor = Color(0xFFFFB74D)) {
                            audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                            gameState.currentScreen.value = Screen.MAIN_MENU
                        }
                    }
                }
            }
        }
    }
}
