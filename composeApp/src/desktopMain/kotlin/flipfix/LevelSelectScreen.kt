package flipfix

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun LevelSelectScreen(
    highestUnlockedLevel: Int,
    onBack: () -> Unit,
    onLevelSelected: (Int) -> Unit
) {
    Box(
        modifier = Modifier.fillMaxSize()
    ) {
        AuroraBackground()

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                FlipFixButton(
                    text = "←",
                    color = Color(0xFF707070),
                    modifier = Modifier.size(58.dp),
                    onClick = onBack
                )

                Text(
                    text = "Level",
                    modifier = Modifier.weight(1f),
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                    fontSize = 30.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF254B61)
                )

                Box(
                    modifier = Modifier.size(58.dp)
                )
            }

            LazyVerticalGrid(
                columns = GridCells.Fixed(4),
                modifier = Modifier
                    .fillMaxSize()
                    .padding(top = 22.dp),
                contentPadding = PaddingValues(10.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items((1..20).toList()) { level ->
                    val unlocked = level <= highestUnlockedLevel

                    LevelTile(
                        level = level,
                        unlocked = unlocked,
                        onClick = {
                            if (unlocked) {
                                onLevelSelected(level)
                            }
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun LevelTile(
    level: Int,
    unlocked: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .size(72.dp)
            .shadow(
                elevation = 9.dp,
                shape = RoundedCornerShape(20.dp)
            )
            .background(
                if (unlocked) {
                    Color.White.copy(alpha = 0.82f)
                } else {
                    Color.White.copy(alpha = 0.42f)
                },
                RoundedCornerShape(20.dp)
            )
            .border(
                width = 1.dp,
                color = Color.White.copy(alpha = 0.8f),
                shape = RoundedCornerShape(20.dp)
            )
            .clickable(
                enabled = unlocked,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = if (unlocked) {
                level.toString()
            } else {
                "🔒"
            },
            fontSize = if (unlocked) 23.sp else 20.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF315D72)
        )
    }
}