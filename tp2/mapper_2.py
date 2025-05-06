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
        if len(fields) != 5:  # Skip invalid lines
            continue
        _, month, _, temperature_str, _ = fields
        try:
            month = int(month)
            temperature = float(temperature_str)
            if temperature > temperature_argument:
                # Emit key-value pair with TAB separator
                print(f"{month}\t{temperature}")  # ✅ Correct separator
        except ValueError:
            continue  # Skip invalid data

if __name__ == "__main__":
    mapper()
