<?php
require_once 'config.php';

$conn = getDB();
$result = mysqli_query($conn, 'SELECT user_email, usertype, status FROM login LIMIT 5');

if (mysqli_num_rows($result) === 0) {
    echo "No users found in database!\n";
} else {
    echo "Users in database:\n";
    while($row = mysqli_fetch_assoc($result)) {
        echo "- Email: {$row['user_email']}, Type: {$row['usertype']}, Status: {$row['status']}\n";
    }
}
