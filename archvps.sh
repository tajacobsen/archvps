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
    case $1 in
        root) VIMRC=/root/.vimrc ;;
        *) VIMRC=/home/$1/.vimrc ;;
    esac
    touch $VIMRC
    chown $1:$1 $VIMRC

cat <<EOF >> $VIMRC
# Added by archvps script
set nocompatible
syntax enable
filetype plugin indent on
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set number
set ic "ignore case in search patterns 
set linebreak "Do not wrap in the middle of lines
set background=dark
set backspace=indent,eol,start
set hlsearch "HighLightSEARCH
EOF
}

setup_screen() {
    case $1 in
        root) SCREENRC=/root/.screenrc ;;
        *) SCREENRC=/home/$1/.screenrc ;;
    esac
    touch $SCREENRC
    chown $1:$1 $SCREENRC

cat <<EOF >> $SCREENRC
# Added by archvps script
hardstatus on
hardstatus alwayslastline
hardstatus string  "%{.BW}%-w%{.bW}[%n %t]%{-}%+w %=%{..Y} %m/%d %c"
startup_message off
defscrollback 10000
EOF
}

init() {
    # Set root password
    echo "Set password for user root"
    passwd
    setup_bashrc root
    setup_vimrc root

    # Create initial user and set password
    useradd -m -G wheel $1
    echo "Set password for user $1"
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

case $1 in
    init) init $2;;
esac
