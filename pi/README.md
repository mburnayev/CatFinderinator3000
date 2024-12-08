# README
## Configuring the RPi
Run `setup.sh` with sudo and everything should get nicely configured
`setup.sh` features three stages:
- Stage 1: Setting up the Raspberry Pi
- Stage 2: Downloading and installing Python 3.9.2
- Stage 3: Setting up the Python virtual environment

Additional details can be found inside the script

setup.sh also requires a txt file that has the desired IP address on the local network
you want the RPI to try to obtain by default

## Note to self:
- Reattach with `tmux attach` once logged in
- If after the script is stopped, restarted, and the camera can't be found, unplug it and plug it
  back in and look in /dev/ for the lowest video# -> that will be the new capture index
- Restarting the pi will reset /dev/video index back to 0

## Resources
Resources used to create setup script:
- [Stage 1](https://www.tomshardware.com/how-to/static-ip-raspberry-pi)
- [Stage 2](https://itheo.tech/install-python-39-on-raspberry-pi)
