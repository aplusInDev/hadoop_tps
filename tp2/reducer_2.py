#!/usr/bin/python3
""" Reducer module for processing weather data and counting months with temperature above a threshold."""
import sys

current_month = None
counter = 0


def reducer():
    """ Reducer function to read input from stdin and count months with temperature above threshold """
    global current_month, counter
    for line in sys.stdin:
        line = line.strip()
        line = line.split(':')
        month, _ = line
        month = int(month)
        if month == current_month:
            continue
        else:
            if counter == 0:
                counter = 1
            else:
                counter += 1
            current_month = month
    print(f"Number of months with temperature above threshold: {counter}")



if __name__ == "__main__":
    reducer()
