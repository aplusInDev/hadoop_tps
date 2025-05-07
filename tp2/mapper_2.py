#!/usr/bin/python3
import sys


if len(sys.argv) != 2:
    print("Usage: python mapper_2.py <temperature>")
    sys.exit(1)

try:
    temperature_argument = float(sys.argv[1])
except ValueError:
    print("Error: Argument must be a number.")
    sys.exit(1)

def mapper():
    for line in sys.stdin:
        line = line.strip()
        fields = line.split(':')
        if len(fields) != 5:
            continue
        _, month, _, temperature_str, _ = fields
        try:
            month = int(month)
            temperature = float(temperature_str)
            if temperature > temperature_argument:
                print(f"{month}\t{temperature}")
        except ValueError:
            continue

if __name__ == "__main__":
    mapper()
