#!/usr/bin/env bash

RESET="\e[0m"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
GRAY="\e[90m"

log_info(){
    echo -e "${BLUE}[INFO]${RESET} $1"
}

log_success(){
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${RESET} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${RESET} $1"
}

log_skipped() {
  echo -e "${GRAY}[SKIPPED]${RESET} $1"
}

check_root(){
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    else
        log_success "Running as root"
    fi
}

check_internet(){
    log_info "Checking internet connectivity"

    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        log_success "Internet connection is available"
        return 0
    else
        log_warning "No internet connection detected. Network-dependent step will be skipped"
        return 1
    fi
}

check_docker_installed(){
    log_info "Checking if Docker is already installed"

    if command -v docker > /dev/null 2>&1; then
        log_skipped "Docker is alreadt installed"
        return 0
    else
        log_info "Docker is not installed"
        return 1
    fi
}

apt_update(){
    if [ "$INTERNET_AVAILABLE" -ne 0 ]; then
        log_skipped "Internet not available, skipping apt update"
        return 0
    fi

    log_info "Update package lists (apt update)"

    if apt update -y > /dev/null 2>&1; then
        log_success "Package lists updated successfully"
        return 0
    else
        log_error "apt update failed"
        exit 1
    fi
}

install_required_packages(){
    if [ "$DOCKER_INSTALLED" -eq 0 ]; then
        log_skipped "Docker already installd, skipping required packages"
        return 0
    fi

    if [ "$INTERNET_AVAILABLE" -ne 0 ]; then
        log_skipped "Internet not available, skipping required packages installation"
        return 0
    fi

    log_info "İnstalling required packages for Docker"

    if apt install -y ca-certificates curl gnupg lsb-release > /dev/null 2>&1; then
        log_success "Required packages installed successfully"
        return 0
    else 
        log_error "Failed to install required packages"
        exit 1
    fi
}

check_root
check_internet
INTERNET_AVAILABLE=$?


check_docker_installed
DOCKER_INSTALLED=$?

apt_update
install_required_packages
