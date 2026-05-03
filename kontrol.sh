#!/bin/bash

# Root kontrolü
if [ "$EUID" -ne 0 ]; then 
  echo "Lütfen sudo ile çalıştırın."
  exit 1
fi

# Ayarlar
TARGET_COMPONENTS=("contrib" "non-free" "non-free-firmware")
NEW_FILE="/etc/apt/sources.list.d/extra-components.sources"
MISSING_COMPS=()

echo "--- Debian 13 Derinlemesine Depo Analizi ---"

# Tüm aktif depo tanımlarını bir havuzda topla (Sadece okuma)
# sources.list ve sources.list.d altındaki tüm dosyaları birleştirip yorumları temizliyoruz
ALL_ACTIVE_SOURCES=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources 2>/dev/null | grep -v '^#')

for COMP in "${TARGET_COMPONENTS[@]}"; do
    # Regex açıklaması:
    # (?<=[[:space:]/]) : Önünde boşluk veya / olsun
    # (?=[[:space:]]|$) : Sonunda boşluk veya satır sonu olsun
    # Bu sayede 'non-free' ararken 'non-free-firmware' asla eşleşmez.
    
    if echo "$ALL_ACTIVE_SOURCES" | grep -Pq "(^|[[:space:]/])$COMP([[:space:]]|$)"; then
        echo "[TAMAM] '$COMP' sistemde zaten tanımlı."
    else
        echo "[EKSİK] '$COMP' bulunamadı!"
        MISSING_COMPS+=("$COMP")
    fi
done

# Eğer her şey tamamsa çık
if [ ${#MISSING_COMPS[@]} -eq 0 ]; then
    echo "Analiz bitti: Eksik bileşen yok."
    exit 0
fi

# Yeni dosyayı oluşturma (Eski dosyaya dokunmuyoruz)
echo "Eksik olanlar ekleniyor: ${MISSING_COMPS[*]}"

# Mevcut ana ayna adresini çek (Hata payını azaltmak için 'main' içeren ilk satırı alıyoruz)
MIRROR_URL=$(grep -v '^#' /etc/apt/sources.list | grep "main" | head -n 1 | awk '{print $2}')

# URL boş gelirse varsayılan Debian aynasını kullan
if [ -z "$MIRROR_URL" ]; then
    MIRROR_URL="http://deb.debian.org/debian"
fi

cat <<EOF > "$NEW_FILE"
Types: deb deb-src
URIs: $MIRROR_URL
Suites: trixie trixie-updates trixie-backports
Components: ${MISSING_COMPS[*]}
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

echo "[BAŞARILI] $NEW_FILE dosyası oluşturuldu."
echo "------------------------------------------"
cat "$NEW_FILE"
echo "------------------------------------------"
