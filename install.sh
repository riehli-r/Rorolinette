#!/usr/bin/env bash
# Author: massard-t <massar_t@etna-alternance.net>

readonly PREFIX="${PREFIX:-/usr/local}"
readonly REPO_URL="https://github.com/riehli-r/Rorolinette"
readonly LOG_FILE="/tmp/$(basename "\$0").log"

info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal() { echo "[FATAL] $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

TMPDIR="$(mktemp -d)"

function cleanup() {
    rm -rf $TMPDIR
}

function _dl_repo() {
    git clone --quiet $REPO_URL $TMPDIR
}

function _install() {
    cp $TMPDIR/rorolinette.rb  "$PREFIX/bin/rorolinette"
}

function _post_inst() {
    info "Rorolinette has been successfully installed !"
    info "Location: $PREFIX/bin/rorolinette"
    info "Reload your PATH by either"
    info " - source /etc/profile"
    info " - source ~/.bashrc"
}

trap cleanup EXIT

function main() {
    info "Using LOG_FILE: $LOG_FILE"
    info "Downloading Rorolinette..."
    _dl_repo || fatal "Could not download sources, exiting..."
    _install || fatal "Could not install the Rorolinette. \n\
        Either you're missing privileges, or have a bad prefix."
    _post_inst
}

main
