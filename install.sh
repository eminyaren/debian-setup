#!/bin/bash

# 1. Depo Kontrolü (kontrol.sh)
if [ -f "./kontrol.sh" ]; then
    chmod +x ./kontrol.sh
    sudo ./kontrol.sh
else
    echo "Hata: kontrol.sh bulunamadı!"
    exit 1
fi

# 2. Sistem Güncelleme[cite: 2, 3]
echo "Sistem güncelleniyor..."
sudo apt update

# 3. Donanım Kontrolü ve Paket Kurulumu
echo "Donanım taranıyor..."
sudo apt-get install -y nvidia-detect > /dev/null

# Nvidia kartı var mı kontrol et
NVIDIA_CHECK=$(nvidia-detect)

# Temel paket listesi (Nvidia hariç)
PACKAGES=(
    curl git kitty blueman lightdm-gtk-greeter-settings 
    lightdm-settings yaru-theme-gtk yaru-theme-icon 
    build-essential linux-headers-$(uname -r)
)

# Eğer çıktı "it is recommended to install the nvidia-driver package" içeriyorsa
if echo "$NVIDIA_CHECK" | grep -q "nvidia-driver"; then
    echo "Nvidia ekran kartı tespit edildi, sürücü listeye ekleniyor."
    PACKAGES+=("nvidia-driver")
else
    echo "Nvidia ekran kartı bulunamadı, sürücü kurulumu atlanıyor."
fi

# Şimdi tüm paketleri tek seferde kur
INSTALL_LOG=$(sudo apt-get install -y "${PACKAGES[@]}")
echo "$INSTALL_LOG"

REBOOT_REQUIRED=false
if echo "$INSTALL_LOG" | grep -qE "newly installed|upgraded|reinstalled"; then
    if ! echo "$INSTALL_LOG" | grep -q "0 upgraded, 0 newly installed"; then
        REBOOT_REQUIRED=true
    fi
fi

# 4. Brave Tarayıcı Kontrolü[cite: 2, 3]
if ! command -v brave-browser &> /dev/null; then
    echo "Brave kuruluyor..."
    curl -fsS https://dl.brave.com/install.sh | sh
    REBOOT_REQUIRED=true
fi

# 5. Yapılandırma Dosyaları ve Terminal Seçimi
echo "Konfigürasyonlar kontrol ediliyor..."
mkdir -p ~/.config ~/.themes
cp -ru ./.config/* ~/.config/
cp -ru ./.themes/* ~/.themes/
cp ./.bashrc ~/.bashrc

# Kitty'yi varsayılan terminal olarak ayarla[cite: 3]
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

# 6. Akıllı Blender Güncelleme (Yeni Bölüm)
if [ -f "./blender_update.sh" ]; then
    chmod +x ./blender_update.sh
    ./blender_update.sh
else
    echo "Uyarı: blender_update.sh bulunamadı, Blender kontrolü atlanıyor."
fi

# 7. Final Kararı ve Sayaç[cite: 2, 3]
if [ "$REBOOT_REQUIRED" = true ]; then
    echo -e "\n--- SİSTEMDE KRİTİK DEĞİŞİKLİK YAPILDI ---"
    if [ -f "./sayac.sh" ]; then
        chmod +x ./sayac.sh
        ./sayac.sh
    else
        echo "Yeniden başlatılıyor..."
        sleep 5
        sudo reboot #[cite: 2]
    fi
else
    echo -e "\n--- SİSTEM ZATEN GÜNCEL ---"
    echo "Yeniden başlatmaya gerek duyulmadı."
fi
