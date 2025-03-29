#!/usr/bin/env python3

import subprocess
import argparse
import os


def docx_to_md(input_file, output_file=None):
    """
    Convert a .docx file to .md using Pandoc.

    Args:
        input_file (str): Path to the .docx file
        output_file (str, optional): Path to output .md file. Defaults to None
    """
    # If output_file is not provided, create it by replacing .docx with .md
    if not output_file:
        output_file = os.path.splitext(input_file)[0] + ".md"

    # Construct the Pandoc command
    cmd = f"pandoc -s {input_file} -t markdown -o {output_file}"

    # Run the command
    try:
        subprocess.run(cmd, shell=True, check=True)
        print(f"Successfully converted {input_file} to {output_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error converting file: {e}")
        return 1
    return 0


def main():
    # Create an ArgumentParser object
    parser = argparse.ArgumentParser(description="Convert .docx to .md")

    # Add arguments
    parser.add_argument("input_file", help="Path to the .docx file to convert")
    parser.add_argument("-o", "--output", help="Path to output .md file")

    # Parse arguments
    args = parser.parse_args()

    # Call the conversion function
    docx_to_md(args.input_file, args.output)


if __name__ == "__main__":
    main()


### How to use this script:

# 1. **Save the script** as `cli_docx_to_md.py`.

# 2. **Make it executable** by running:
#    ```bash
#    chmod +x cli_docx_to_md.py
#    ```

# 3. **Use the CLI tool** in your terminal:
#    ```bash
#    ./cli_docx_to_md.py input.docx
#    ```
#    This will create an `input.md` file in the same directory.

# 4. **Optional output file**:
#    ```bash
#    ./cli_docx_to_md.py input.docx -o output.md
#    ```

# ### Prerequisites:
# - Install Pandoc from [its official website](https://pandoc.org/installing.html)
# - Make sure Python is installed on your system

# ### Features:
# - Converts `.docx` files to `.md` format
# - If no output file is specified, it automatically creates one with the same base name
# - Includes error handling
# - Command-line interface with arguments

# ### Optional Enhancements:
# - Add support for more file formats
# - Add conversion options (e.g., custom CSS, format-specific settings)
# - Add logging for debugging purposes
# - Add progress indicators

# You can also make this script available system-wide by placing it in a directory that's in your `PATH` environment variable.
