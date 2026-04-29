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
     * GET /api/certificates/co-authors
     * Get co-authors list for the current participant
     */
    public function myCoAuthors(): void {
        $auth = Auth::requireRole('participant');
        $conn = getDB();
        $uid  = mysqli_real_escape_string($conn, $auth['user_id']);

        $emailQ   = mysqli_query($conn, "SELECT user_email FROM `login` WHERE user_id = '$uid' LIMIT 1");
        $loginRow = mysqli_fetch_assoc($emailQ);
        if (!$loginRow) Response::notFound('User not found');

        $email   = mysqli_real_escape_string($conn, $loginRow['user_email']);
        $regQ    = mysqli_query($conn, "SELECT registration_code FROM registration WHERE email = '$email' LIMIT 1");
        $regRow  = mysqli_fetch_assoc($regQ);
        if (!$regRow) Response::notFound('Registration not found');

        $regCode = mysqli_real_escape_string($conn, $regRow['registration_code']);

        $result = @mysqli_query($conn,
            "SELECT first_name, middle_name, last_name
             FROM author_details
             WHERE registration_id = '$regCode'
             AND FIND_IN_SET('Co Author', REPLACE(author_type, ', ', ','))"
        );

        $coAuthors = [];
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) {
                $firstNames  = array_map('trim', explode(',', $row['first_name']));
                $middleNames = array_map('trim', explode(',', $row['middle_name']));
                $lastNames   = array_map('trim', explode(',', $row['last_name']));

                // Remove first element (main/presenting author)
                array_shift($firstNames);
                array_shift($middleNames);
                array_shift($lastNames);

                $count = count($firstNames);
                for ($i = 0; $i < $count; $i++) {
                    $fname = $firstNames[$i] ?? '';
                    $mname = $middleNames[$i] ?? '';
                    $lname = $lastNames[$i] ?? '';
                    if ($fname !== '') {
                        $fullName = trim('Dr. ' . $fname . ' ' . $mname . ' ' . $lname);
                        $coAuthors[] = ['full_name' => $fullName];
                    }
                }
            }
        }

        Response::success($coAuthors);
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
            "SELECT ct.*, r.full_name, r.honorofic, r.email
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

    /**
     * POST /api/admin/certificates/generate
     * Generate certificates for a batch of participants
     * Body: { "certificate_type": "...", "users": ["REG001", "REG002", ...] }
     */
    public function generate(): void {
        $auth  = Auth::requireRole('admin');
        $input = json_decode(file_get_contents('php://input'), true);
        $conn  = getDB();

        $certType = trim($input['certificate_type'] ?? '');
        $users    = $input['users'] ?? [];

        if (empty($certType)) Response::error('certificate_type is required');
        if (empty($users) || !is_array($users)) Response::error('users array is required');

        $allowedTypes = [
            'preconference_item_analysis', 'mindful_map', 'sage', 'itlm',
            'workshop_bridging', 'workshop_proms_prems', 'workshop_microteaching',
            'first_place_paper', 'second_place_paper',
            'first_place_poster', 'second_place_poster',
            'first_place_yenvision', 'second_place_yenvision',
            'co_author_certificate',
        ];
        if (!in_array($certType, $allowedTypes)) Response::error('Invalid certificate type');

        $adminId  = $auth['user_id'];
        $count    = 0;

        try {
            $stmt = mysqli_prepare($conn,
                "INSERT INTO `certificate_generated` (registration_code, certificate_type, generated_by)
                 VALUES (?, ?, ?)
                 ON DUPLICATE KEY UPDATE generated_by = ?, generated_date = NOW()"
            );

            foreach ($users as $regCode) {
                $regCode = trim((string)$regCode);
                if (empty($regCode)) continue;

                mysqli_stmt_bind_param($stmt, 'ssss', $regCode, $certType, $adminId, $adminId);
                if (mysqli_stmt_execute($stmt)) $count++;
            }

            mysqli_stmt_close($stmt);
        } catch (\Throwable $e) {
            Response::serverError('Database error: ' . $e->getMessage());
        }

        Response::success(['generated' => $count], "Certificates generated for $count participant(s)");
    }

    /**
     * GET /api/admin/co-authors
     * List all co-authors from author_details (admin)
     */
    public function listCoAuthors(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $result = @mysqli_query($conn,
            "SELECT
                registration_id,
                CONCAT(
                    SUBSTRING_INDEX(first_name, ',', 1), ' ',
                    SUBSTRING_INDEX(middle_name, ',', 1), ' ',
                    SUBSTRING_INDEX(last_name, ',', 1)
                ) AS full_name,
                SUBSTRING_INDEX(author_email, ',', 1) AS author_email
             FROM author_details
             WHERE LOWER(author_type) LIKE '%co author%'"
        );

        $rows = [];
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        }
        Response::success($rows);
    }

    /**
     * DELETE /api/admin/certificates/{id}
     * Revoke a generated certificate record
     */
    public function revoke(string $id): void {
        Auth::requireRole('admin');
        $conn = getDB();
        $id   = mysqli_real_escape_string($conn, $id);

        $exists = @mysqli_fetch_assoc(mysqli_query($conn,
            "SELECT id FROM `certificate_generated` WHERE id = '$id' LIMIT 1"
        ));
        if (!$exists) Response::notFound('Certificate record not found');

        mysqli_query($conn, "DELETE FROM `certificate_generated` WHERE id = '$id'");
        Response::success(null, 'Certificate revoked');
    }
}
