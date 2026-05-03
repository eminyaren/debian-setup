# 🚀 Debian 13 (Trixie) Kurulum Sihirbazı & Akıllı Blender Güncelleyici

Bu depo, Debian 13 (Trixie) sisteminizi saniyeler içinde modernize etmek, gerekli sürücüleri kurmak ve Blender'ın her zaman en güncel sürümde kalmasını sağlamak için tasarlanmış profesyonel bir otomasyon setidir.

## ✨ Öne Çıkan Özellikler

*   **Akıllı Kurulum:** Sistemde zaten yüklü olan paketleri kontrol eder, sadece gerekenleri kurar ve gereksiz yeniden başlatma (reboot) talep etmez.
*   **Otomatik Blender Güncelleyici:** Blender'ın resmi yansılarını tarayarak en güncel kararlı sürümü (5.x+) tespit eder, mevcut sürümle karşılaştırır ve gerekliyse otomatik günceller.
*   **Modern Terminal Deneyimi:** GPU tabanlı `kitty` terminalini kurar, varsayılan yapar ve özelleştirilmiş, renkli bir `.bashrc` arayüzü uygular.
*   **Donanım Desteği:** Nvidia sürücülerini ve gerekli firmware paketlerini (`non-free`) otomatik olarak yapılandırır.
*   **Güvenli Geçiş:** Kritik işlemlerden sonra kullanıcıya 10 saniyelik bir nefes payı tanıyan bir geri sayım mekanizması içerir.

## 🛠️ İçerikte Neler Var?

| Dosya | Açıklama |
| :--- | :--- |
| `install.sh` | Ana kurulum scripti. Tüm süreci yöneten orkestra şefi. |
| `blender_update.sh` | Blender sürüm kontrolü ve güncelleme otomasyonu. |
| `kontrol.sh` | Debian depo (repository) ve non-free paket kontrolleri. |
| `sayac.sh` | Kritik işlemlerden sonra devreye giren görsel geri sayım aracı. |
| `.bashrc` | Terminali renklendiren ve verimlilik artıran özel konfigürasyon. |

## 🚀 Hızlı Başlama

Sisteminizi modernize etmek için terminalinizi açın ve şu komutları sırasıyla çalıştırın:
```bash
# Depoyu klonlayın
git clone git@github.com:eminyaren/debian-setup.git

# Klasöre girin
cd debian-setup

# Yetkileri verin ve sihirbazı başlatın
chmod +x *.sh
./install.sh