package com.flipfix.game

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun StyledButton(
    text: String,
    backgroundColor: Color,
    textColor: Color = Color.White,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .width(180.dp)
            .height(50.dp)
            .shadow(6.dp, RoundedCornerShape(25.dp))
            .clip(RoundedCornerShape(25.dp))
            .background(backgroundColor)
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = textColor
        )
    }
}

@Composable
fun IconButtonWithShadow(
    iconRes: Int,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .size(48.dp)
            .shadow(4.dp, CircleShape)
            .clip(CircleShape)
            .background(Color.White)
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Icon(
            painter = painterResource(id = iconRes),
            contentDescription = "Button Icon",
            tint = Color(0xFF37474F),
            modifier = Modifier.size(24.dp)
        )
    }
}
