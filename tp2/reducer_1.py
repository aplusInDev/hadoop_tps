#!/usr/bin/env python3
""" Reducer module for processing weather data and finding the maximum temperature per year."""
import sys

current_year = None
max_temp = None


def reducer():
    """ Reducer function to read input from stdin and output year and max temperature """
    global current_year, max_temp
    for line in sys.stdin:
        line = line.strip()
        line = line.split(':')
        year, temperature = line
        year = int(year)
        temperature = float(temperature)
        if year == current_year:
            if max_temp is None or temperature > max_temp:
                max_temp = temperature
        else:
            if current_year is not None:
                print(f"{current_year}\t{max_temp}")
            current_year = year
            max_temp = temperature


if __name__ == "__main__":
    reducer()
