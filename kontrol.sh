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

# ... (Üst kısımlar aynı) ...

echo "--- Devuan Depo Analizi ---"

# ... (Analiz döngüsü aynı) ...

# Devuan için Mirror ve Suite ayarlarını güncelle
MIRROR_URL=$(grep -v '^#' /etc/apt/sources.list | grep "main" | head -n 1 | awk '{print $2}')

# URL boş gelirse varsayılan Devuan aynasını kullan
if [ -z "$MIRROR_URL" ]; then
    MIRROR_URL="http://pkgmaster.devuan.org/merged"
fi

# Devuan sürüm adını otomatik tespit et (daedalus, excalibur vb.)
SUITE=$(lsb_release -cs 2>/dev/null || echo "daedalus")

cat <<EOF > "$NEW_FILE"
Types: deb deb-src
URIs: $MIRROR_URL
Suites: $SUITE ${SUITE}-updates ${SUITE}-backports
Components: ${MISSING_COMPS[*]}
Signed-By: /usr/share/keyrings/devuan-archive-keyring.gpg
EOF

echo "[BAŞARILI] $NEW_FILE dosyası oluşturuldu."
# ... (Alt kısımlar aynı) ...
echo "------------------------------------------"
cat "$NEW_FILE"
echo "------------------------------------------"
