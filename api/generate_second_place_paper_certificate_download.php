<?php
/**
 * Certificate Download - Takes certificate image + adds participant name
 * 
 * SETUP: Convert PDF to image first using convert_certificate_helper.php
 * Save as: certificates/2ND_PLACE_PAPER.jpg (or .png)
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

// Get user's generated certificates
$generated_certs = [];

$query = "SELECT certificate_type FROM certificate_generated WHERE registration_code = '$id'";
$result = mysqli_query($conn, $query);
while($row = mysqli_fetch_assoc($result)) {
    $generated_certs[] = $row['certificate_type'];
}

// Helper function to check if certificate is generated
function isCertificateGenerated($cert_type, $generated_certs) {
    return in_array($cert_type, $generated_certs);
}

// Check if this certificate has been generated for the user
if (!isCertificateGenerated('second_place_paper', $generated_certs)) {
    header('location:participant_certificates.php');
    exit();
}

// Get participant name from database
$query = "SELECT * FROM registration WHERE `registration_code`='$id'";
$result = mysqli_query($conn, $query);

if ($row = mysqli_fetch_assoc($result)) {
    $fullName = $row['honorofic'] . ' ' . $row['full_name'];
} else {
    die("User not found in registration.");
}

require_once('libraries/autoload.php');

// Certificate image path - using relative path (works on both local and live)
$imagePath = __DIR__ . '/certificates/2ND_PLACE_PAPER.jpg';

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
                <strong>Simple Setup:</strong> Just place your certificate JPEG/PNG image in the certificates folder!
            </div>
            
            <h3 style="color: #333; margin-top: 30px;">Option 1: Upload JPEG/JPG Image (Easiest)</h3>
            
            <div style="background: #e3f2fd; padding: 20px; margin: 15px 0; border-radius: 5px;">
                <p><strong>If you have the certificate as JPEG/JPG:</strong></p>
                <ol>
                    <li>Click the upload button below</li>
                    <li>Select your certificate JPEG/JPG file</li>
                    <li>Done! It will be saved as <code>2ND_PLACE_PAPER.jpg</code></li>
                </ol>
                <a href="upload_certificate_image.php" style="display: inline-block; background: #4CAF50; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold; margin-top: 10px;">
                    📤 Upload JPEG Image →
                </a>
            </div>
            
            <h3 style="color: #333; margin-top: 30px;">Option 2: Manual File Copy</h3>
            
            <div style="background: #e8f5e9; padding: 20px; margin: 15px 0; border-radius: 5px;">
                <p>Copy your certificate image file to:</p>
                <code style="display: block; background: white; padding: 10px; border-radius: 5px; margin: 10px 0;">
                    certificates/2ND_PLACE_PAPER.jpg
                </code>
                <p style="margin-top: 15px;"><small>Or use .png or .jpeg extension</small></p>
            </div>
            
            <div style="background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; font-size: 14px;">
                <strong>Accepted formats:</strong>
                <ul style="margin: 10px 0;">
                    <li>2ND_PLACE_PAPER.jpg</li>
                    <li>2ND_PLACE_PAPER.jpeg</li>
                    <li>2ND_PLACE_PAPER.png</li>
                </ul>
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
$pdf->SetTitle('2nd Place Paper Award Certificate');
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

// Position the name closer to "Presented to"
$nameWidth = 140;                       // Width of name area
$xPosition = 78.605;                    // Moved 3.5% left (~10.395mm) from 89mm
$yPosition = 111.8;                     // Moved 5% down (~10.5mm) from 101.3mm

$pdf->SetXY($xPosition, $yPosition);
$pdf->Cell($nameWidth, 7, $fullName, 0, 0, 'L');  // No underline, left align

// Download the PDF
$pdf->Output('Certificate_2nd_Place_Paper_' . str_replace(' ', '_', $fullName) . '.pdf', 'D');
?>