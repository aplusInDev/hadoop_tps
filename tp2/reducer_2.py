#!/usr/bin/python3
import sys

def reducer():
    unique_months = set()

    for line in sys.stdin:
        line = line.strip()
        parts = line.split('\t')
        if len(parts) != 2:
            continue
        month_str, _ = parts
        try:
            month = int(month_str)
            unique_months.add(month)
        except ValueError:
            continue


    print(f"Number of months with temperature above threshold: {len(unique_months)}")

if __name__ == "__main__":
    reducer()
