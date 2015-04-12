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
    case $1 in
        root) BASHRC=/root/.bashrc ;;
        *) BASHRC=/home/$1/.bashrc ;;
    esac
    touch $BASHRC
    chown $1:$1 $BASHRC

cat <<EOF >> $BASHRC
# Added by archvps script
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias l='ls -alF'
export PATH="$HOME/bin:$PATH"
export PS1='\[\e[1;33m\][\A]\[\e[0m\] \[\e[32m\]\u\[\e[0m\]@\[\e[31m\]\h \[\e[36m\]\W\[\e[m\] \$ '
export EDITOR=vim
export PAGER=less
EOF
}

setup_vimrc() {
    echo "TODO vimrc for $1"
}

setup_screenrc() {
    echo "TODO screenrc for $1"
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
    setup_screen $1

    # Update system and install required packages
    pacman -Syu --noconfirm --quiet
    pacman -S --noconfirm --quiet ${MINIMAL[*]}

    # Add wheel group to sudoers
    sed -i 's/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

    # Setup services
    setup_iptables
    setup_sshd
}

#init

