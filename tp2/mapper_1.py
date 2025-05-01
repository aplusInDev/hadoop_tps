#!/usr/bin/env python3
""" Mapper module for processing weather data and finding the maximum temperature per year."""
import sys


def mapper():
    """ Mapper function to read input from stdin and output year and max temperature """
    for line in sys.stdin:
        line = line.strip()
        line = line.split(':')
        _, _, year, temperature, _ = line
        year = int(year)
        temperature = float(temperature)
        print(f"{year}:{temperature}")


if __name__ == "__main__":
    mapper()
