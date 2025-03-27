#!/bin/bash

# This script formats names and generates email addresses for employees

# Check if file path is provided
if [ $# -lt 1 ]; then
  echo "Usage: ./task1.sh /path/to/accounts.csv"
  exit 1
fi

file=$1

# Check if file exists
if [ ! -f "$file" ]; then
  echo "File $file doesn't exist"
  exit 1
fi

# Full path output file for Autocode compatibility
output_file="$(pwd)/accounts_new.csv"

# AWK processing: normalize names, generate emails, handle duplicates
awk '
BEGIN { FS=","; OFS=","; }

NR == FNR {
  split($3, name, / /)
  email = tolower(substr(name[1],1,1) name[2])
  count[email]++
  next
}

{
  split($3, name, / /)
  first = toupper(substr(name[1],1,1)) tolower(substr(name[1],2))
  last = toupper(substr(name[2],1,1)) tolower(substr(name[2],2))
  $3 = first " " last

  base_email = tolower(substr(name[1],1,1) name[2])

  if (count[base_email] > 1) {
    email = base_email $2 "@abc.com"
  } else {
    email = base_email "@abc.com"
  }

  $5 = email
  NF = 6
  print
}
' "$file" "$file" > "$output_file"

# MacOS: remove empty line
sed -i '' '/^,,/d' "$output_file"

