#!/bin/bash

# Gerekli araçların kontrolü
if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
    sudo apt update && sudo apt install -y curl jq
fi

INSTALL_DIR="/opt/blender"

# 1. Mevcut Yüklü Sürümü Kontrol Et
CURRENT_VER="Yok"
if [ -f "$INSTALL_DIR/blender" ]; then
    # blender --version komutu "Blender 4.2.0" şeklinde çıktı verir
    CURRENT_VER=$($INSTALL_DIR/blender --version | head -n 1 | awk '{print $2}')
fi

echo "Şu anki sürüm: $CURRENT_VER"

# 2. İnternetteki En Güncel Sürümü Tespit Et
echo "Güncel sürüm kontrol ediliyor..."
# Blender yansı listesinden en yüksek sürüm numarasını çeker
REMOTE_VER=$(curl -s https://mirrors.dotsrc.org/blender/release/ | grep -oP 'Blender\K[0-9]+\.[0-9]+' | sort -V | tail -n 1)

# Alt sürümü (patch) bulmak için ilgili klasöre bak
PATCH_VER=$(curl -s "https://mirrors.dotsrc.org/blender/release/Blender$REMOTE_VER/" | grep -oP "blender-\K$REMOTE_VER\.[0-9]+" | sort -V | tail -n 1)

if [ -z "$PATCH_VER" ]; then
    echo "Hata: Güncel sürüm bilgisi alınamadı."
    exit 1
fi

echo "En son kararlı sürüm: $PATCH_VER"

# 3. Karşılaştırma ve Karar
if [ "$CURRENT_VER" == "$PATCH_VER" ]; then
    echo "Sisteminizdeki Blender zaten güncel ($CURRENT_VER). İşlem iptal edildi."
    exit 0
fi

# 4. İndirme ve Kurulum
FILENAME="blender-${PATCH_VER}-linux-x64.tar.xz"
DOWNLOAD_URL="https://mirrors.dotsrc.org/blender/release/Blender$REMOTE_VER/$FILENAME"

echo "Yeni sürüm bulundu! İndiriliyor: $PATCH_VER"
curl -L -f "$DOWNLOAD_URL" -o "/tmp/$FILENAME"

if [ $? -eq 0 ]; then
    echo "Kurulum yapılıyor..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo rm -rf "$INSTALL_DIR"/*
    sudo tar -xJf "/tmp/$FILENAME" -C "$INSTALL_DIR" --strip-components=1
    
    # Sistem entegrasyonu
    sudo ln -sf "$INSTALL_DIR/blender" /usr/local/bin/blender
    
    # Masaüstü dosyası güncelleme
    cat <<EOF > ~/.local/share/applications/blender.desktop
[Desktop Entry]
Name=Blender $PATCH_VER
GenericName=3D Modeler
Exec=$INSTALL_DIR/blender %f
Icon=$INSTALL_DIR/blender.svg
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;
EOF

    rm "/tmp/$FILENAME"
    echo "--- Blender $PATCH_VER Başarıyla Kuruldu ---"
else
    echo "Hata: İndirme başarısız oldu."
    exit 1
fi