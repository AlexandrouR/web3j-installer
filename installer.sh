#!/bin/sh
web3j_version="4.5.6"
installed_flag=0
check_if_installed() {
  if [ -x "$(command -v web3j)" ] >/dev/null 2>&1; then
    printf 'A Web3j installation exists on your system: '
    installed_flag=1
  fi
}

setup_color() {
  # Only use colors if connected to a terminal
  if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
  fi
}

install_web3j() {
  echo "Downloading Web3j ..."
  mkdir "$HOME/.web3j"
  if [ "$(curl --write-out "%{http_code}" --silent --output /dev/null "https://github.com/web3j/web3j-cli/releases/download/v${web3j_version}/web3j-${web3j_version}.tar")" -eq 302 ]; then
    curl -# -L -o "$HOME/.web3j/web3j-${web3j_version}.tar" "https://github.com/web3j/web3j-cli/releases/download/v${web3j_version}/web3j-${web3j_version}.tar"
    echo "Installing Web3j..."
    tar -xf "$HOME/.web3j/web3j-${web3j_version}.tar" -C "$HOME/.web3j"
    echo "export PATH=\$PATH:$HOME/.web3j/web3j-${web3j_version}/bin" >"$HOME/.web3j/source.sh"
    chmod +x "$HOME/.web3j/source.sh"
    echo "Removing downloaded archive..."
    rm "$HOME/.web3j/web3j-${web3j_version}.tar"
  else
    echo "Looks like there was an error while trying to download web3j"
    exit 0
  fi
}
get_user_input() {
  while echo "Would you like to update Web3j [Y/n]" && read -r user_input </dev/tty ; do
    case $user_input in
    n)
      echo "Aborting instalation ..."
      exit 0
      ;;
    *)
       echo "Updating Web3j ..."
       break
       ;;
    esac
  done
}

check_version() {
  version_string=$(web3j version | grep Version | awk -F" " '{print $NF}')  
  if [ "$version_string" = "$web3j_version" ]; then
      echo "You have the latest version of Web3j. Exiting."
      exit 0
    else
      echo "Your Web3j version is not up to date."
      get_user_input
  fi
}

source_web3j() {
  SOURCE_WEB3J="\n[ -s \"$HOME/.web3j/source.sh\" ] && source \"$HOME/.web3j/source.sh\""
  if [ -f "$HOME/.bashrc" ]; then
    bash_rc="$HOME/.bashrc"
    touch "${bash_rc}"
    if ! grep -qc '.web3j/source.sh' "${bash_rc}"; then
      echo "Adding source string to ${bash_rc}"
      printf "${SOURCE_WEB3J}\n" >>"${bash_rc}"
    else
      echo "Skipped update of ${bash_rc} (source string already present)"
    fi
  fi
  if [ -f "$HOME/.bash_profile" ]; then
    bash_profile="${HOME}/.bash_profile"
    touch "${bash_profile}"
    if ! grep -qc '.web3j/source.sh' "${bash_profile}"; then
      echo "Adding source string to ${bash_profile}"
      printf "${SOURCE_WEB3J}\n" >>"${bash_profile}"
    else
      echo "Skipped update of ${bash_profile} (source string already present)"
    fi
  fi
  if [ -f "$HOME/.bash_login" ]; then
    bash_login="$HOME/.bash_login"
    touch "${bash_login}"
    if ! grep -qc '.web3j/source.sh' "${bash_login}"; then
      echo "Adding source string to ${bash_login}"
      printf "${SOURCE_WEB3J}\n" >>"${bash_login}"
    else
      echo "Skipped update of ${bash_login} (source string already present)"
    fi
  fi
  if [ -f "$HOME/.profile" ]; then
    profile="$HOME/.profile"
    touch "${profile}"
    if ! grep -qc '.web3j/source.sh' "${profile}"; then
      echo "Adding source string to ${profile}"
      printf "$SOURCE_WEB3J\n" >>"${profile}"
    else
      echo "Skipped update of ${profile} (source string already present)"
    fi
  fi

  if [ -f "$(command -v zsh 2>/dev/null)" ]; then
    file="$HOME/.zshrc"
    touch "${file}"
    if ! grep -qc '.web3j/source.sh' "${file}"; then
      echo "Adding source string to ${file}"
      printf "$SOURCE_WEB3J\n" >>"${file}"
    else
      echo "Skipped update of ${file} (source string already present)"
    fi
  fi
}

check_if_web3j_homebrew() {
  if (command -v brew && ! (brew info web3j 2>&1 | grep -e "Not installed\|No available formula") >/dev/null 2>&1); then
    echo "Looks like Web3j is installed with Homebrew. Please use Homebrew to update. Exiting."
    exit 0
  fi
}

clean_up() {
  if [ -d "$HOME/.web3j" ]; then
    rm -r "$HOME/.web3j" >/dev/null 2>&1
    echo "Deleting older installation ..."
  fi
}

completed() {
  printf '\n'
  printf "$GREEN" 
  echo "Web3j was succesfully installed."
  echo "To use web3j in your current shell run:"
  echo "source \$HOME/.web3j/source.sh"
  echo "When you open a new shell this will be performed automatically."
  echo "To see what web3j's CLI can do you can check the documentation bellow."
  echo "https://docs.web3j.io/command_line_tools/ "
  printf "$RESET" 
  exit 0
}

main() {
  setup_color
  check_if_installed
  if [ $installed_flag -eq 1 ]; then
    check_if_web3j_homebrew
    check_version
    clean_up
    install_web3j
    source_web3j
    completed
   
  else
    clean_up
    install_web3j
    source_web3j
    completed
    
  fi
}

main
