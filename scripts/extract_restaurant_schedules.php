<?php
declare(strict_types=1);

$inputFile = __DIR__ . '/../SQL/menuca_v1_restaurants.sql';
$outputDir = __DIR__ . '/../output';

if (!file_exists($inputFile)) {
    fwrite(STDERR, "Input file not found: {$inputFile}\n");
    exit(1);
}

if (!is_dir($outputDir) && !mkdir($outputDir, 0777, true) && !is_dir($outputDir)) {
    fwrite(STDERR, "Failed to create output directory: {$outputDir}\n");
    exit(1);
}

$scheduleOutPath = $outputDir . '/restaurants_schedule.sql';
$specialOutPath = $outputDir . '/restaurants_special_schedule.sql';

$scheduleHandle = fopen($scheduleOutPath, 'w');
$specialHandle = fopen($specialOutPath, 'w');

if (!$scheduleHandle || !$specialHandle) {
    fwrite(STDERR, "Failed to open output files for writing.\n");
    exit(1);
}

// Start files with truncate statements to simplify loading.
fwrite($scheduleHandle, "TRUNCATE TABLE `restaurants_schedule_normalized`;\n");
fwrite($specialHandle, "TRUNCATE TABLE `restaurants_special_schedule`;\n");

$dayMap = [
    'mon' => 1,
    'tue' => 2,
    'wed' => 3,
    'thu' => 4,
    'fri' => 5,
    'sat' => 6,
    'sun' => 7,
];

$statement = '';
$handle = fopen($inputFile, 'r');
if (!$handle) {
    fwrite(STDERR, "Unable to open input file for reading.\n");
    exit(1);
}

while (($line = fgets($handle)) !== false) {
    $statement .= $line;
    if (strpos($line, ';') === false) {
        continue;
    }

    $trimmed = trim($statement);
    if ($trimmed === '') {
        $statement = '';
        continue;
    }

    if (strpos($trimmed, 'INSERT INTO `restaurants` VALUES') !== 0) {
        $statement = '';
        continue;
    }

    processInsertStatement($trimmed, $dayMap, $scheduleHandle, $specialHandle);
    $statement = '';
}

fclose($handle);
fclose($scheduleHandle);
fclose($specialHandle);

echo "Extraction complete.\n";

function processInsertStatement(string $statement, array $dayMap, $scheduleHandle, $specialHandle): void
{
    // Remove trailing semicolon.
    if (str_ends_with($statement, ';')) {
        $statement = substr($statement, 0, -1);
    }

    $prefix = 'INSERT INTO `restaurants` VALUES ';
    $valuesPart = substr($statement, strlen($prefix));
    $rows = extractRows($valuesPart);

    foreach ($rows as $rowSql) {
        $columns = splitColumns($rowSql);
        if (count($columns) < 11) {
            continue; // unexpected shape
        }

        $restaurantId = (int)normalizeValue($columns[0]);
        $deliveryRaw = normalizeValue($columns[8]);
        $restaurantRaw = normalizeValue($columns[9]);
        $specialRaw = normalizeValue($columns[10]);

        if ($deliveryRaw !== null) {
            $deliveryData = decodeSchedule($deliveryRaw);
            writeScheduleRows($scheduleHandle, $restaurantId, 'd', $deliveryData, $dayMap);
        }
        if ($restaurantRaw !== null) {
            $restaurantData = decodeSchedule($restaurantRaw);
            writeScheduleRows($scheduleHandle, $restaurantId, 't', $restaurantData, $dayMap);
        }
        if ($specialRaw !== null) {
            $specialData = decodeSpecialSchedule($specialRaw);
            writeSpecialRows($specialHandle, $restaurantId, $specialData);
        }
    }
}

function extractRows(string $valuesPart): array
{
    $rows = [];
    $length = strlen($valuesPart);
    $buffer = '';
    $depth = 0;
    $inString = false;
    $quote = '';

    for ($i = 0; $i < $length; $i++) {
        $char = $valuesPart[$i];
        $buffer .= $char;

        if ($inString) {
            if ($char === '\\') {
                $buffer .= $valuesPart[++$i] ?? '';
                continue;
            }
            if ($char === $quote) {
                $inString = false;
            }
            continue;
        }

        if ($char === '\'' || $char === '\"') {
            $inString = true;
            $quote = $char;
            continue;
        }

        if ($char === '(') {
            $depth++;
            continue;
        }

        if ($char === ')') {
            $depth--;
            if ($depth === 0) {
                $rows[] = trim($buffer);
                $buffer = '';
            }
            continue;
        }
    }

    return $rows;
}

function splitColumns(string $rowSql): array
{
    $rowSql = trim($rowSql);
    if ($rowSql === '') {
        return [];
    }

    if ($rowSql[0] === '(' && str_ends_with($rowSql, ')')) {
        $rowSql = substr($rowSql, 1, -1);
    }

    $columns = [];
    $current = '';
    $length = strlen($rowSql);
    $inString = false;
    $quote = '';

    for ($i = 0; $i < $length; $i++) {
        $char = $rowSql[$i];

        if ($inString) {
            if ($char === '\\') {
                $current .= $char;
                $current .= $rowSql[++$i] ?? '';
                continue;
            }
            if ($char === $quote) {
                $inString = false;
            }
            $current .= $char;
            continue;
        }

        if ($char === '\'' || $char === '\"') {
            $inString = true;
            $quote = $char;
            $current .= $char;
            continue;
        }

        if ($char === ',') {
            $columns[] = trim($current);
            $current = '';
            continue;
        }

        $current .= $char;
    }

    if ($current !== '') {
        $columns[] = trim($current);
    }

    return $columns;
}

function normalizeValue(?string $value)
{
    if ($value === null) {
        return null;
    }

    $value = trim($value);
    if ($value === '' || strtoupper($value) === 'NULL') {
        return null;
    }

    if (str_starts_with($value, '_binary')) {
        $value = trim(substr($value, strlen('_binary')));
    }

    if ($value !== '' && ($value[0] === '\'' || $value[0] === '"')) {
        $value = substr($value, 1, -1);
    }

    $value = stripcslashes($value);

    return $value;
}

function decodeSchedule(?string $serialized): array
{
    if ($serialized === null || $serialized === '') {
        return [];
    }

    $data = @unserialize($serialized);
    return is_array($data) ? $data : [];
}

function decodeSpecialSchedule(?string $serialized): array
{
    if ($serialized === null || $serialized === '') {
        return [];
    }

    $data = @unserialize($serialized);
    return is_array($data) ? $data : [];
}

function writeScheduleRows($handle, int $restaurantId, string $type, array $schedule, array $dayMap): void
{
    if (!isset($schedule['start'], $schedule['stop'])) {
        return;
    }

    foreach ($schedule['start'] as $day => $slots) {
        if (!isset($dayMap[$day])) {
            continue;
        }
        $dayNumber = $dayMap[$day];
        if (!is_array($slots)) {
            continue;
        }
        foreach ($slots as $index => $startRaw) {
            $stopRaw = $schedule['stop'][$day][$index] ?? null;
            $start = normalizeTime($startRaw);
            $stop = normalizeTime($stopRaw);
            if ($start === null || $stop === null) {
                continue;
            }

            $sql = sprintf(
                "INSERT INTO `restaurants_schedule_normalized` (`restaurant_id`,`day_start`,`time_start`,`day_stop`,`time_stop`,`type`,`enabled`) VALUES (%d,%d,%s,%d,%s,'%s','y');\n",
                $restaurantId,
                $dayNumber,
                toSqlTime($start),
                $dayNumber,
                toSqlTime($stop),
                $type
            );
            fwrite($handle, $sql);
        }
    }
}

function writeSpecialRows($handle, int $restaurantId, array $special): void
{
    if (empty($special)) {
        return;
    }

    $dates = $special['date'] ?? [];
    if (!is_array($dates)) {
        return;
    }

    $hour = $special['hour'] ?? [];
    $startSets = $hour['start'] ?? [];
    $stopSets = $hour['stop'] ?? [];

    foreach ($dates as $index => $dateRaw) {
        $date = normalizeDate($dateRaw);
        if ($date === null) {
            continue;
        }

        $starts = collectSpecialTimes($startSets, $index);
        $stops = collectSpecialTimes($stopSets, $index);
        $pairCount = max(count($starts), count($stops));

        for ($i = 0; $i < $pairCount; $i++) {
            $start = $starts[$i] ?? null;
            $stop = $stops[$i] ?? null;
            if ($start === null || $stop === null) {
                continue;
            }

            $sql = sprintf(
                "INSERT INTO `restaurants_special_schedule` (`restaurant_id`,`special_date`,`time_start`,`time_stop`,`enabled`) VALUES (%d,'%s',%s,%s,'y');\n",
                $restaurantId,
                $date,
                toSqlTime($start),
                toSqlTime($stop)
            );
            fwrite($handle, $sql);
        }
    }
}

function collectSpecialTimes(array $sets, $index): array
{
    $times = [];
    foreach (['i1', 'i2', 'i3'] as $slotKey) {
        if (!isset($sets[$slotKey])) {
            continue;
        }
        $slot = $sets[$slotKey];
        if (!is_array($slot)) {
            continue;
        }
        $value = $slot[$index] ?? null;
        if (is_array($value)) {
            $value = reset($value);
        }
        $time = normalizeTime($value);
        if ($time !== null) {
            $times[] = $time;
        }
    }
    return $times;
}

function normalizeTime($value): ?string
{
    if ($value === null) {
        return null;
    }

    if (is_int($value)) {
        $value = (string)$value;
    } elseif (!is_string($value)) {
        return null;
    }

    $value = trim($value);
    if ($value === '' || strtolower($value) === 'closed') {
        return null;
    }

    if ($value === '0') {
        $value = '00:00';
    }

    if (preg_match('/^\d{1,2}:\d{2}(:\d{2})?$/', $value) === 1) {
        return substr($value, 0, 5);
    }

    if (preg_match('/^\d{1,2}$/', $value) === 1) {
        return sprintf('%02d:00', (int)$value);
    }

    return null;
}

function toSqlTime(string $time): string
{
    return "'" . $time . ":00'";
}

function normalizeDate($value): ?string
{
    if ($value === null) {
        return null;
    }

    if (!is_string($value)) {
        return null;
    }

    $value = trim($value);
    if ($value === '') {
        return null;
    }

    $formats = ['Y-m-d', 'm-d-Y', 'd-m-Y'];
    foreach ($formats as $format) {
        $dt = DateTime::createFromFormat($format, $value);
        if ($dt instanceof DateTime) {
            return $dt->format('Y-m-d');
        }
    }

    return null;
}

