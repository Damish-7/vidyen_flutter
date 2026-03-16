<?php
require_once __DIR__ . '/config.php';

$conn = getDB();
$result = mysqli_query($conn, 'DESCRIBE registration');

echo "Registration table structure:\n\n";
while ($row = mysqli_fetch_assoc($result)) {
    $null = $row['Null'] === 'NO' ? 'REQUIRED' : 'nullable';
    $default = $row['Default'] ?? 'NULL';
    echo sprintf("%-30s | %-20s | %s | Default: %s\n", 
        $row['Field'], $row['Type'], $null, $default);
}

echo "\n\nLogin table structure:\n\n";
$result2 = mysqli_query($conn, 'DESCRIBE login');
while ($row = mysqli_fetch_assoc($result2)) {
    $null = $row['Null'] === 'NO' ? 'REQUIRED' : 'nullable';
    $default = $row['Default'] ?? 'NULL';
    echo sprintf("%-30s | %-20s | %s | Default: %s\n", 
        $row['Field'], $row['Type'], $null, $default);
}
