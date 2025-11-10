#!/usr/bin/env python3
import sys
import re
import os
import subprocess
import json

def get_include_paths():
    """Get include paths from make."""
    try:
        output = subprocess.check_output(
            'make -Bn 2>/dev/null | grep -o "\\-I[^ ]*" | sed "s/^-I//" | sort -u',
            shell=True, text=True
        )
        paths = output.strip().split('\n')
        paths.append('')  # add empty string for current dir
        return paths
    except subprocess.CalledProcessError:
        return ['']

def file_word_complete(base, filename, root_path=None, visited=None):
    """Recursively extract words from a file."""
    if visited is None:
        visited = set()

    # Avoid cycles
    if filename in visited:
        return set()
    visited.add(filename)

    # Determine file path
    if filename == 'self':
        with open(sys.argv[1], 'r') as f:
            lines = f.readlines()
    else:
        if root_path:
            path = os.path.join(root_path, filename)
        else:
            path = filename
        if not os.path.isfile(path):
            return set()
        with open(path, 'r') as f:
            lines = f.readlines()

    words = set()
    for line in lines:
        # Handle includes
        m = re.match(r'\s*#\s*include\s*"([^"]+)"', line)
        if m:
            include_file = m.group(1)
            for inc_path in get_include_paths():
                final_path = os.path.abspath(os.path.join(inc_path, include_file))
                words.update(file_word_complete(base, final_path, root_path=None, visited=visited))
        # Split line into words
        for w in re.split(r'\W+', line):
            if w.startswith(base):
                words.add(w)
    return words

def main():
    if len(sys.argv) < 3:
        print("Usage: file_word_complete.py <base> <filename>", file=sys.stderr)
        sys.exit(1)

    base = sys.argv[1]
    filename = sys.argv[2]

    matches = file_word_complete(base, filename)
    # Output JSON lines for easy parsing
    print("\n".join(sorted(matches)))

if __name__ == '__main__':
    main()
