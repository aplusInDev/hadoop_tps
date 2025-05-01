#!/usr/bin/python3
import sys

current_month = None
counter = 0


def reducer():
    global current_month, counter
    for line in sys.stdin:
        line = line.strip()
        line = line.split(':')
        month, _ = line
        month = int(month)
        if month == current_month:
            if counter == 0:
                counter = 1
            else:
                counter += 1
        else:
            if current_month is not None:
                print(f"{current_month}\t{counter}")
            current_month = month
    print(f"Number of months with temperature above threshold: {counter}")



if __name__ == "__main__":
    reducer()
