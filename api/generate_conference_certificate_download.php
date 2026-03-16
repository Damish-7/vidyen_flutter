<?php
/**
 * Conference Certificate Download - Takes certificate image + adds participant name
 */

session_start();
include('config.php');

header_remove('Content-Type');
$conn = getDB();

if (isset($_GET['id']) && !empty($_GET['id'])) {
    $id = mysqli_real_escape_string($conn, $_GET['id']);
} elseif (isset($_SESSION['user_id'])) {
    if ($_SESSION['usertype'] != 'participant' && $_SESSION['usertype'] != 'admin') {
        header('location:login.php');
        exit();
    }
    $id = $_SESSION['user_id'];
} else {
    die("Unauthorized access.");
}

$query = "SELECT * FROM registration WHERE `registration_code`='$id'";
$result = mysqli_query($conn, $query);

if ($row = mysqli_fetch_assoc($result)) {
    $fullName = $row['honorofic'] . ' ' . $row['full_name'];
} else {
    die("User not found in registration.");
}

require_once('libraries/autoload.php');

// Certificate image path - using relative path (works on both local and live)
$imagePath = __DIR__ . '/certificates/conference_participation.jpg';

if (!file_exists($imagePath)) {
    // Image not found - show error with instructions
    die('
    <html>
    <head>
        <title>Setup Required</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body style="font-family: Arial; padding: 50px; background: #f5f5f5;">
        <div style="max-width: 700px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <h2 style="color: #d32f2f; margin-bottom: 20px;">⚠ Certificate Image Not Found</h2>
            
            <div style="background: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0;">
                <strong>Setup Required:</strong> Please upload the conference_participation.jpg certificate image!
            </div>
            
            <div style="background: #e8f5e9; padding: 20px; margin: 15px 0; border-radius: 5px;">
                <p>Upload your certificate image file to:</p>
                <code style="display: block; background: white; padding: 10px; border-radius: 5px; margin: 10px 0;">
                    certificates/conference_participation.jpg
                </code>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
                <a href="participant_certificates.php" style="color: #666; text-decoration: none;">← Back to Certificates</a>
            </div>
        </div>
    </body>
    </html>
    ');
}

// Create PDF with certificate image as background
$pdf = new \TCPDF('L', 'mm', 'A4', true, 'UTF-8', false);
$pdf->SetCreator('VIDYEN Conference');
$pdf->SetTitle('Conference Participation Certificate');
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);
$pdf->SetMargins(0, 0, 0);
$pdf->SetAutoPageBreak(false, 0);
$pdf->AddPage();

// Add certificate image as background (full page)
$pdf->Image($imagePath, 0, 0, 297, 210, '', '', '', false, 300, '', false, false, 0);

// Add participant name on top of the certificate
// Position based on "Presented to" location in the certificate
$pdf->SetFont('times', 'B', 16);        // Times New Roman Bold, 16pt
$pdf->SetTextColor(0, 0, 0);            // Black color

// Position the name: 3% right and 1% up from previous position
$nameWidth = 140;                       // Width of name area
$xPosition = 91.97;                     // 3% right of 297mm = ~8.91mm, so 83.06 + 8.91 = 91.97mm
$yPosition = 111.8;                     // 1% up of 210mm = ~2.1mm, so 113.9 - 2.1 = 111.8mm

$pdf->SetXY($xPosition, $yPosition);
$pdf->Cell($nameWidth, 7, $fullName, 0, 0, 'L');  // No underline, left align

// Download the PDF
$pdf->Output('Certificate_Conference_' . str_replace(' ', '_', $fullName) . '.pdf', 'D');
?>
