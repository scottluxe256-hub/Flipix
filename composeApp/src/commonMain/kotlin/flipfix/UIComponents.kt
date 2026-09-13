package flipfix

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import composeApp.generated.resources.Res
import io.github.kdroidfilter.composemediaplayer.VideoPlayerSurface
import io.github.kdroidfilter.composemediaplayer.rememberVideoPlayerState
import kotlinx.coroutines.delay
import org.jetbrains.compose.resources.painterResource

private enum class AppScreen {
    Splash,
    Menu,
    Levels,
    Game
}

@Composable
fun FlipFixApp() {
    var screen by remember {
        mutableStateOf(AppScreen.Splash)
    }

    var selectedLevel by remember {
        mutableStateOf(1)
    }

    var highestUnlockedLevel by remember {
        mutableStateOf(1)
    }

    var showSettings by remember {
        mutableStateOf(false)
    }

    var showRules by remember {
        mutableStateOf(false)
    }

    val audio = rememberFlipFixAudioController()

    val androidMode = rememberPlatformPortraitMode()

    MaterialTheme {
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFBFE9FF))
        ) {
            val portrait = maxHeight > maxWidth

            when (screen) {
                AppScreen.Splash -> {
                    SplashScreen(
                        portrait = portrait,
                        onFinished = {
                            screen = AppScreen.Menu
                        }
                    )
                }

                AppScreen.Menu -> {
                    MainMenuScreen(
                        portrait = portrait,
                        audio = audio,
                        onNext = {
                            audio.playSfx(resourceUri("files/click.opus"))
                            screen = AppScreen.Levels
                        },
                        onSettings = {
                            audio.playSfx(resourceUri("files/click.opus"))
                            showSettings = true
                        },
                        onRules = {
                            audio.playSfx(resourceUri("files/click.opus"))
                            showRules = true
                        },
                        onExit = {
                            audio.playSfx(resourceUri("files/click.opus"))
                        }
                    )

                    MusicEffect(
                        controller = audio,
                        uri = resourceUri("files/output.m4a"),
                        enabled = audio.bgmEnabled
                    )
                }

                AppScreen.Levels -> {
                    LevelSelectScreen(
                        onBack = {
                            audio.playSfx(resourceUri("files/click.opus"))
                            screen = AppScreen.Menu
                        },
                        onLevelSelected = { level ->
                            selectedLevel = level
                            audio.playSfx(resourceUri("files/click.opus"))
                            screen = AppScreen.Game
                        },
                        highestUnlockedLevel = highestUnlockedLevel
                    )
                }

                AppScreen.Game -> {
                    InGameScreen(
                        level = selectedLevel,
                        portrait = portrait,
                        audio = audio,
                        onExit = {
                            audio.playSfx(resourceUri("files/click.opus"))
                            screen = AppScreen.Levels
                        },
                        onNextLevel = {
                            val next = selectedLevel + 1

                            if (next <= 20) {
                                highestUnlockedLevel =
                                    maxOf(highestUnlockedLevel, next)

                                selectedLevel = next
                                screen = AppScreen.Game
                            } else {
                                screen = AppScreen.Levels
                            }
                        }
                    )

                    MusicEffect(
                        controller = audio,
                        uri = resourceUri("files/ingame.m4a"),
                        enabled = audio.bgmEnabled
                    )
                }
            }

            if (showSettings) {
                SettingsDialog(
                    audio = audio,
                    onDismiss = {
                        showSettings = false
                    }
                )
            }

            if (showRules) {
                RulesDialog(
                    onDismiss = {
                        showRules = false
                    }
                )
            }
        }
    }
}

@Composable
private fun SplashScreen(
    portrait: Boolean,
    onFinished: () -> Unit
) {
    val videoState = rememberVideoPlayerState()

    val videoUri = resourceUri(
        if (portrait) {
            "files/aarch64.mp4"
        } else {
            "files/x64.mp4"
        }
    )

    var finished by remember {
        mutableStateOf(false)
    }

    LaunchedEffect(videoUri) {
        try {
            videoState.onPlaybackEnded = {
                if (!finished) {
                    finished = true
                    onFinished()
                }
            }

            videoState.openUri(videoUri)

            delay(8_500)

            if (!finished) {
                finished = true
                onFinished()
            }
        } catch (_: Throwable) {
            if (!finished) {
                finished = true
                onFinished()
            }
        }
    }

    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        VideoPlayerSurface(
            playerState = videoState,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
    }
}

@Composable
fun GameViewport(
    modifier: Modifier = Modifier,
    portrait: Boolean,
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .then(
                    if (portrait) {
                        Modifier
                            .fillMaxHeight()
                            .aspectRatio(9f / 20f)
                    } else {
                        Modifier
                            .fillMaxWidth()
                            .aspectRatio(16f / 9f)
                    }
                )
        ) {
            content()
        }
    }
}

@Composable
fun GlassPanel(
    modifier: Modifier = Modifier,
    shape: RoundedCornerShape = RoundedCornerShape(24.dp),
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier
            .shadow(
                elevation = 14.dp,
                shape = shape,
                clip = false
            )
            .clip(shape)
            .background(
                Color.White.copy(alpha = 0.20f)
            )
            .border(
                width = 1.dp,
                color = Color.White.copy(alpha = 0.60f),
                shape = shape
            )
            .padding(14.dp)
    ) {
        content()
    }
}

@Composable
fun FlipFixButton(
    text: String,
    modifier: Modifier = Modifier,
    color: Color,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        modifier = modifier
            .shadow(
                elevation = 12.dp,
                shape = RoundedCornerShape(32.dp),
                clip = false
            ),
        shape = RoundedCornerShape(32.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = color,
            contentColor = Color.White
        )
    ) {
        Text(
            text = text,
            fontSize = 21.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun AuroraBackground(
    modifier: Modifier = Modifier
) {
    val transition = rememberInfiniteTransition(
        label = "aurora"
    )

    val rotation by transition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(
                durationMillis = 16_000,
                easing = FastOutSlowInEasing
            ),
            repeatMode = RepeatMode.Restart
        ),
        label = "auroraRotation"
    )

    val pulse by transition.animateFloat(
        initialValue = 0.55f,
        targetValue = 0.95f,
        animationSpec = infiniteRepeatable(
            animation = tween(4_000),
            repeatMode = RepeatMode.Reverse
        ),
        label = "auroraPulse"
    )

    Canvas(
        modifier = modifier
            .fillMaxSize()
            .background(
                Color(0xFFBEEFFF)
            )
    ) {
        withTransform({
            rotate(
                degrees = rotation,
                pivot = center
            )
        }) {
            drawRect(
                brush = Brush.sweepGradient(
                    colors = listOf(
                        Color(0xFF9DE7FF),
                        Color(0xFFDBF6FF),
                        Color(0xFF89D7FF),
                        Color(0xFFE9FAFF),
                        Color(0xFF9DE7FF)
                    )
                )
            )
        }

        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color.White.copy(alpha = 0.40f * pulse),
                    Color.Transparent
                )
            ),
            radius = size.minDimension * 0.55f,
            center = Offset(
                size.width * 0.20f,
                size.height * 0.22f
            )
        )

        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color(0xFF69CFFF).copy(alpha = 0.25f),
                    Color.Transparent
                )
            ),
            radius = size.minDimension * 0.65f,
            center = Offset(
                size.width * 0.80f,
                size.height * 0.75f
            )
        )
    }
}

@Composable
private fun SettingsDialog(
    audio: FlipFixAudioController,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                "Settings",
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Column(
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                SettingRow(
                    title = "BGM",
                    checked = audio.bgmEnabled,
                    onCheckedChange = audio::setBgmEnabled
                )

                SettingRow(
                    title = "SFX",
                    checked = audio.sfxEnabled,
                    onCheckedChange = audio::setSfxEnabled
                )
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("OK")
            }
        }
    )
}

@Composable
private fun SettingRow(
    title: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = title,
            fontSize = 18.sp
        )

        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange
        )
    }
}

@Composable
private fun RulesDialog(
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                "Rules",
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Text(
                text = """
                    • Semua kartu dibuka selama countdown.
                    
                    • Setelah countdown selesai, kartu ditutup.
                    
                    • Buka dua kartu untuk mencari pasangan.
                    
                    • Pasangan benar menambah skor.
                    
                    • Pasangan salah mengurangi skor.
                    
                    • Selesaikan semua pasangan sebelum waktu habis.
                """.trimIndent(),
                lineHeight = 22.sp
            )
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Mengerti")
            }
        }
    )
}

private fun resourceUri(path: String): String {
    return Res.getUri(path)
}

@Composable
private fun rememberPlatformPortraitMode(): Boolean {
    return false
}