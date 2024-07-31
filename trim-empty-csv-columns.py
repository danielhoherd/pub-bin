#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Trim empty columns from a csv file and write the result to a new file."""

import csv
import typer

app = typer.Typer()


@app.command()
def trim_null_empty_columns(input_file: str, output_file: str = "output.csv"):
    """Trim null and empty columns from a CSV file."""
    # Read the CSV file and store its contents
    with open(input_file, newline="", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile)
        data = list(reader)

    # rotate the table and check for empty rows
    null_empty_columns = [i for i, column in enumerate(zip(*data)) if all(value == "" or value is None for value in column[1:])]
    # Remove identified columns from the data
    trimmed_data = [[row[i] for i in range(len(data[0])) if i not in null_empty_columns] for row in data]

    # Write the trimmed data to a new CSV file with lineterminator="\n"
    with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile, quoting=csv.QUOTE_ALL, lineterminator="\n")
        writer.writerows(trimmed_data)


if __name__ == "__main__":
    app()
