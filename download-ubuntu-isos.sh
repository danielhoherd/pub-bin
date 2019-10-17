#!/usr/bin/env bash

command -v aria2c &>/dev/null || { echo "ERROR: the command 'aria2c' is required." >&2 ; exit 1 ; }

lowest_speed_limit=2M  # per connection
#max_overall_download_limit=500K  # total download speed
DL_OPTIONS=(
  "-s5"
  "-c"
  "--lowest-speed-limit=${lowest_speed_limit:-0}"
  "--max-download-limit=${max_overall_download_limit:-0}"
  "--file-allocation" "none"
)

# Mirror list:
# - https://launchpad.net/ubuntu/+cdmirrors  # human readable table with alleged speeds (tests show some fat pipes throttle)
# - http://mirrors.ubuntu.com/mirrors.txt  # simple list of mirrors
get_file_from_mirror() {
  aria2c "${DL_OPTIONS[@]}" \
    "http://mirror.math.princeton.edu/pub/ubuntu-iso/$1" \
    "http://mirrors.layeronline.com/ubuntu-releases/$1" \
    "http://mirrors.xtom.com/ubuntu-releases/$1" \
    "http://isos.ubuntu.mirror.constant.com/$1" \
    "http://mirror.cs.unm.edu/releases/$1" \
    "http://mirror.pnl.gov/releases/$1" \
    "http://mirror.umd.edu/ubuntu-iso/$1" \
    "http://mirror.us.leaseweb.net/ubuntu-releases/$1" \
    "http://mirrors.bloomu.edu/ubuntu-releases/$1" \
    "http://mirrors.rit.edu/ubuntu-releases/$1" \
    "http://mirrors.syringanetworks.net/ubuntu-releases/$1" \
    "http://ubuntu.cs.utah.edu/releases/$1" \
    "http://mirror.lstn.net/ubuntu-releases/$1" \
    "http://mirrors.advancedhosters.com/ubuntu-releases/$1" \
    "http://mirrors.us.kernel.org/ubuntu-releases/$1" \
    "http://repo.ialab.dsu.edu/ubuntu-releases/$1" \
    "http://ubuntu.osuosl.org/releases/$1" \
    "http://mirror.clarkson.edu/ubuntu-releases/$1" \
    "http://mirror.cogentco.com/pub/linux/ubuntu-releases/$1" \
    "http://mirror.cs.jmu.edu/pub/ubuntu-iso/$1" \
    "http://mirror.cs.pitt.edu/ubuntu/releases/$1" \
    "http://mirror.metrocast.net/ubuntu-releases/$1" \
    "http://mirror.mrjester.net/ubuntu/release/$1" \
    "http://mirror.os6.org/ubuntu-releases/$1" \
    "http://mirror.sjc02.svwh.net/ubuntu-releases/$1" \
    "http://mirror.steadfastnet.com/ubuntu-releases/$1" \
    "http://mirror.team-cymru.com/ubuntu-releases/$1" \
    "http://mirror.uoregon.edu/ubuntu-releases/$1" \
    "http://mirror.wayne.edu/ubuntu/releases/$1" \
    "http://mirrors.cat.pdx.edu/ubuntu-releases/$1" \
    "http://mirrors.easynews.com/linux/ubuntu-releases/$1" \
    "http://mirrors.gigenet.com/ubuntu/$1" \
    "http://mirrors.koehn.com/ubuntureleases/$1" \
    "http://mirrors.lug.mtu.edu/ubuntu-releases/$1" \
    "http://mirrors.mit.edu/ubuntu-releases/$1" \
    "http://mirrors.ocf.berkeley.edu/ubuntu-releases/$1" \
    "http://mirrors.tripadvisor.com/releases/$1" \
    "http://mirrors.usinternet.com/ubuntu/releases/$1" \
    "http://mirrors.xmission.com/ubuntu-cd/$1" \
    "http://reflection.oss.ou.edu/ubuntu-release/$1" \
    "http://ubuntu.mirrors.tds.net/pub/releases/$1" \
    "http://ubuntu-releases.cs.umn.edu/$1" \
    "http://www.gtlib.gatech.edu/pub/ubuntu-releases/$1"
}

get_file_from_mirror "16.04.6/ubuntu-16.04.6-desktop-amd64.iso"
get_file_from_mirror "16.04.6/ubuntu-16.04.6-server-amd64.iso"
get_file_from_mirror "18.04.3/ubuntu-18.04.3-desktop-amd64.iso"
get_file_from_mirror "18.04.3/ubuntu-18.04.3-live-server-amd64.iso"
get_file_from_mirror "19.10/ubuntu-19.10-desktop-amd64.iso"
get_file_from_mirror "19.10/ubuntu-19.10-live-server-amd64.iso"
