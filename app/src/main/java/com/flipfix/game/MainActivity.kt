package com.flipfix.game

import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var showSplash by remember { mutableStateOf(true) }

            if (showSplash) {
                SplashScreen(onVideoFinished = { showSplash = false })
            } else {
                MainMenuScreen()
            }
        }
    }
}

@Composable
fun SplashScreen(onVideoFinished: () -> Unit) {
    val context = LocalContext.current
    
    // Safety Fallback: Jika video stuck lebih dari 4 detik, langsung masuk ke Menu Utama
    LaunchedEffect(Unit) {
        delay(4000)
        onVideoFinished()
    }

    val exoPlayer = remember {
        ExoPlayer.Builder(context).build().apply {
            val videoUri = Uri.parse("asset:///aarch64.mp4")
            setMediaItem(MediaItem.fromUri(videoUri))
            prepare()
            playWhenReady = true
            
            addListener(object : Player.Listener {
                override fun onPlaybackStateChanged(state: Int) {
                    if (state == Player.STATE_ENDED) {
                        onVideoFinished()
                    }
                }
                override fun onPlayerError(error: androidx.media3.common.PlaybackException) {
                    // Jika video gagal diputar/file tak terdeteksi, langsung skip ke menu
                    onVideoFinished()
                }
            })
        }
    }

    DisposableEffect(Unit) {
        onDispose {
            exoPlayer.release()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        contentAlignment = Alignment.Center
    ) {
        AndroidView(
            factory = { ctx ->
                PlayerView(ctx).apply {
                    player = exoPlayer
                    useController = false
                }
            },
            modifier = Modifier.fillMaxSize()
        )
    }
}

@Composable
fun MainMenuScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.DarkGray),
        contentAlignment = Alignment.Center
    ) {
        Text(text = "Selamat Datang di Flipix!", color = Color.White)
    }
}
