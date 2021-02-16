#!/usr/bin/env bash
# shellcheck disable=SC2028
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Show all parsed 'date' format strings for easy perusal

if [[ "${OSTYPE}" =~ ^darwin ]] ; then
  command -v gdate >/dev/null 2>&1 || { echo "Cannot find gdate. Try 'brew install coreutils' https://brew.sh" ; exit 1 ; }
  ydate() { gdate "$@" ; }
  echo "Using 'gdate' to get GNU date behavior"
elif [[ "${OSTYPE}" =~ ^linux ]] ; then
  ydate() { date "$@" ; }
else
  echo "Not sure what to do with ${OSTYPE}..."
  exit 1
fi

echo "
$(ydate "+%%")|%%|a literal %
$(ydate "+%a")|%a|locale’s abbreviated weekday name (e.g., Sun)
$(ydate "+%A")|%A|locale’s full weekday name (e.g., Sunday)
$(ydate "+%b")|%b|locale’s abbreviated month name (e.g., Jan)
$(ydate "+%B")|%B|locale’s full month name (e.g., January)
$(ydate "+%c")|%c|locale’s date and time (e.g., Thu Mar 3 23:05:25 2005)
$(ydate "+%C")|%C|century; like %Y, except omit last two digits (e.g., 21)
$(ydate "+%d")|%d|day of month (e.g, 01)
$(ydate "+%D")|%D|date; same as %m/%d/%y
$(ydate "+%e")|%e|day of month, space padded; same as %_d
$(ydate "+%F")|%F|full date; same as %Y-%m-%d
$(ydate "+%g")|%g|last two digits of year of ISO week number (see %G)
$(ydate "+%G")|%G|year of ISO week number (see %V); normally useful only with %V
$(ydate "+%h")|%h|same as %b
$(ydate "+%H")|%H|hour (00..23)
$(ydate "+%I")|%I|hour (01..12)
$(ydate "+%j")|%j|day of year (001..366)
$(ydate "+%k")|%k|hour ( 0..23)
$(ydate "+%l")|%l|hour ( 1..12)
$(ydate "+%m")|%m|month (01..12)
$(ydate "+%M")|%M|minute (00..59)
\\n|%n|a newline
$(ydate "+%N")|%N|nanoseconds (000000000..999999999)
$(ydate "+%p")|%p|locale’s equivalent of either AM or PM; blank if not known
$(ydate "+%P")|%P|like %p, but lower case
$(ydate "+%r")|%r|locale’s 12-hour clock time (e.g., 11:11:04 PM)
$(ydate "+%R")|%R|24-hour hour and minute; same as %H:%M
$(ydate "+%s")|%s|seconds since 1970-01-01 00:00:00 UTC
$(ydate "+%S")|%S|second (00..60)
\\t|%t|a tab
$(ydate "+%T")|%T|time; same as %H:%M:%S
$(ydate "+%u")|%u|day of week (1..7); 1 is Monday
$(ydate "+%U")|%U|week number of year, with Sunday as first day of week (00..53)
$(ydate "+%V")|%V|ISO week number, with Monday as first day of week (01..53)
$(ydate "+%w")|%w|day of week (0..6); 0 is Sunday
$(ydate "+%W")|%W|week number of year, with Monday as first day of week (00..53)
$(ydate "+%x")|%x|locale’s date representation (e.g., 12/31/99)
$(ydate "+%X")|%X|locale’s time representation (e.g., 23:13:48)
$(ydate "+%y")|%y|last two digits of year (00..99)
$(ydate "+%Y")|%Y|year
$(ydate "+%z")|%z|+hhmm numeric timezone (e.g., -0400)
$(ydate "+%:z")|%:z|+hh:mm numeric timezone (e.g., -04:00)
$(ydate "+%::z")|%::z|+hh:mm:ss numeric time zone (e.g., -04:00:00)
$(ydate "+%:::z")|%:::z|numeric time zone with : to necessary precision (e.g., -04, +05:30)
$(ydate "+%Z")|%Z|alphabetic time zone abbreviation (e.g., EDT)
" | column -s'|' -t
