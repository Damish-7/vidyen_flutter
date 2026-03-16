<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../middleware/Auth.php';

class CertificateController {

    /**
     * GET /api/certificates/my
     * Get all available certificates for a participant
     */
    public function myCertificates(): void {
        $auth = Auth::requireRole('participant');
        $conn = getDB();
        $uid  = mysqli_real_escape_string($conn, $auth['user_id']);

        // Get registration code
        $emailQ   = mysqli_query($conn, "SELECT user_email FROM `login` WHERE user_id = '$uid' LIMIT 1");
        $loginRow = mysqli_fetch_assoc($emailQ);
        if (!$loginRow) Response::notFound('User not found');

        $email  = mysqli_real_escape_string($conn, $loginRow['user_email']);
        $regQ   = mysqli_query($conn, "SELECT registration_code, full_name FROM registration WHERE email = '$email' LIMIT 1");
        $regRow = mysqli_fetch_assoc($regQ);
        if (!$regRow) Response::notFound('Registration not found');

        $regCode = $regRow['registration_code'];

        // Fetch from certificate_generated table
        $certs = [];
        $certResult = @mysqli_query($conn,
            "SELECT certificate_type FROM `certificate_generated` WHERE registration_code = '$regCode'"
        );
        if ($certResult) {
            while ($row = mysqli_fetch_assoc($certResult)) {
                $certs[] = $row['certificate_type'];
            }
        }

        // Check for paper presentation
        $hasPaper = false;
        $paperQuery = "SELECT * FROM abstract WHERE registration_id = '$regCode' 
                       AND (type_of_presentation = 'Oral Presentations for research submission' 
                       OR type_of_presentation = 'Oral Presentations for Speciality Research')
                       LIMIT 1";
        $paperResult = mysqli_query($conn, $paperQuery);
        if ($paperResult && mysqli_num_rows($paperResult) > 0) {
            $hasPaper = true;
        }

        // Check for poster presentation
        $hasPoster = false;
        $posterQuery = "SELECT * FROM abstract WHERE registration_id = '$regCode' 
                        AND type_of_presentation = 'Posters'
                        LIMIT 1";
        $posterResult = mysqli_query($conn, $posterQuery);
        if ($posterResult && mysqli_num_rows($posterResult) > 0) {
            $hasPoster = true;
        }

        // Check for Yenvision Lightning Talk
        $hasYenvision = false;
        $yenvisionQuery = "SELECT * FROM abstract WHERE registration_id = '$regCode' 
                           AND type_of_presentation = 'Yenvision- Lightning talk'
                           LIMIT 1";
        $yenvisionResult = mysqli_query($conn, $yenvisionQuery);
        if ($yenvisionResult && mysqli_num_rows($yenvisionResult) > 0) {
            $hasYenvision = true;
        }

        Response::success([
            'registration_code' => $regCode,
            'full_name'         => $regRow['full_name'],
            'generated_certificates' => $certs,
            'has_paper_presentation' => $hasPaper,
            'has_poster_presentation' => $hasPoster,
            'has_yenvision_lightning_talk' => $hasYenvision
        ]);
    }

    /**
     * GET /api/certificates/{type}/{regCode}
     * Download certificate (returns download URL)
     */
    public function downloadInfo(string $type, string $regCode): void {
        $auth = Auth::require();
        $conn = getDB();

        $regCode = mysqli_real_escape_string($conn, $regCode);

        // Map type to PHP file endpoint
        $typeMap = [
            'conference'                     => 'generate_conference_certificate_download.php',
            'paper_presentation'             => 'generate_paper_presentation_certificate_download.php',
            'poster_presentation'            => 'generate_poster_presentation_certificate_download.php',
            'yenvision_lightning_talk'       => 'generate_yenvision_lightning_talk_certificate_download.php',
            'preconference_item_analysis'    => 'generate_certificate_download.php',
            'mindful_map'                    => 'generate_mindfulmap_certificate_download.php',
            'sage'                           => 'generate_sage_certificate_download.php',
            'itlm'                           => 'generate_itlm_certificate_download.php',
            'workshop_bridging'              => 'generate_workshop_bridging_certificate_download.php',
            'workshop_proms_prems'           => 'generate_workshop_proms_prems_certificate_download.php',
            'workshop_microteaching'         => 'generate_workshop_microteaching_certificate_download.php',
            'first_place_paper'              => 'generate_first_place_paper_certificate_download.php',
            'second_place_paper'             => 'generate_second_place_paper_certificate_download.php',
            'first_place_poster'             => 'generate_first_place_poster_certificate_download.php',
            'second_place_poster'            => 'generate_second_place_poster_certificate_download.php',
            'first_place_yenvision'          => 'generate_first_place_yenvision_certificate_download.php',
            'second_place_yenvision'         => 'generate_second_place_yenvision_certificate_download.php',
        ];

        if (!isset($typeMap[$type])) {
            Response::error('Unknown certificate type');
        }

        // Construct base URL (use localhost:8000 for dev server)
        $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'];
        $baseUrl = "$protocol://$host/";

        Response::success([
            'download_url' => $baseUrl . $typeMap[$type] . "?id=$regCode"
        ]);
    }

    /**
     * GET /api/admin/certificates
     * List all generated certificates (admin)
     */
    public function listAll(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $result = @mysqli_query($conn,
            "SELECT ct.*, r.full_name
             FROM `certificate_generated` ct
             LEFT JOIN `registration` r ON ct.registration_code = r.registration_code
             ORDER BY ct.id DESC"
        );

        $rows = [];
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        }
        Response::success($rows);
    }
}
