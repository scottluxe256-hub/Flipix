package com.flipfix.game

import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf

enum class Screen {
    SPLASH, MAIN_MENU, LEVEL_SELECT, IN_GAME
}

data class MemoryCard(
    val id: Int,
    val imageAsset: String,
    var isFlipped: Boolean = false,
    var isMatched: Boolean = false
)

class GameState {
    var currentScreen = mutableStateOf(Screen.SPLASH)
    var isBgmEnabled = mutableStateOf(true)
    var isSfxEnabled = mutableStateOf(true)

    var unlockedLevel = mutableStateOf(1)
    var selectedLevel = mutableStateOf(1)

    var currentScore = mutableStateOf(0)
    var targetScore = mutableStateOf(100)
    var timeRemaining = mutableStateOf(30)
    var countdownTime = mutableStateOf(3)
    var isCountdownActive = mutableStateOf(true)
    var isGameOver = mutableStateOf(false)
    var isLevelCompleted = mutableStateOf(false)

    val cards = mutableStateListOf<MemoryCard>()
    val flippedCardIndices = mutableStateListOf<Int>()

    fun loadLevel(level: Int) {
        selectedLevel.value = level
        currentScore.value = 0
        targetScore.value = 100 + (level * 20)
        timeRemaining.value = 30 + (level * 2)
        countdownTime.value = 3
        isCountdownActive.value = true
        isGameOver.value = false
        isLevelCompleted.value = false
        flippedCardIndices.clear()

        // Generate pasangan kartu sederhana
        val cardImages = listOf(
            "card_1.webp", "card_2.webp", "card_3.webp", "card_4.webp"
        )
        val deck = mutableListOf<MemoryCard>()
        var idCounter = 0

        val pairCount = minOf(2 + (level / 2), cardImages.size)
        for (i in 0 until pairCount) {
            val img = cardImages[i]
            deck.add(MemoryCard(idCounter++, img, isFlipped = true))
            deck.add(MemoryCard(idCounter++, img, isFlipped = true))
        }

        deck.shuffle()
        cards.clear()
        cards.addAll(deck)
    }

    fun flipCard(index: Int, onMatch: () -> Unit, onMismatch: () -> Unit) {
        if (flippedCardIndices.size < 2 && !cards[index].isFlipped && !cards[index].isMatched) {
            cards[index] = cards[index].copy(isFlipped = true)
            flippedCardIndices.add(index)

            if (flippedCardIndices.size == 2) {
                val idx1 = flippedCardIndices[0]
                val idx2 = flippedCardIndices[1]

                if (cards[idx1].imageAsset == cards[idx2].imageAsset) {
                    cards[idx1] = cards[idx1].copy(isMatched = true)
                    cards[idx2] = cards[idx2].copy(isMatched = true)
                    currentScore.value += 50
                    flippedCardIndices.clear()
                    onMatch()

                    if (cards.all { it.isMatched }) {
                        isLevelCompleted.value = true
                        if (selectedLevel.value >= unlockedLevel.value && unlockedLevel.value < 20) {
                            unlockedLevel.value++
                        }
                    }
                } else {
                    onMismatch()
                }
            }
        }
    }

    fun resetFlippedCards() {
        if (flippedCardIndices.size == 2) {
            val idx1 = flippedCardIndices[0]
            val idx2 = flippedCardIndices[1]
            cards[idx1] = cards[idx1].copy(isFlipped = false)
            cards[idx2] = cards[idx2].copy(isFlipped = false)
            flippedCardIndices.clear()
        }
    }
}
