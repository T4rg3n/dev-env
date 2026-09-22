LOG=/home/victor/Documents/my-dev-env/.cursor/debug-85fb34.log
echo "===== BEFORE =====" > "$LOG"
dkms status >> "$LOG" 2>&1
lsmod | grep evdi >> "$LOG" 2>&1 || echo "evdi not loaded" >> "$LOG"
for c in /sys/class/drm/card*-*/status; do echo "$c: $(cat $c)" >> "$LOG"; done
echo "===== BUILD =====" >> "$LOG"
sudo dkms install evdi/1.14.16 -k 7.2.5-200.fc44.x86_64 >> "$LOG" 2>&1
echo "===== RESTART =====" >> "$LOG"
sudo systemctl restart displaylink-driver.service >> "$LOG" 2>&1
sleep 4
echo "===== AFTER =====" >> "$LOG"
dkms status >> "$LOG" 2>&1
lsmod | grep evdi >> "$LOG" 2>&1 || echo "evdi still not loaded" >> "$LOG"
systemctl is-active displaylink-driver.service >> "$LOG" 2>&1
systemctl status displaylink-driver.service --no-pager >> "$LOG" 2>&1
for c in /sys/class/drm/card*-*/status; do echo "$c: $(cat $c)" >> "$LOG"; done
ls /dev/dri/ >> "$LOG" 2>&1
journalctl -b 0 --no-pager -u displaylink-driver.service --since "1 minute ago" >> "$LOG" 2>&1
echo "===== DONE =====" >> "$LOG"
