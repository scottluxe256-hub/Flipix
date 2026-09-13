package flipfix

import androidx.compose.ui.window.Window
import androidx.compose.ui.window.WindowState
import androidx.compose.ui.window.application
import androidx.compose.ui.unit.dp

fun main() = application {
    Window(
        onCloseRequest = ::exitApplication,
        title = "FlipFix",
        state = WindowState(
            width = 1280.dp,
            height = 720.dp
        ),
        resizable = true
    ) {
        FlipFixApp()
    }
}