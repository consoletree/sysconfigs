# == MY ARCH SETUP INSTALLER == #
# part1
	echo "Welcome to Arch Linux Magic Script"
	pacman --noconfirm -Sy archlinux-keyring
	loadkeys us
	timedatectl set-ntp true

# setup wifi
	for i in wlan0 wlp2s0 wlp3s0; do iwctl station $i get-networks
	echo "Connect to a wifi network"
	read connect; eval $connect

# Setup partitions
	lsblk
	read -p "Enter the drive: " drive
	cfdisk $drive 
	read -p "Enter the linux partition: " partition
	mkfs.ext4 $partition 
	mount $partition /mnt 
	read -p "Did you also create efi partition? [y/n]" answer
	if [[ $answer = y ]] ; then
		read -p "Enter EFI partition: " efipartition
		mkfs.fat -F 32 $efipartition
		mkdir -p /mnt/boot
		mount $efipartition /mnt/boot
	fi

	read -p "Enter the swap size (in GB): " swapsize
	head -c $swapsize\G\B /dev/zero > /swap
	chmod 600 /swap
	mkswap /swap
	swapon /swap

# setup chroot stuffs
	pacstrap /mnt base base-devel linux linux-firmware vim man-db doas networkmanager wpa_supplicant

	genfstab -U /mnt >> /mnt/etc/fstab

# part 1 complete
	sed '1,/^#part2$/d' arch_install.sh > /mnt/arch_install2.sh
	chmod +x /mnt/arch_install2.sh
	arch-chroot /mnt ./arch_install2.sh
	exit 

# Configuring System
	ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
	hwclock --systohc
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
	echo "LANG=en_US.UTF-8" > /etc/locale.conf
	echo "KEYMAP=us" > /etc/vconsole.conf
	read -p "Hostname: " hostname
	echo $hostname > /etc/hostname
	echo "127.0.0.1       localhost" >> /etc/hosts
	echo "::1             localhost" >> /etc/hosts
	echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

	mkinitcpio -P

	passwd

	pacman -S --noconfirm xorg-server xorg-xinit xorg-xsetroot xorg-xbacklight\
			 sxiv mpv zathura zathura-pdf-mupdf imagemagick xclip   \
			 fzf zip unzip unrar tlp acpi_call upower tlp-rdw youtube-dl \ 
			 ntfs-3g git pipewire pipewire-pulse \
			 firefox jq axel intel-ucode tree
	pacman -Rns sudo
     

# Enabling system services
	systemctl enable NetworkManager 

	# For power saving
		systemctl enable tlp 
		sytemctl enable upower
		echo "USB_AUTOSUSPEND=0" >> /etc/tlp.conf
		systemctl mask systemd-rfkill.service
		systemctl mask systemd-rfkill.socket

# Creating user and its permissions	
	read -p "Enter Username: " username
	useradd -m -G wheel,sys -s /bin/bash $username
	passwd $username
	echo "permit persist $username as root" > /etc/doas.conf

# from consoletree/sysconfigs 
	bootctl --path=/boot install
	git clone https://github.com/consoletree/sysconfigs
	cp -r sysconfigs/boot/loader/entries/* /boot/loader/entries/*
	cp -r sysconfigs/boot/loader/loader.conf /boot/loader/loader.conf
	rm -rf sysconfigs/boot
	cp -r sysconfigs/etc/mkinitcpio.conf /etc/mkinitcpio.conf
	cp -r sysconfigs/etc/vimrc /etc/vimrc
	rm -rf sysconfigs/etc
	mkdir -p /usr/share/fonts/ttf/
	cp -r sysconfigs/usr/share/fonts/ttf/MonoLisa-Regular.ttf /usr/share/fonts/ttf/
	rm -rf sysconfigs/usr
  mv sysconfigs/home/consoletree/* /home/$username/ 	
	rm -rf sysconfigs
	mkdir -p /home/$username/.local/src	

# part 2 complete
	echo "Pre-Installation Finish Reboot now"
	ai3_path=/home/$username/arch_install3.sh
	sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
	chown $username:$username $ai3_path
	chmod +x $ai3_path
	su -c $ai3_path -s /bin/sh $username
	exit 

# part3
	cd $HOME

# cause it sucks
	git clone https://github.com/consoletree/suckless
	git clone https://aur.archlinux.org/libxft-bgra.git
	cd libxft-bgra && makepkg -si
	cd suckless/dmenu-5.0/ && doas make clean install; cd
	cd suckless/dwm-6.2/ && doas make clean install; cd
	cd suckless/slock-1.4/ && doas make clean install; cd
	cd suckless/st-0.8.4/ && doas make clean install; cd
	cd suckless/wmname-0.1/ && doas make clean install; cd
	mv suckless/* .local/src/
	rm -rf libxft-bgra/

# aur - afetch, onlyoffice
	echo "Installing onlyoffice..."
	git clone https://aur.archlinux.org/onlyoffice-bin.git
	cd onlyoffice-bin/
	echo "Installing afetch..."
	git clone https://aur.archlinux.org/afetch.git &
	makepkg -si
	cd afetch
	makepkg -si
	cd | rm -rf onlyoffice-bin

# Install adobe connect
	echo "Installing adobe connect..."
	axel -n 10 https://github.com/mahancoder/Adobe-Connect-Linux/releases/download/v1.0/v1.0.tar.gz
	tar xvf v1.0.tar.gz
	cd Release
	rm -rf flash_player_ppapi_linux.x86_64.tar.gz LGPL manifest.json readme.txt license.pdf  
	#axel -n 10 https://download2278.mediafire.com/ukv5b22i8vng/h87715s3w9xebf0/libpepflashplayer.so 
	axel -n 10 https://0x0.st/-Rog.so
	mv ./-Rog.so libpepflashplayer.so
	doas ./install.sh
	cd $HOME
	rm -rf Release

# part 3 complete
	startx
