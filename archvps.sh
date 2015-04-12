#!/usr/bin/sh

MINIMAL=('vim-minimal' 'sudo' 'iptables')

setup_iptables() {
    echo "TODO: Write iptables.rules"
    systemctl enable iptables
    systemctl start iptables
}

setup_sshd() {
    echo "TODO: disable ssh rootlogin"
    systemctl restart sshd
}

setup_bashrc() {
    echo "TODO bashrc for $1"
}

setup_vimrc() {
    echo "TODO vimrc for $1"
}

init() {
    # Set root password
    passwd
    setup_bashrc root
    setup_vimrc root

    # Create initial user and set password
    useradd -m -G wheel $1
    passwd $1
    setup_bashrc $1
    setup_vimrc $1

    # Update system
    pacman -Syu --noconfirm --quiet

    # Install required packages
    pacman -S --noconfirm --quiet ${MINIMAL[*]}

    # Add wheel group to sudoers
    sed -i 's/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

    # Setup services
    setup_iptables
    setup_sshd
}

#init

