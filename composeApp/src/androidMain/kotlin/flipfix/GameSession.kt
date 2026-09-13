package flipfix

import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import kotlin.random.Random

data class MemoryCard(
    val id: Int,
    val pairId: Int,
    val imageIndex: Int,
    val isFaceUp: Boolean = false,
    val isMatched: Boolean = false
)

enum class GameResult {
    Playing,
    Won,
    Lost
}

class GameSession(
    val level: Int
) {
    companion object {
        const val CARD_TYPES = 11
        const val PAIRS = 11
        const val TARGET_SCORE = 100
        const val POINTS_PER_MATCH = 10
        const val PENALTY_PER_MISS = 5

        fun timeForLevel(level: Int): Int {
            return (60 - ((level - 1) * 2)).coerceAtLeast(25)
        }
    }

    val cards = mutableStateListOf<MemoryCard>()

    val score = mutableStateOf(0)
    val timeLeft = mutableStateOf(timeForLevel(level))
    val previewSeconds = mutableStateOf(3)

    val selectedFirst = mutableStateOf<Int?>(null)
    val selectedSecond = mutableStateOf<Int?>(null)

    val acceptingInput = mutableStateOf(false)
    val result = mutableStateOf(GameResult.Playing)

    private var nextCardId = 0

    init {
        reset()
    }

    fun reset() {
        cards.clear()

        score.value = 0
        timeLeft.value = timeForLevel(level)
        previewSeconds.value = 3
        selectedFirst.value = null
        selectedSecond.value = null
        acceptingInput.value = false
        result.value = GameResult.Playing

        nextCardId = 0

        val generated = buildList {
            repeat(PAIRS) { pair ->
                add(
                    MemoryCard(
                        id = nextCardId++,
                        pairId = pair,
                        imageIndex = pair + 1,
                        isFaceUp = true
                    )
                )

                add(
                    MemoryCard(
                        id = nextCardId++,
                        pairId = pair,
                        imageIndex = pair + 1,
                        isFaceUp = true
                    )
                )
            }
        }.shuffled(Random(level * 997 + 17))

        cards.addAll(generated)
    }

    fun beginGameplay() {
        cards.indices.forEach { index ->
            cards[index] = cards[index].copy(
                isFaceUp = false
            )
        }

        acceptingInput.value = true
        previewSeconds.value = 0
    }

    fun tapCard(index: Int): Boolean {
        if (!acceptingInput.value) return false
        if (result.value != GameResult.Playing) return false
        if (index !in cards.indices) return false

        val card = cards[index]

        if (card.isFaceUp || card.isMatched) {
            return false
        }

        if (selectedFirst.value == null) {
            cards[index] = card.copy(isFaceUp = true)
            selectedFirst.value = index
            return true
        }

        if (selectedSecond.value == null && selectedFirst.value != index) {
            cards[index] = card.copy(isFaceUp = true)
            selectedSecond.value = index
            acceptingInput.value = false
            return true
        }

        return false
    }

    fun evaluateSelection(): Boolean? {
        val firstIndex = selectedFirst.value ?: return null
        val secondIndex = selectedSecond.value ?: return null

        if (firstIndex !in cards.indices || secondIndex !in cards.indices) {
            clearSelection()
            return null
        }

        val first = cards[firstIndex]
        val second = cards[secondIndex]

        return if (first.pairId == second.pairId) {
            cards[firstIndex] = first.copy(
                isMatched = true,
                isFaceUp = true
            )

            cards[secondIndex] = second.copy(
                isMatched = true,
                isFaceUp = true
            )

            score.value += POINTS_PER_MATCH
            clearSelection()

            if (cards.all { it.isMatched }) {
                result.value = GameResult.Won
                acceptingInput.value = false
            } else {
                acceptingInput.value = true
            }

            true
        } else {
            score.value = (score.value - PENALTY_PER_MISS).coerceAtLeast(0)

            cards[firstIndex] = first.copy(isFaceUp = false)
            cards[secondIndex] = second.copy(isFaceUp = false)

            clearSelection()
            acceptingInput.value = true

            false
        }
    }

    fun tick() {
        if (!acceptingInput.value) return
        if (result.value != GameResult.Playing) return

        timeLeft.value--

        if (timeLeft.value <= 0) {
            timeLeft.value = 0
            result.value = GameResult.Lost
            acceptingInput.value = false
        }
    }

    private fun clearSelection() {
        selectedFirst.value = null
        selectedSecond.value = null
    }
}
