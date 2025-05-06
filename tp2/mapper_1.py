#!/usr/bin/env python3
""" Mapper module for processing weather data and finding the maximum temperature per year."""
import sys


def mapper():
    for line in sys.stdin:
        line = line.strip()
        fields = line.split(':')
        if len(fields) < 4:
            continue
        year = fields[2]
        temperature = fields[3]
        try:
            year = int(year)
            temperature = float(temperature)
            print(f"{year}\t{temperature}")
        except ValueError:
            continue


if __name__ == "__main__":
    mapper()
