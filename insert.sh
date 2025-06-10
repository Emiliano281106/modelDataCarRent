#!/bin/bash
TABLE_NAME="Delegations"

# Generate all days in the next six months in YYYY/MM/DD format
dates_json="["

for month_offset in {0..5}; do
    # Get the first day of the target month
    first_day=$(date -d "-$(($(date +%d)-1)) days +$month_offset month" +%Y/%m/%d)
    # Get the first day of the next month
    next_month_first_day=$(date -d "$first_day +1 month" +%Y/%m/%d)
    # Get the last day of the current month
    last_day=$(date -d "$next_month_first_day -1 day" +%Y/%m/%d)

    # Convert to epoch seconds for iteration
    start_sec=$(date -d "$first_day" +%s)
    end_sec=$(date -d "$last_day" +%s)

    # Generate all dates in the current month
    current_sec=$start_sec
    while [[ $current_sec -le $end_sec ]]; do
        formatted_date=$(date -d "@$current_sec" +%Y/%m/%d)
        dates_json+="\"$formatted_date\","
        current_sec=$((current_sec + 86400))  # Add 1 day in seconds
    done
done

# Remove trailing comma and close array
dates_json="${dates_json%,}]"

# Read cars.json into a variable
cars_data=$(cat cars.json)

# Insert into DynamoDB
echo "$cars_data" | jq -c '.[]' | while read -r car; do
    item_json=$(jq --argjson dates "$dates_json" '{
        "delegationId": {"S": .delegationId},
        "operation": {"S": .operation},
        "availableDates": {"L": $dates | map({"S": .})},
        "make": {"S": .make},
        "model": {"S": .model},
        "year": {"N": (.year|tostring)},
        "color": {"S": .color},
        "price": {"N": (.price|tostring)}
    }' <<< "$car")
    
    aws dynamodb put-item \
        --table-name "$TABLE_NAME" \
        --item "$item_json"
done

echo "All items inserted to $TABLE_NAME"