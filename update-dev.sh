sudo chown -R mloiseleur:mloiseleur *
rake log:clear
rake tmp:clear
cvs up
sudo chown -R www-data:www-data *
sudo /etc/init.d/apache2 restart

