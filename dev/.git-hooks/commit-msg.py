#!/usr/bin/env python3
# © 2021 bloopark systems (<http://bloopark.de>)
# License AGPL-3.0 or later (http://www.gnu.org/licenses/agpl.html).
import re
import sys


def main():
    with open(sys.argv[1]) as fc:
        lines = fc.readlines()
        for seq, line in enumerate(lines):
            if line[0] == "#":
                continue
            if not line_valid(seq, line):
                commit_rules()
                sys.exit(1)
    sys.exit(0)


def line_valid(seq, line):
    if seq == 0:
        return re.match(
            r"^PROJECT_CODE-[0-9]*\s[\w\s&.\-!@#$%^&*()]+",
            line,
        )
    elif seq == 1:
        return len(line.strip()) == 0
    else:
        return len(line.strip()) <= 72


def commit_rules():
    print(
        """
Rules for the commit messages
* Subject must start with the ticket number ex: PROJECT_CODE-123
* Followed with the subject of the commit
* Separate subject from the body with a blank line
* Capitalize the subject line
* Wrap the body at 72 characters
* Use the body to explain what and why vs. how
 EXAMPLE:

 PROJECT_CODE-123 Subject of the commit

 Body of the commit explaining the changes
"""
    )


if __name__ == "__main__":
    main()
