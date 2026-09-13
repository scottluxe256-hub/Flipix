package com.flipfix.game

import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.annotation.OptIn
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .aspectRatio(9f / 20f)
                        ) {
                            FlipFixApp()
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun FlipFixApp() {
    val context = LocalContext.current
    val gameState = remember { GameState() }
    val audioPlayer = remember { AudioPlayer(context) }

    DisposableEffect(Unit) {
        onDispose {
            audioPlayer.release()
        }
    }

    when (gameState.currentScreen.value) {
        Screen.SPLASH -> InlineSplashScreen(gameState)
        Screen.MAIN_MENU -> MainMenuScreen(gameState, audioPlayer)
        Screen.LEVEL_SELECT -> LevelSelectScreen(gameState, audioPlayer)
        Screen.IN_GAME -> InGameScreen(gameState, audioPlayer)
    }
}

@OptIn(UnstableApi::class)
@Composable
fun InlineSplashScreen(gameState: GameState) {
    val context = LocalContext.current

    val exoPlayer = remember {
        val renderersFactory = DefaultRenderersFactory(context).apply {
            setExtensionRendererMode(DefaultRenderersFactory.EXTENSION_RENDERER_MODE_PREFER)
        }
        ExoPlayer.Builder(context, renderersFactory).build().apply {
            val videoUri = Uri.parse("asset:///aarch64.mp4")
            setMediaItem(MediaItem.fromUri(videoUri))
            prepare()
            playWhenReady = true
        }
    }

    DisposableEffect(exoPlayer) {
        val listener = object : Player.Listener {
            override fun onPlaybackStateChanged(playbackState: Int) {
                if (playbackState == Player.STATE_ENDED) {
                    gameState.currentScreen.value = Screen.MAIN_MENU
                }
            }
        }
        exoPlayer.addListener(listener)

        onDispose {
            exoPlayer.removeListener(listener)
            exoPlayer.release()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        AndroidView(
            factory = { ctx ->
                PlayerView(ctx).apply {
                    player = exoPlayer
                    useController = false
                    resizeMode = AspectRatioFrameLayout.RESIZE_MODE_ZOOM
                }
            },
            modifier = Modifier.fillMaxSize()
        )
    }
}
