# == MY ARCH SETUP INSTALLER == #
#part1
echo "Welcome to Arch Linux Magic Script"
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true

#setup wifi
for i in wlan0 wlp2s0 wlp3s0; do iwctl station $i get-networks
echo "Connect to a wifi network"
read connect; eval $connect

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

pacstrap /mnt base base-devel linux linux-firmware vim man-db doas networkmanager wpa_supplicant

genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' arch_install.sh > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
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
     sxiv mpv zathura zathura-pdf-mupdf imagemagick  \
     fzf man-db xclip zip unzip unrar tlp acpi_call upower tlp-rdw\ 
     ntfs-3g git pipewire pipewire-pulse \
     vim firefox jq axel intel-ucode tree
     

systemctl enable NetworkManager 
systemctl enable tlp 
sytemctl enable upower
echo "USB_AUTOSUSPEND=0" >> /etc/tlp.conf
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

read -p "Enter Username: " username
useradd -m -G wheel,sys -s /bin/bash $username
passwd $username

echo "permit persist consoletree as root" /etc/doas.conf

echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit 

#part3
cd $HOME

# aur - afetch onlyoffice
echo "Installing onlyoffice..."
git clone https://aur.archlinux.org/onlyoffice-bin.git
cd onlyoffice-bin/
echo "Installing afetch..."
git clone https://aur.archlinux.org/afetch.git &
makepkg -si
cd afetch
makepkg -si
cd | rm -rf onlyoffice-bin

echo "Installing adobe connect..."
axel -n 10 https://github.com/mahancoder/Adobe-Connect-Linux/releases/download/v1.0/v1.0.tar.gz
tar xvf v1.0.tar.gz
cd Release
rm -rf flash_player_ppapi_linux.x86_64.tar.gz LGPL manifest.json readme.txt license.pdf  
read -p "Did you find a way to patch for libflashplayer version 32?? [y/n]" answer
if [[ $answer = n ]] ; then
	echo "Installing flash player version 34(patched)"
	axel -n 10 https://github.com/darktohka/clean-flash-builds/releases/download/v1.7/flash_player_patched_npapi_linux.x86_64.tar.gz
	tar xvf flash_player_patched_npapi_linux.x86_64.tar.gz
else
	echo "Installing flash player version 32"
	axel -n 10 https://web.archive.org/web/20210101005931/https://fpdownload.adobe.com/pub/flashplayer/pdc/32.0.0.465/flash_player_ppapi_linux.x86_64.tar.gz
	tar xvf flash_player_ppapi_linux.x86_64.tar.gz
fi

doas ./install.sh

# mkinicpio - systemd => (base, udev)

exit



