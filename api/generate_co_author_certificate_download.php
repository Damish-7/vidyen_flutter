<?php
session_start();
include('config.php');

header_remove('Content-Type');

//  Get co-author name from URL
if (isset($_GET['name']) && trim($_GET['name']) !== '') {
    $fullName = htmlspecialchars(urldecode(trim($_GET['name'])));
} else {
    die("No co-author name provided.");
}

// Auth check only when accessed via browser without a name param from app
if (!isset($_GET['name']) && (
    !isset($_SESSION['user_id']) ||
    ($_SESSION['usertype'] != 'participant' && $_SESSION['usertype'] != 'admin')
)) {
    header('location:login.php');
    exit();
}

//  Load TCPDF
require_once('libraries/autoload.php');

//  Certificate image path
$imagePath = __DIR__ . '/certificates/co_author.jpeg';

if (!file_exists($imagePath)) {
    die('Certificate image not found. Please upload it in certificates folder.');
}

//  Create PDF
$pdf = new \TCPDF('L', 'mm', 'A4', true, 'UTF-8', false);
$pdf->SetCreator('VIDYEN Conference');
$pdf->SetTitle('Co-Author Certificate');

// Remove header/footer
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

// No margins
$pdf->SetMargins(0, 0, 0);
$pdf->SetAutoPageBreak(false, 0);

// Add page
$pdf->AddPage();

//  Add background image
$pdf->Image($imagePath, 0, 0, 297, 210, '', '', '', false, 300, '', false, false, 0);

//  Font settings
$pdf->SetFont('times', 'B', 16);
$pdf->SetTextColor(0, 0, 0);

//  Position (adjust if needed)
$nameWidth = 140;
$xPosition = 89;
$yPosition = 103;

$pdf->SetXY($xPosition, $yPosition);

//  Print Name (EXACT from URL)
$pdf->MultiCell($nameWidth, 7, $fullName, 0, 'L');

//  Clean filename
$fileName = 'CoAuthor_Certificate_' . preg_replace('/[^A-Za-z0-9]/', '_', $fullName) . '.pdf';

//  Output PDF
$pdf->Output($fileName, 'D');
?>