#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Download ISOs for Ubuntu LTS and latest available release.

command -v aria2c &>/dev/null || { echo "ERROR: the command 'aria2c' is required." >&2 ; exit 1 ; }

trap "kill 0" SIGINT

lowest_speed_limit=2M  # per connection
#max_overall_download_limit=500K  # total download speed
dl_options=(
  "--split=5"
  "--continue"
  "--lowest-speed-limit=${lowest_speed_limit:-0}"
  "--max-download-limit=${max_overall_download_limit:-0}"
  "--file-allocation" "none"
)

# Mirror list:
# - https://launchpad.net/ubuntu/+cdmirrors  # human readable table with alleged speeds (tests show some fat pipes throttle)
# - http://mirrors.ubuntu.com/mirrors.txt  # simple list of mirrors
mirrors=(
  "http://mirror.math.princeton.edu/pub/ubuntu-iso/"
  "http://mirrors.xtom.com/ubuntu-releases/"
  "http://isos.ubuntu.mirror.constant.com/"
  "http://mirror.cs.unm.edu/releases/"
  "http://mirror.pnl.gov/releases/"
  "http://mirror.umd.edu/ubuntu-iso/"
  "http://mirror.us.leaseweb.net/ubuntu-releases/"
  "http://mirrors.bloomu.edu/ubuntu-releases/"
  "http://mirrors.rit.edu/ubuntu-releases/"
  "http://mirrors.syringanetworks.net/ubuntu-releases/"
  "http://ubuntu.cs.utah.edu/releases/"
  "http://mirror.lstn.net/ubuntu-releases/"
  "http://mirrors.advancedhosters.com/ubuntu-releases/"
  "http://mirrors.us.kernel.org/ubuntu-releases/"
  "http://repo.ialab.dsu.edu/ubuntu-releases/"
  "http://ubuntu.osuosl.org/releases/"
  "http://mirror.clarkson.edu/ubuntu-releases/"
  "http://mirror.cogentco.com/pub/linux/ubuntu-releases/"
  "http://mirror.cs.jmu.edu/pub/ubuntu-iso/"
  "http://mirror.cs.pitt.edu/ubuntu/releases/"
  "http://mirror.metrocast.net/ubuntu-releases/"
  "http://mirror.mrjester.net/ubuntu/release/"
  "http://mirror.os6.org/ubuntu-releases/"
  "http://mirror.sjc02.svwh.net/ubuntu-releases/"
  "http://mirror.steadfastnet.com/ubuntu-releases/"
  "http://mirror.team-cymru.com/ubuntu-releases/"
  "http://mirror.uoregon.edu/ubuntu-releases/"
  "http://mirror.wayne.edu/ubuntu/releases/"
  "http://mirrors.cat.pdx.edu/ubuntu-releases/"
  "http://mirrors.easynews.com/linux/ubuntu-releases/"
  "http://mirrors.gigenet.com/ubuntu/"
  "http://mirrors.koehn.com/ubuntureleases/"
  "http://mirrors.lug.mtu.edu/ubuntu-releases/"
  "http://mirrors.mit.edu/ubuntu-releases/"
  "http://mirrors.ocf.berkeley.edu/ubuntu-releases/"
  "http://mirrors.tripadvisor.com/releases/"
  "http://mirrors.usinternet.com/ubuntu/releases/"
  "http://mirrors.xmission.com/ubuntu-cd/"
  "http://reflection.oss.ou.edu/ubuntu-release/"
  "http://ubuntu.mirrors.tds.net/pub/releases/"
  "http://ubuntu-releases.cs.umn.edu/"
  "http://www.gtlib.gatech.edu/pub/ubuntu-releases/"
)

get_file_from_mirror() {
  aria2c "${dl_options[@]}" "${mirrors[@]/%/$1}"
}

get_file_from_mirror "21.10/ubuntu-21.10-live-server-amd64.iso"
get_file_from_mirror "21.10/ubuntu-21.10-desktop-amd64.iso"
get_file_from_mirror "20.04/ubuntu-20.04.3-live-server-amd64.iso"
get_file_from_mirror "20.04/ubuntu-20.04.3-desktop-amd64.iso"
