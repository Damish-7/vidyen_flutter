<?php
require_once __DIR__ . '/config.php';

$conn = getDB();
$result = mysqli_query($conn, 'DESCRIBE pre_conference');

echo "Pre-conference table structure:\n\n";
while ($row = mysqli_fetch_assoc($result)) {
    $null = $row['Null'] === 'NO' ? 'REQUIRED' : 'nullable';
    $default = $row['Default'] ?? 'NULL';
    echo sprintf("%-35s | %-25s | %s | Default: %s\n", 
        $row['Field'], $row['Type'], $null, $default);
}
