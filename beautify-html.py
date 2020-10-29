#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Beautify contents of HTML files
#
# TODO:
# - Implement a --force option, then...
# - Ask for confirmation when not using --force
# - Better detect actual HTML, current method has false positives

from bs4 import BeautifulSoup as bs
import sys
from pathlib import Path

for filename in sys.argv[1:]:
    path_to_file = Path(filename)
    if not path_to_file.exists():
        print(f"{filename} skipped: it does not exist")
        continue
    with open(filename, "r+") as f:
        try:
            web_page = f.read()
        except UnicodeDecodeError:
            print(f"{filename} skipped: it appears to be binary")
            continue
        print(f"{filename} loaded")

        file_is_html = bool(bs(web_page, "html.parser").find())
        if not file_is_html:
            print(f"{filename} skipped: It doesn't have a BODY element")
            continue

        soup = bs(web_page, features="html5lib")
        body = soup.find_all("body")
        pretty_html = soup.prettify()

        if web_page == pretty_html:
            print(f"{filename} skipped: It is already pretty")
            f.close()
            continue

        f.seek(0)
        f.write(pretty_html)
        f.truncate()
        f.close()
        print(f"{filename} prettified")
