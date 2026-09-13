package flipfix

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.flipfix.R
import kotlinx.coroutines.delay

@Composable
fun InGameScreen(
    level: Int,
    portrait: Boolean,
    audio: FlipFixAudioController,
    onExit: () -> Unit,
    onNextLevel: () -> Unit
) {
    val session = remember(level) { GameSession(level) }

    LaunchedEffect(level) {
        repeat(3) {
            delay(1_000)
            session.previewSeconds.value--
        }
        session.beginGameplay()
    }

    LaunchedEffect(session.acceptingInput.value) {
        if (!session.acceptingInput.value) return@LaunchedEffect
        while (session.result.value == GameResult.Playing && session.acceptingInput.value) {
            delay(1_000)
            session.tick()
        }
    }

    LaunchedEffect(session.selectedSecond.value) {
        if (session.selectedSecond.value == null) return@LaunchedEffect
        delay(550)
        when (session.evaluateSelection()) {
            true -> audio.playSfx(resourceUri("benar.opus"))
            false -> audio.playSfx(resourceUri("salah.opus"))
            null -> Unit
        }
    }

    GameViewport(portrait = portrait) {
        Box(modifier = Modifier.fillMaxSize()) {
            Box(modifier = Modifier.fillMaxSize().background(Color(0xFFEAF8FF)))
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = if (portrait) 14.dp else 36.dp, vertical = 16.dp)
            ) {
                GameHeader(
                    level = level,
                    target = GameSession.TARGET_SCORE,
                    score = session.score.value,
                    timeLeft = session.timeLeft.value
                )

                Spacer(modifier = Modifier.height(18.dp))

                Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
                    CardGrid(
                        session = session,
                        onCardTapped = { index ->
                            if (session.tapCard(index)) {
                                audio.playSfx(resourceUri("flip.opus"))
                            }
                        }
                    )

                    if (session.previewSeconds.value > 0) {
                        PreviewOverlay(seconds = session.previewSeconds.value)
                    }
                }
            }

            GameResultDialog(
                result = session.result.value,
                score = session.score.value,
                timeLeft = session.timeLeft.value,
                level = level,
                onExit = onExit,
                onNextLevel = onNextLevel,
                onRetry = { session.reset() }
            )
        }
    }
}

@Composable
private fun GameHeader(level: Int, target: Int, score: Int, timeLeft: Int) {
    GlassPanel(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(20.dp)) {
        Column(modifier = Modifier.fillMaxWidth()) {
            Text(text = "Level $level", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color(0xFF34596B))
            Row(
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                HeaderValue(title = "Target", value = target.toString())
                HeaderValue(title = "Score", value = score.toString())
                HeaderValue(title = "Time Left", value = formatTime(timeLeft))
            }
        }
    }
}

@Composable
private fun HeaderValue(title: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = title, fontSize = 13.sp, color = Color(0xFF526E7B))
        Text(text = value, fontSize = 21.sp, fontWeight = FontWeight.Bold, color = Color(0xFF172F3B))
    }
}

@Composable
private fun CardGrid(session: GameSession, onCardTapped: (Int) -> Unit) {
    LazyVerticalGrid(
        columns = GridCells.Fixed(4),
        modifier = Modifier.fillMaxSize(),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        itemsIndexed(items = session.cards, key = { _, card -> card.id }) { index, card ->
            MemoryCardView(card = card, onClick = { onCardTapped(index) })
        }
    }
}

@Composable
private fun MemoryCardView(card: MemoryCard, onClick: () -> Unit) {
    val imageRes = when (card.imageIndex) {
        1 -> R.drawable.card_1
        2 -> R.drawable.card_2
        3 -> R.drawable.card_3
        4 -> R.drawable.card_4
        5 -> R.drawable.card_5
        6 -> R.drawable.card_6
        7 -> R.drawable.card_7
        8 -> R.drawable.card_8
        9 -> R.drawable.card_9
        10 -> R.drawable.card_10
        else -> R.drawable.card_11
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(0.78f)
            .shadow(elevation = 8.dp, shape = RoundedCornerShape(18.dp))
            .background(Color.White, RoundedCornerShape(18.dp))
            .border(1.dp, Color.White.copy(alpha = 0.95f), RoundedCornerShape(18.dp))
            .clickable(enabled = !card.isMatched, onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        if (card.isFaceUp || card.isMatched) {
            Image(
                painter = painterResource(imageRes),
                contentDescription = "Memory card",
                modifier = Modifier.fillMaxSize().padding(10.dp),
                contentScale = ContentScale.Fit
            )
        } else {
            Image(
                painter = painterResource(R.drawable.card_back),
                contentDescription = "Card back",
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
        }
    }
}

@Composable
private fun PreviewOverlay(seconds: Int) {
    Box(
        modifier = Modifier.fillMaxSize().background(Color.White.copy(alpha = 0.12f)),
        contentAlignment = Alignment.Center
    ) {
        GlassPanel(modifier = Modifier.size(140.dp), shape = RoundedCornerShape(32.dp)) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(text = seconds.toString(), fontSize = 58.sp, fontWeight = FontWeight.Black, color = Color(0xFF214A60))
            }
        }
    }
}

@Composable
private fun GameResultDialog(
    result: GameResult, score: Int, timeLeft: Int, level: Int,
    onExit: () -> Unit, onNextLevel: () -> Unit, onRetry: () -> Unit
) {
    if (result == GameResult.Playing) return
    val won = result == GameResult.Won

    AlertDialog(
        onDismissRequest = {},
        title = { Text(text = if (won) "Level Completed" else "Game Over", fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(text = "Level: $level")
                Text(text = "Score: $score")
                Text(text = "Sisa waktu: ${formatTime(timeLeft)}")
            }
        },
        confirmButton = {
            if (won) {
                TextButton(onClick = onNextLevel) { Text("Next Level") }
            } else {
                TextButton(onClick = onRetry) { Text("Try Again") }
            }
        },
        dismissButton = { TextButton(onClick = onExit) { Text("Exit") } }
    )
}

private fun formatTime(totalSeconds: Int): String {
    val minutes = totalSeconds / 60
    val seconds = totalSeconds % 60
    return "%02d:%02d".format(minutes, seconds)
}
