#!/bin/bash


# Fn + F-keys fix
echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf
sudo dracut --regenerate-all


# Bluetooth fix
CONFIG_FILE='/etc/bluetooth/main.conf'
sed -c -i "s/\('FastConnectable' *= *\).*/\1'true'/" $CONFIG_FILE
sed -c -i "s/\('ReconnectAttempts' *= *\).*/\1'15'/" $CONFIG_FILE
sed -c -i "s/\('ReconnectIntervals' *= *\).*/\1'1, 2, 3, 5'/" $CONFIG_FILE


# Bluetooth after waking up from sleep fix
sudo tee /lib/systemd/system-sleep/bt << EOT
#!/bin/sh
case $1 in
  post)
    modprobe -r btusb
    sleep 1
    service bluetooth restart
    sleep 1
    modprobe btusb
    ;;
esac
EOT
sudo chmod +x /lib/systemd/system-sleep/bt
