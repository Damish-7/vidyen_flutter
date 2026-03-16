<?php
// Test pre-conference INSERT query
require_once __DIR__ . '/config.php';

$conn = getDB();
$esc = fn($v) => mysqli_real_escape_string($conn, $v);

// Sample test data
$testData = [
    'pre_confernce_id' => 'PRE000099',
    'registration_id' => 'VIDYEN/TEST123',
    'subthemes' => 'Test Theme',
    'paper_title' => 'Test Paper Title',
    'keyword' => 'test, keywords',
    'paper_abstract' => 'This is a test abstract background',
    'abstract_rationale' => 'This is the rationale',
    'abstract_objective' => 'These are objectives',
    'abstract_outcome' => 'Expected outcomes',
    'abstract_structure' => 'Structure details',
    'abstract_description' => 'Description of the workshop',
    'participant' => 'Target participants',
    'participant_description' => 'Participant details',
    'max_participants' => '50',
    'workshop_overview' => 'Workshop overview text',
    'created_by' => 'test_user',
    'created_on' => date('d-m-Y'),
];

$query = "INSERT INTO `pre_conference`
            (`pre_confernce_id`,`registration_id`,`sub_theme`,`title_paper`,
             `keywords`,`abstract_background`,`abstract_rationale`,`abstract_objective`,
             `abstract_outcome`,`abstract_structure`,`abstract_description`,
             `participant`,`participant_description`,`max_participants`,
             `workshop_overview`,`created_by`,`created_on`,`status`,`flag`)
          VALUES
            ('{$esc($testData['pre_confernce_id'])}','{$esc($testData['registration_id'])}',
             '{$esc($testData['subthemes'])}','{$esc($testData['paper_title'])}',
             '{$esc($testData['keyword'])}','{$esc($testData['paper_abstract'])}',
             '{$esc($testData['abstract_rationale'])}','{$esc($testData['abstract_objective'])}',
             '{$esc($testData['abstract_outcome'])}','{$esc($testData['abstract_structure'])}',
             '{$esc($testData['abstract_description'])}','{$esc($testData['participant'])}',
             '{$esc($testData['participant_description'])}','{$esc($testData['max_participants'])}',
             '{$esc($testData['workshop_overview'])}','{$esc($testData['created_by'])}',
             '{$esc($testData['created_on'])}','0','0')";

echo "Testing INSERT query...\n\n";
echo "Query:\n" . $query . "\n\n";

try {
    if (mysqli_query($conn, $query)) {
        echo "✓ INSERT successful!" . PHP_EOL;
        echo "Inserted ID: " . mysqli_insert_id($conn) . PHP_EOL;
        
        // Clean up test data
        $deleteQuery = "DELETE FROM `pre_conference` WHERE pre_confernce_id = 'PRE000099'";
        mysqli_query($conn, $deleteQuery);
        echo "✓ Test data cleaned up" . PHP_EOL;
    } else {
        echo "✗ INSERT failed!" . PHP_EOL;
        echo "Error: " . mysqli_error($conn) . PHP_EOL;
    }
} catch (Exception $e) {
    echo "✗ Exception: " . $e->getMessage() . PHP_EOL;
}
