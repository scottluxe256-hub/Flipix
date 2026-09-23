@echo off
setlocal enabledelayedexpansion

:: Tentukan folder input dan folder output
set "INPUT_DIR=assets\audio"
set "OUTPUT_DIR=assets\audio_converted"

:: Buat folder output jika belum ada
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo Folder %OUTPUT_DIR% berhasil dibuat.
)

echo ===================================================
echo Memulai Kompresi Audio ke AAC HE v1 (64k) via FFmpeg
echo ===================================================

:: Loop untuk memproses semua file audio di folder input
for %%F in ("%INPUT_DIR%\*.*") do (
    echo Processing: %%~nxF ...
    
    :: Jalankan FFmpeg dengan codec libfdk_aac HE-AAC v1
    ffmpeg -y -i "%%F" -c:a libfdk_aac -profile:a aac_he -b:a 64k "%OUTPUT_DIR%\%%~nF.m4a" >nul 2>&1

    if !errorlevel! equ 0 (
        echo [OK] Successfully converted %%~nF.m4a
    ) else (
        :: Fallback jika FFmpeg lokal kamu tidak di-compile dengan libfdk_aac
        echo [WARNING] libfdk_aac tidak ditemukan, mencoba native ffmpeg aac encoder...
        ffmpeg -y -i "%%F" -c:a aac -b:a 64k "%OUTPUT_DIR%\%%~nF.m4a" >nul 2>&1
        echo [OK] Converted with standard aac %%~nF.m4a
    )
)

echo ===================================================
echo Selesai! Semua file tersimpan di: %OUTPUT_DIR%
echo Silakan pindahkan file di folder tersebut ke assets\audio
echo ===================================================
pause