#!/usr/bin/python3
import sys


# Check if the argument is a valid integer
if len(sys.argv) != 2:
    print("Usage: python mapper_2.py <temperature>")
    sys.exit(1)

try:
    temperature_argument = float(sys.argv[1])
except ValueError:
    print("Error: Argument must be an integer.")
    sys.exit(1)


def mapper():
    for line in sys.stdin:
        line = line.strip()
        line = line.split(':')
        _, month, _, temperature, _ = line
        month = int(month)
        temperature = float(temperature)
        if temperature > temperature_argument:
            print(f"{month}:{temperature}")


if __name__ == "__main__":
    mapper()
