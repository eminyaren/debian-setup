#!/bin/bash

# --- Geri Sayım Barı (printf ile) ---
secs=10
msg="Sistem yeniden başlatılıyor"

while [ $secs -gt 0 ]; do
    # Çubuk hesaplaması
    # %-10s: 10 karakterlik alan ayır ve sola yasla
    progress_bar=$(printf "%${secs}s" | tr ' ' '#')
    dots=$(printf "%$((10-secs))s" | tr ' ' '.')
    
    # \r imleci başa döndürür
    # %s ile metni ve barı hizalı şekilde basar
    printf "\r%s [%-10s] %2d sn... " "$msg" "${progress_bar}${dots}" "$secs"
    
    sleep 1
    ((secs--))
done

printf "\nŞimdi yeniden başlatılıyor!\n"
