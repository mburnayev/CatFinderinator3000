# PP (personal project) Documentation

Allowing File Sharing through UTM
	- choose directory as mount point
		- make sure FTP permissions are enabled for this directory
	- enable file sharing on UTM
		- make sure ‘Directory Share Mode’ has SPICE WebDAV selected
		- select directory mentioned above in ‘Shared Directory’
	- once VM is online, check to see if ‘Spice Client Folder’ is available under Networks
		- if not, run sudo apt install spice-vdagent spice-webdavd and restart the VM

Installing Python 3.9:	
	- sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev curl software-properties-common
	- sudo apt install build-essential python-dev python-setuptools python-pip python-smbus libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libffi-dev
	- sudo apt-get install libbz2-dev (might help in the event your system doesn’t already have the library for whatever reason)
	- cd [project directory]
	- wget https://www.python.org/ftp/python/3.9.4/Python-3.9.4.tar.xz
	- tar -xf Python-3.9.4.tar.xz
	- cd Python-3.9.4
	- ./configure (this may take a while)
	- sudo make (this may take a while)
	- sudo make install (this may take a while)

Create and activate virtual environment
	- cd .. (back to Python download point)
	- python3.9 -m venv [env name] (this may take a while)
	- source [env name]/bin/activate
		- to deactivate venv, enter ‘deactivate’

Setting up tflite model maker:
	- pip install tflite-model-maker —use-feature=2020-resolver (this may take a while)
		- MAKE SURE THERE ARE 0 ERRORS (warnings are ok)
	- pip install numpy==1.23.4 (to resolve AttributeError: module ‘numpy’ has no attribute ‘object’)Creating a custom model:	- create file containing model-making code
	- make sure you have just images in your training/testing data
	- make sure pathing to images is correct, should be as follows:		
		- images
			- class 1
				- class1img1.png
				- class1img2.png
				- …
			- class x
				- classximg1.png
				- ...
	- python model.py (this will take a while, roughly 3 hours?)

Pi setup:
	- sudo apt-get update
	- sudo apt-get upgrade
	- sudo apt-get install cmake
	- sudo apt install python3-opencv	
    - sudo apt-get install openexr
    -—	
	- See Installing Python 3.9	—
	--
	- pip install --upgrade pip setuptools wheel
	- pip install pyrebase
	- pip install cmake
	- pip install numpy==1.19.3

	? pip install opencv-python-headless

	- pip install opencv-python
		-> Problem with the CMake installation, aborting build. CMake executable is /tmp/pip-build-env-yo78dif5/overlay/lib/python3.9/site-packages/cmake/data/bin/cmake
		-> ERROR: Could not build wheels for opencv-python, which is required to install pyproject.toml-based projects
		
	- pip install opencv-python==4.5.3.56
		- successful install
		- on run produces error:
			-> ImportError: libIlmImf-2_5.so.25: cannot open shared object file: No such file or directory

	- wget https://www.python.org/ftp/python/3.8.10/Python-3.8.10.tgz

	- sudo apt-get update
	- sudo apt-get install software-properties-common
	- sudo add-apt-repository ppa:deadsnakes/ppa
	- sudo apt-get update
	- sudo apt install python3.9.2

Pi setup from fresh install:
	- sudo apt-get update --allow-releaseinfo-change
	- sudo apt-get upgrade
	- sudo apt-get install vim
	- change ~/.bashrc to fix PATH variable so /usr/bin/ is the first location checked for binaries

To install all prereqs on Pi,
- upgrade python to python3
- upgrade pip to pip3?
- pip3 install opencv-python
- sudo apt-get install libatlas-base-dev
- pip install tensorflow
- pip install micropython-cpython-uos

	

