package flipfix

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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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

    Box(modifier = Modifier.fillMaxSize().background(Color(0xFFEAF8FF))) {
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
                        session.tapCard(index)
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

@Composable
private fun GameHeader(level: Int, target: Int, score: Int, timeLeft: Int) {
    Column(modifier = Modifier.fillMaxWidth()) {
        Text(text = "Level $level", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color(0xFF34596B))
        Row(
            modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(text = "Target: $target", fontSize = 15.sp)
            Text(text = "Score: $score", fontSize = 15.sp)
            Text(text = "Time: ${formatTime(timeLeft)}", fontSize = 15.sp)
        }
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
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(0.78f)
            .shadow(elevation = 4.dp, shape = RoundedCornerShape(12.dp))
            .background(if (card.isFaceUp || card.isMatched) Color.White else Color(0xFF2196F3), RoundedCornerShape(12.dp))
            .border(1.dp, Color.Gray, RoundedCornerShape(12.dp))
            .clickable(enabled = !card.isMatched, onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        if (card.isFaceUp || card.isMatched) {
            Text(text = "${card.imageIndex}", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color.Black)
        } else {
            Text(text = "?", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color.White)
        }
    }
}

@Composable
private fun PreviewOverlay(seconds: Int) {
    Box(
        modifier = Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.3f)),
        contentAlignment = Alignment.Center
    ) {
        Text(text = seconds.toString(), fontSize = 48.sp, fontWeight = FontWeight.Bold, color = Color.White)
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
