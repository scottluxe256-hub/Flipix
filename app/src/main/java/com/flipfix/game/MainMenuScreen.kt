package com.flipfix.game

import android.app.Activity
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog

@Composable
fun MainMenuScreen(gameState: GameState, audioPlayer: AudioPlayer) {
    val context = LocalContext.current
    var showSettingsDialog by remember { mutableStateOf(false) }
    var showRulesDialog by remember { mutableStateOf(false) }

    val bgBitmap = rememberAssetBitmap("bg_android.webp")

    LaunchedEffect(Unit) {
        audioPlayer.playBgm("output.m4a", gameState.isBgmEnabled.value)
    }

    Box(modifier = Modifier.fillMaxSize()) {
        // Render Background WebP bawaan
        bgBitmap?.let { bitmap ->
            Image(
                bitmap = bitmap,
                contentDescription = "Main Menu Background",
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
        }

        // Tombol Navigasi Atas
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            IconButtonWithShadow(iconRes = android.R.drawable.ic_menu_sort_by_size) {
                audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                showRulesDialog = true
            }
            IconButtonWithShadow(iconRes = android.R.drawable.ic_menu_preferences) {
                audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                showSettingsDialog = true
            }
        }

        // Tombol Utama Mulai / Keluar
        Column(
            modifier = Modifier
                .align(Alignment.Center)
                .padding(top = 100.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            StyledButton(
                text = "MULAI",
                backgroundColor = Color(0xFF8BC34A)
            ) {
                audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                gameState.currentScreen.value = Screen.LEVEL_SELECT
            }

            StyledButton(
                text = "KELUAR",
                backgroundColor = Color(0xFFFFB74D)
            ) {
                audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                (context as? Activity)?.finish()
            }
        }
    }

    // Dialog Settings
    if (showSettingsDialog) {
        Dialog(onDismissRequest = { showSettingsDialog = false }) {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                modifier = Modifier.padding(16.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Text("Pengaturan", fontSize = 20.sp)

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Musik BGM")
                        Switch(
                            checked = gameState.isBgmEnabled.value,
                            onCheckedChange = {
                                gameState.isBgmEnabled.value = it
                                if (it) audioPlayer.resumeBgm() else audioPlayer.pauseBgm()
                            }
                        )
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Efek SFX")
                        Switch(
                            checked = gameState.isSfxEnabled.value,
                            onCheckedChange = { gameState.isSfxEnabled.value = it }
                        )
                    }

                    StyledButton(text = "TUTUP", backgroundColor = Color(0xFF8BC34A)) {
                        audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                        showSettingsDialog = false
                    }
                }
            }
        }
    }

    // Dialog Rules
    if (showRulesDialog) {
        Dialog(onDismissRequest = { showRulesDialog = false }) {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                modifier = Modifier.padding(16.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text("Cara Bermain", fontSize = 20.sp)
                    Text("1. Pilih level untuk memulai tantangan.")
                    Text("2. Di awal game, perhatikan posisi gambar kartu.")
                    Text("3. Temukan pasangan kartu yang cocok sebelum waktu habis.")

                    StyledButton(text = "MENGERTI", backgroundColor = Color(0xFF8BC34A)) {
                        audioPlayer.playSfx("click.opus", gameState.isSfxEnabled.value)
                        showRulesDialog = false
                    }
                }
            }
        }
    }
}
