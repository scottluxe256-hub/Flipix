package com.flipfix.game

import android.content.Context
import android.media.MediaPlayer

class AudioPlayer(private val context: Context) {
    private var bgmPlayer: MediaPlayer? = null
    private var sfxPlayer: MediaPlayer? = null

    fun playBgm(assetName: String, enabled: Boolean) {
        if (!enabled) return
        try {
            bgmPlayer?.release()
            val afd = context.assets.openFd(assetName)
            bgmPlayer = MediaPlayer().apply {
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                isLooping = true
                prepare()
                start()
            }
            afd.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun pauseBgm() {
        bgmPlayer?.pause()
    }

    fun resumeBgm() {
        bgmPlayer?.start()
    }

    fun playSfx(assetName: String, enabled: Boolean) {
        if (!enabled) return
        try {
            sfxPlayer?.release()
            val afd = context.assets.openFd(assetName)
            sfxPlayer = MediaPlayer().apply {
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                prepare()
                start()
            }
            afd.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun release() {
        bgmPlayer?.release()
        sfxPlayer?.release()
        bgmPlayer = null
        sfxPlayer = null
    }
}
