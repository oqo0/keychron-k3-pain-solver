#!/bin/bash


# fn + f keys fix
echo ""
read -p "Do you want to perform fn + f keys fix? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
FNMODE=""
  while [[ $((FNMODE)) != $FNMODE ]]
  do
    echo "Fn + f keys options"
    echo "0 - Disable the fn key. Pressing fn+F8 will behave like you only press F8"
    echo "1 - Function keys are used as last key. Pressing F8 key will act as a special key. Pressing fn+F8 will behave like a F8."
    echo "2 - Function keys are used as first key. Pressing F8 key will behave like a F8. Pressing fn+F8 will act as special key (play/pause)."
    echo "Select one option:"
    read FNMODE
  done
  echo "options hid_apple fnmode=$FNMODE" | sudo tee /etc/modprobe.d/hid_apple.conf
  sudo dracut --regenerate-all
fi


# keyboard won't reconnect after sleep fix
echo ""
read -p "Do you want to perform keyboard reconnect after sleep fix? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "options btusb enable_autosuspend=n" | sudo tee /etc/modprobe.d/btusb_disable_autosuspend.conf
  sudo dracut --regenerate-all
  sudo modprobe -r btusb
  sudo systemctl restart bluetooth
  sudo modprobe btusb
fi


# bluetooth fix
echo ""
read -p "Do you want to perform bluetooth fix? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  CONFIG_FILE='/etc/bluetooth/main.conf'
  sed -c -i "s/\('FastConnectable' *= *\).*/\1'true'/" $CONFIG_FILE
  sed -c -i "s/\('ReconnectAttempts' *= *\).*/\1'15'/" $CONFIG_FILE
  sed -c -i "s/\('ReconnectIntervals' *= *\).*/\1'1, 2, 3, 5'/" $CONFIG_FILE
fi


# bluetooth after waking up from sleep fix
echo ""
read -p "Do you want to perform bluetooth after waking up from sleep fix? [y/N] " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo ""
  exit 0
fi

echo ""
sudo tee /lib/systemd/system-sleep/bt << EOT
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
