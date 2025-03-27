#!/bin/bash

# Exit if path to output.txt file not provided as argument
if [ $# -lt 1 ]; then
    echo "Usage: ./task2.sh /path/to/output.txt"
    exit 1
fi

file=$1

# Exit if provided file doesn't exist
if [ ! -f "$file" ]; then
    echo "File $file doesn't exist"
    exit 1
fi

# Extract test name
test_name=$(head -n 1 "$file" | sed -n 's/^\[\(.*\)\],.*/\1/p' | xargs)

# Extract test entries
test_entries=""
while IFS= read -r line; do
    if [[ $line =~ ^(ok|not\ ok)[[:space:]]+[0-9]+[[:space:]]+(.*),[[:space:]]+([0-9]+ms)$ ]]; then
        status=${BASH_REMATCH[1]}
        name=${BASH_REMATCH[2]}
        duration=${BASH_REMATCH[3]}

        # Clean up name
        name=$(echo "$name" | xargs)

        # Convert status
        if [[ "$status" == "ok" ]]; then
            status_value=true
        else
            status_value=false
        fi

        test_entries+=$(printf '    {"name": "%s", "status": %s, "duration": "%s"},\n' "$name" "$status_value" "$duration")
    fi
done < "$file"

# Remove trailing comma from last test entry
test_entries=$(printf "%s" "$test_entries" | sed '$s/},$/}/')

# Extract summary line
summary_line=$(grep -E "tests passed" "$file")
passed=$(echo "$summary_line" | grep -oE "^[0-9]+")
failed=$(echo "$summary_line" | grep -oE "[0-9]+ tests failed" | grep -oE "[0-9]+")
rating=$(echo "$summary_line" | grep -oE "rated as [0-9]+(\.[0-9]+)?" | awk '{print $3}')
duration=$(echo "$summary_line" | grep -oE "spent [0-9]+ms" | awk '{print $2}')

# Output full JSON
json_output=$(cat <<EOF
{
  "testName": "$test_name",
  "tests": [
$test_entries
  ],
  "summary": {
    "success": $passed,
    "failed": $failed,
    "rating": $rating,
    "duration": "$duration"
  }
}
EOF
)

# Save to output.json
echo "$json_output" > "$(dirname "$file")/output.json"
echo "✅ output.json created successfully."

