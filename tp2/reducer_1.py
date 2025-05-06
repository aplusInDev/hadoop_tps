#!/usr/bin/env python3
""" Reducer module for processing weather data and finding the maximum temperature per year."""
import sys


def reducer():
    current_year = None
    max_temp = -float('inf')  # Initialize to negative infinity

    for line in sys.stdin:
        line = line.strip()
        key, value = line.split('\t', 1)
        year = int(key)
        temperature = float(value)

        if year == current_year:
            if temperature > max_temp:
                max_temp = temperature
        else:
            if current_year is not None:
                print(f"{current_year}\t{max_temp}")
            current_year = year
            max_temp = temperature

    if current_year is not None:
        print(f"{current_year}\t{max_temp}")


if __name__ == "__main__":
    reducer()
