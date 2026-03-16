<?php
/**
 * Pre-Conference Certificate Preview
 */
session_start();
include('config.php');

// Check if user is logged in
if (!isset($_SESSION['user_id']) || ($_SESSION['usertype'] != 'participant' && $_SESSION['usertype'] != 'admin')) {
    header('location:login.php');
    exit();
}

// Get participant name from database
$id = $_SESSION['user_id'];
$query = "SELECT * FROM registration WHERE `registration_code`='$id'";
$result = mysqli_query($conn, $query);

if ($row = mysqli_fetch_assoc($result)) {
    $fullName = $row['honorofic'] . ' ' . $row['full_name'];
} else {
    die("User not found in registration.");
}

include('header.php'); 
?>

<div class="content-wrapper">
  <div class="row">
    <div class="col-lg-12 grid-margin stretch-card">
      <div class="card">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="card-title mb-0">Pre-Conference Participation Certificate Preview</h4>
            <a href="generate_certificate_download.php" class="btn btn-success">
              <i class="fa-solid fa-download"></i> Download Certificate
            </a>
          </div>
          
          <div class="certificate-preview" style="position: relative; width: 100%; max-width: 1200px; margin: 0 auto;">
            <style>
              .certificate-container {
                position: relative;
                width: 100%;
                border: 2px solid #ddd;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
              }
              .certificate-container img {
                width: 100%;
                height: auto;
                display: block;
              }
              .name-overlay {
                position: absolute;
                top: 49.2%;
                left: 32%;
                font-family: 'Times New Roman', Times, serif;
                font-size: 18px;
                font-weight: bold;
                color: #000000;
                text-align: left;
                white-space: nowrap;
                pointer-events: none;
              }
            </style>
            
            <div class="certificate-container">
              <img src="certificates/preconference_certificate.jpg" alt="Pre-Conference Certificate" />
              <div class="name-overlay"><?php echo htmlspecialchars($fullName); ?></div>
            </div>
          </div>
          
          <div class="mt-3 text-center">
            <a href="participant_certificates.php" class="btn btn-secondary">
              <i class="fa-solid fa-arrow-left"></i> Back to Certificates
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<?php 
include('footer.php');
?>
