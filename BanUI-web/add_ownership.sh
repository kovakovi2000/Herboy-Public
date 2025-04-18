sudo chown -R www-data:www-data /var/www/html/herboyd2.hu/public/bansysv2_webui
sudo find /var/www/html/herboyd2.hu/public/bansysv2_webui -type d -exec chmod 755 {} \;
sudo find /var/www/html/herboyd2.hu/public/bansysv2_webui -type f -exec chmod 644 {} \;
ls -la /var/www/html/herboyd2.hu/public/bansysv2_webui
