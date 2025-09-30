Param(
    [string]$CsvPath = "Database/Restaurant Management Entity/restaurant_contacts/CSV/menuca_v1_restaurants_contacts.csv"
)

if (-not (Test-Path -Path $CsvPath)) {
    throw "File not found: $CsvPath"
}

$contacts = Import-Csv -Path $CsvPath -Delimiter ';'

$counter = 1
foreach ($row in $contacts) {
    if ([string]::IsNullOrWhiteSpace($row.phone)) {
        $row.phone = ""
    } else {
        $row.phone = $row.phone.Trim()
    }

    $row.id = $counter.ToString()
    $counter++
}

$contacts |
    Export-Csv -Path $CsvPath -Delimiter ';' -NoTypeInformation -Encoding UTF8

