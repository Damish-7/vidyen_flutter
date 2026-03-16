<?php
// This file generates a certificate with the participant's name

function generateCertificate($participantName) {
    // Check if FPDI library exists
    if (file_exists(__DIR__ . '/vendor/autoload.php')) {
        require_once(__DIR__ . '/vendor/autoload.php');
        
        // Try to use FPDI if available
        if (class_exists('setasign\Fpdi\Fpdi')) {
            generateCertificateWithFPDI($participantName);
            return;
        }
    }
    
    // Fallback: Use TCPDF or FPDF if available
    if (file_exists(__DIR__ . '/vendor/tecnickcom/tcpdf/tcpdf.php')) {
        require_once(__DIR__ . '/vendor/tecnickcom/tcpdf/tcpdf.php');
        generateCertificateWithTCPDF($participantName);
        return;
    }
    
    // Final fallback: Create an HTML page that displays the certificate
    generateCertificateHTML($participantName);
}

function generateCertificateWithFPDI($participantName) {
    $pdf = new \setasign\Fpdi\Fpdi();
    $pdf->AddPage('L'); // Landscape orientation for certificate
    
    $templatePath = __DIR__ . '/certificates/Preconference participation- item analysis.pdf';
    
    if (file_exists($templatePath)) {
        $pageCount = $pdf->setSourceFile($templatePath);
        $tplId = $pdf->importPage(1);
        $pdf->useTemplate($tplId);
    }
    
    // Add the participant name
    // Adjust coordinates based on where "Presented to" appears on your certificate
    $pdf->SetFont('Arial', 'B', 24);
    $pdf->SetTextColor(0, 0, 128); // Dark blue color
    $pdf->SetXY(70, 110); // Adjust X and Y coordinates as needed
    $pdf->Cell(150, 10, $participantName, 0, 0, 'C');
    
    // Output the PDF
    $pdf->Output('I', 'Certificate_Preconference_' . str_replace(' ', '_', $participantName) . '.pdf');
}

function generateCertificateWithTCPDF($participantName) {
    $pdf = new TCPDF('L', 'mm', 'A4', true, 'UTF-8', false);
    
    $pdf->SetCreator('VIDYEN Conference');
    $pdf->SetAuthor('VIDYEN');
    $pdf->SetTitle('Pre-Conference Participation Certificate');
    
    $pdf->setPrintHeader(false);
    $pdf->setPrintFooter(false);
    
    $pdf->AddPage();
    
    $templatePath = __DIR__ . '/certificates/Preconference participation- item analysis.pdf';
    
    if (file_exists($templatePath)) {
        // Set the background PDF
        $pdf->setSourceFile($templatePath);
        $tplId = $pdf->importPage(1);
        $pdf->useTemplate($tplId);
    }
    
    // Add the participant name
    $pdf->SetFont('helvetica', 'B', 24);
    $pdf->SetTextColor(0, 0, 128);
    $pdf->SetXY(70, 110);
    $pdf->Cell(150, 10, $participantName, 0, 0, 'C');
    
    $pdf->Output('Certificate_Preconference_' . str_replace(' ', '_', $participantName) . '.pdf', 'I');
}

function generateCertificateHTML($participantName) {
    // HTML/CSS approach - displays the certificate in browser with name overlay
    $certificatePath = 'certificates/Preconference participation- item analysis.pdf';
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Certificate - <?php echo htmlspecialchars($participantName); ?></title>
        <style>
            body {
                margin: 0;
                padding: 20px;
                font-family: Arial, sans-serif;
                background-color: #f5f5f5;
            }
            .certificate-container {
                position: relative;
                max-width: 1000px;
                margin: 0 auto;
                background: white;
                box-shadow: 0 0 20px rgba(0,0,0,0.1);
            }
            .certificate-overlay {
                position: relative;
                width: 100%;
            }
            .participant-name {
                position: absolute;
                top: 52%; /* Adjust based on certificate layout */
                left: 50%;
                transform: translate(-50%, -50%);
                font-size: 28px;
                font-weight: bold;
                color: #003366;
                text-align: center;
                width: 80%;
                font-family: 'Georgia', serif;
            }
            .download-btn {
                display: block;
                margin: 20px auto;
                padding: 12px 30px;
                background-color: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 5px;
                text-align: center;
                max-width: 200px;
            }
            .download-btn:hover {
                background-color: #0056b3;
            }
            iframe {
                width: 100%;
                height: 800px;
                border: none;
            }
            .instructions {
                text-align: center;
                padding: 20px;
                background: #e9ecef;
                margin-bottom: 20px;
                border-radius: 5px;
            }
        </style>
    </head>
    <body>
        <div class="certificate-container">
            <div class="instructions">
                <h2>Pre-Conference Participation Certificate</h2>
                <p>Certificate for: <strong><?php echo htmlspecialchars($participantName); ?></strong></p>
                <p>To print this certificate with your name, use your browser's print function (Ctrl+P / Cmd+P) and select "Save as PDF"</p>
                <a href="<?php echo $certificatePath; ?>" class="download-btn" download>Download Template</a>
            </div>
            
            <div class="certificate-overlay">
                <iframe src="<?php echo $certificatePath; ?>"></iframe>
                <div class="participant-name"><?php echo htmlspecialchars($participantName); ?></div>
            </div>
        </div>
        
        <script>
            // Auto-adjust name position if needed
            window.addEventListener('load', function() {
                console.log('Certificate loaded for: <?php echo htmlspecialchars($participantName); ?>');
            });
        </script>
    </body>
    </html>
    <?php
}
?>
