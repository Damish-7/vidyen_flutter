<?php
require_once __DIR__ . '/config.php';

$conn = getDB();
$result = mysqli_query($conn, 'DESCRIBE assign_reviewer');

if (!$result) {
    echo "Table does not exist or error: " . mysqli_error($conn) . "\n";
    exit;
}
echo "assign_reviewer table structure:\n\n";
while ($row = mysqli_fetch_assoc($result)) {
    echo $row['Field'] . " | " . $row['Type'] . "\n";
}
