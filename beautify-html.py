#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: Unlicense
# Purpose: Beautify contents of HTML files

from bs4 import BeautifulSoup as bs
import sys

for filename in sys.argv[1:]:
    with open(filename, "r+") as f:
        web_page = f.read()
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
