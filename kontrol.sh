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

echo "--- Devuan Derinlemesine Depo Analizi ---"

# Tüm aktif depo tanımlarını bir havuzda topla (sources.list ve sources.list.d altındaki tüm dosyalar)
ALL_ACTIVE_SOURCES=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources 2>/dev/null | grep -v '^#')

for COMP in "${TARGET_COMPONENTS[@]}"; do
    # Hassas regex ile bileşen kontrolü
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

echo "Eksik olanlar ekleniyor: ${MISSING_COMPS[*]}"

# 1. Mevcut aktif aynayı (Mirror) bul
MIRROR_URL=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null | grep -v '^#' | grep "main" | head -n 1 | awk '{print $2}')

# Eğer ayna bulunamazsa Devuan varsayılan aynasını ata
if [ -z "$MIRROR_URL" ] || [ "$MIRROR_URL" == " " ]; then
    echo "⚠️ Sistem aynası tespit edilemedi, varsayılan Devuan aynası atanıyor..."
    MIRROR_URL="http://pkgmaster.devuan.org/merged"
fi

# 2. Sürüm adını (Suite) kesinleştir (daedalus, excalibur vb.)
SUITE=$(lsb_release -cs 2>/dev/null)
if [ -z "$SUITE" ]; then
    # lsb_release yoksa dosyadan oku
    SUITE=$(cut -d' ' -f1 /etc/devuan_version 2>/dev/null | tr '[:upper:]' '[:lower:]')
    [ -z "$SUITE" ] && SUITE="daedalus"
fi

echo "🔗 Kullanılacak Ayna: $MIRROR_URL"
echo "📂 Sürüm (Suite): $SUITE"

# 3. Yeni DEB822 formatında kaynak dosyasını oluştur
cat <<EOF > "$NEW_FILE"
Types: deb deb-src
URIs: $MIRROR_URL
Suites: $SUITE ${SUITE}-updates ${SUITE}-backports
Components: ${MISSING_COMPS[*]}
Signed-By: /usr/share/keyrings/devuan-archive-keyring.gpg
EOF

echo "[BAŞARILI] $NEW_FILE dosyası oluşturuldu."
echo "------------------------------------------"
cat "$NEW_FILE"
echo "------------------------------------------"