<?php
/**
 * Deserialize BLOB data from V1 dump
 * Converts serialized PHP arrays to structured data for V3 insertion
 */

echo "=============================================================\n";
echo "PHP BLOB Deserializer for MVP Restaurants\n";
echo "=============================================================\n\n";

// Load the JSON files
$deliveryAreaData = json_decode(file_get_contents('mvp_blob_deliveryArea.json'), true);
$deliveryScheduleData = json_decode(file_get_contents('mvp_blob_delivery_schedule.json'), true);
$feeData = json_decode(file_get_contents('mvp_blob_fee.json'), true);

echo "Loaded BLOB data:\n";
echo "  - Delivery Areas: " . count($deliveryAreaData) . " restaurants\n";
echo "  - Delivery Schedules: " . count($deliveryScheduleData) . " restaurants\n";
echo "  - Fees: " . count($feeData) . " restaurants\n\n";

// Process Delivery Schedules
echo "Processing Delivery Schedules...\n";
echo str_repeat("-", 60) . "\n";

$scheduleResults = [];

foreach ($deliveryScheduleData as $restaurant) {
    $v1_id = $restaurant['v1_id'];
    $v3_id = $restaurant['v3_id'];
    $name = $restaurant['restaurant_name'];
    $blobData = $restaurant['blob_data'];
    
    echo "\n[$v1_id] $name (V3 ID: $v3_id)\n";
    
    // Unescape the blob data
    $unescaped = stripslashes($blobData);
    
    // Unserialize the PHP array
    $schedule = @unserialize($unescaped);
    
    if ($schedule === false) {
        echo "  ERROR: Could not unserialize schedule data\n";
        echo "  Raw data (first 100 chars): " . substr($blobData, 0, 100) . "\n";
        continue;
    }
    
    echo "  Successfully deserialized schedule data\n";
    
    // V1 format: array with 'start' and 'stop' keys, each containing day arrays
    // Each day has i1, i2, i3 (for multiple time periods)
    $scheduleEntries = [];
    
    if (isset($schedule['start']) && isset($schedule['stop'])) {
        $days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
        
        foreach ($days as $dayIndex => $day) {
            if (isset($schedule['start'][$day]) && isset($schedule['stop'][$day])) {
                $startTimes = $schedule['start'][$day];
                $stopTimes = $schedule['stop'][$day];
                
                // Process each time period (i1, i2, i3)
                foreach (['i1', 'i2', 'i3'] as $periodIndex => $period) {
                    $startTime = isset($startTimes[$period]) ? $startTimes[$period] : '';
                    $stopTime = isset($stopTimes[$period]) ? $stopTimes[$period] : '';
                    
                    // Skip if no start time (means this period is not used)
                    if (empty($startTime) || $startTime === '0') {
                        continue;
                    }
                    
                    $scheduleEntries[] = [
                        'restaurant_id' => $v3_id,
                        'type' => 'delivery',
                        'day_of_week' => $dayIndex, // 0=Monday, 6=Sunday
                        'day_name' => ucfirst($day),
                        'period' => $periodIndex + 1,
                        'time_start' => $startTime,
                        'time_stop' => empty($stopTime) ? '23:59' : $stopTime
                    ];
                }
            }
        }
        
        echo "  Extracted " . count($scheduleEntries) . " schedule entries\n";
        foreach ($scheduleEntries as $entry) {
            echo "    - {$entry['day_name']}: {$entry['time_start']} - {$entry['time_stop']}\n";
        }
    }
    
    $scheduleResults[$v1_id] = [
        'v1_id' => $v1_id,
        'v3_id' => $v3_id,
        'restaurant_name' => $name,
        'schedule_entries' => $scheduleEntries
    ];
}

// Process Delivery Areas
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "Processing Delivery Areas...\n";
echo str_repeat("-", 60) . "\n";

$areaResults = [];

foreach ($deliveryAreaData as $restaurant) {
    $v1_id = $restaurant['v1_id'];
    $v3_id = $restaurant['v3_id'];
    $name = $restaurant['restaurant_name'];
    $blobData = $restaurant['blob_data'];
    
    echo "\n[$v1_id] $name (V3 ID: $v3_id)\n";
    
    // The deliveryArea BLOB is JSON-encoded string stored as serialized string
    // Format: s:123:"{"1":[...],"2":[...],...}"
    
    // Extract the JSON string from the serialized format
    if (preg_match('/s:\d+:"(.+)";?$/', $blobData, $matches)) {
        $jsonString = stripslashes($matches[1]);
        
        // Decode the JSON
        $areas = json_decode($jsonString, true);
        
        if ($areas === null) {
            echo "  ERROR: Could not decode JSON area data\n";
            continue;
        }
        
        echo "  Successfully decoded area data\n";
        
        // V1 format: {"1":[polygon points],"2":[...],...,"10":[]}
        // Each area key represents a delivery zone (1-10)
        $areaEntries = [];
        
        foreach ($areas as $areaNum => $coordinates) {
            if (empty($coordinates) || !is_array($coordinates)) {
                continue;
            }
            
            // Convert coordinates to PostGIS format
            $points = [];
            foreach ($coordinates as $point) {
                // Points can have various key names (lat/lng, ob/pb, Ya/Za, k/A, etc.)
                $lat = null;
                $lng = null;
                
                foreach ($point as $key => $value) {
                    if (in_array($key, ['lat', 'ob', 'Ya', 'k', 'nb', 'lb'])) {
                        $lat = $value;
                    }
                    if (in_array($key, ['lng', 'pb', 'Za', 'A', 'ob', 'mb'])) {
                        $lng = $value;
                    }
                }
                
                if ($lat !== null && $lng !== null) {
                    $points[] = "$lng $lat"; // PostGIS uses lng,lat order
                }
            }
            
            if (!empty($points)) {
                // Close the polygon by repeating the first point
                $points[] = $points[0];
                
                $polygonWKT = 'POLYGON((' . implode(',', $points) . '))';
                
                $areaEntries[] = [
                    'restaurant_id' => $v3_id,
                    'area_number' => $areaNum,
                    'area_name' => "Delivery Zone $areaNum",
                    'coordinates_count' => count($coordinates),
                    'polygon_wkt' => $polygonWKT
                ];
                
                echo "  Zone $areaNum: " . count($coordinates) . " coordinates\n";
            }
        }
        
        $areaResults[$v1_id] = [
            'v1_id' => $v1_id,
            'v3_id' => $v3_id,
            'restaurant_name' => $name,
            'area_entries' => $areaEntries
        ];
    } else {
        echo "  ERROR: Could not extract JSON from serialized format\n";
        echo "  Raw data (first 100 chars): " . substr($blobData, 0, 100) . "\n";
    }
}

// Process Fees
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "Processing Delivery Fees...\n";
echo str_repeat("-", 60) . "\n";

$feeResults = [];

foreach ($feeData as $restaurant) {
    $v1_id = $restaurant['v1_id'];
    $v3_id = $restaurant['v3_id'];
    $name = $restaurant['restaurant_name'];
    $blobData = $restaurant['blob_data'];
    
    echo "\n[$v1_id] $name (V3 ID: $v3_id)\n";
    
    // Unescape the blob data
    $unescaped = stripslashes($blobData);
    
    // Unserialize the PHP array
    $fees = @unserialize($unescaped);
    
    if ($fees === false) {
        echo "  ERROR: Could not unserialize fee data\n";
        echo "  Raw data: " . substr($blobData, 0, 100) . "\n";
        
        // Try to handle it as a simple value
        if (!empty($blobData) && is_numeric($blobData)) {
            $fees = [(string)$blobData];
            echo "  Using simple numeric value: $blobData\n";
        } else {
            continue;
        }
    }
    
    echo "  Successfully deserialized fee data\n";
    
    // V1 format: array with indices 0-9 representing different fee tiers
    // Usually only index 0 is used for flat fee
    $feeEntries = [];
    
    if (is_array($fees)) {
        foreach ($fees as $index => $feeValue) {
            if (!empty($feeValue) && $feeValue !== '0' && $feeValue !== '') {
                $feeEntries[] = [
                    'restaurant_id' => $v3_id,
                    'fee_tier' => $index,
                    'fee_value' => $feeValue,
                    'fee_type' => $index === 0 ? 'flat' : 'tiered'
                ];
                
                echo "  Tier $index: \$$feeValue\n";
            }
        }
    }
    
    $feeResults[$v1_id] = [
        'v1_id' => $v1_id,
        'v3_id' => $v3_id,
        'restaurant_name' => $name,
        'fee_entries' => $feeEntries
    ];
}

// Save results to JSON files for SQL generation
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "Saving deserialized data...\n";
echo str_repeat("-", 60) . "\n";

file_put_contents('deserialized_schedules.json', json_encode($scheduleResults, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
echo "  Saved: deserialized_schedules.json\n";

file_put_contents('deserialized_areas.json', json_encode($areaResults, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
echo "  Saved: deserialized_areas.json\n";

file_put_contents('deserialized_fees.json', json_encode($feeResults, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
echo "  Saved: deserialized_fees.json\n";

echo "\n" . str_repeat("=", 60) . "\n";
echo "BLOB Deserialization Complete!\n";
echo str_repeat("=", 60) . "\n";
echo "\nSummary:\n";
echo "  - Processed " . count($scheduleResults) . " schedule records\n";
echo "  - Processed " . count($areaResults) . " delivery area records\n";
echo "  - Processed " . count($feeResults) . " fee records\n";
echo "\nNext step: Run generate_v3_sql_from_blobs.php to create SQL INSERT statements\n\n";
?>








