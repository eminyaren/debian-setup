#!/bin/bash
# LightDM ayarlarını güncelle
if [ -f "./lightdm-gtk-greeter.conf" ]; then
    echo "💡 Giriş ekranı (LightDM) yapılandırılıyor..."
    sudo cp ./lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
    sudo cp ./lightdm.conf /etc/lightdm/lightdm.conf
    
fi

# Sahipliği root'tan kullanıcıya geri alıyoruz
sudo chown -R $USER:$USER ~/.config ~/.themes ~/.bashrc