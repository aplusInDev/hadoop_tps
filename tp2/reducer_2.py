#!/usr/bin/python3
import sys

def reducer():
    current_month = None
    unique_months = set()  # Track unique months

    for line in sys.stdin:
        line = line.strip()
        # Split by TAB (key=month, value=temperature)
        parts = line.split('\t')
        if len(parts) != 2:  # Skip invalid lines
            continue
        month_str, _ = parts
        try:
            month = int(month_str)
            unique_months.add(month)  # Add month to set
        except ValueError:
            continue

    # Output total unique months
    print(f"Number of months with temperature above threshold: {len(unique_months)}")

if __name__ == "__main__":
    reducer()
