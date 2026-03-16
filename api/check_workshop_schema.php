<?php
// Check workshop table schema
require_once __DIR__ . '/config.php';

$conn = getDB();
$result = mysqli_query($conn, "DESCRIBE workshop");

echo "Workshop table structure:\n\n";
while ($row = mysqli_fetch_assoc($result)) {
    $null = $row['Null'] == 'NO' ? 'REQUIRED' : 'OPTIONAL';
    printf("%-35s | %-25s | %-8s | Default: %s\n", 
        $row['Field'], 
        $row['Type'], 
        $null,
        $row['Default'] ?? 'NULL'
    );
}
