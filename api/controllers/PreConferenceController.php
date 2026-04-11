<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../middleware/Auth.php';

class PreConferenceController {

    // Lookup the registration_code for a logged-in user
    private function getRegCode(object $conn, string $userId): string {
        $uid   = mysqli_real_escape_string($conn, $userId);
        $lRow  = mysqli_fetch_assoc(mysqli_query($conn,
            "SELECT user_email FROM `login` WHERE user_id = '$uid' LIMIT 1"));
        if (!$lRow) Response::notFound('User not found');
        $email = mysqli_real_escape_string($conn, $lRow['user_email']);
        $rRow  = mysqli_fetch_assoc(mysqli_query($conn,
            "SELECT registration_code FROM `registration` WHERE email = '$email' LIMIT 1"));
        if (!$rRow) Response::notFound('Registration not found');
        return $rRow['registration_code'];
    }

    /**
     * POST /api/preconference
     * Submit preconference (participant)
     * DB table: pre_conference  |  ID col: pre_confernce_id
     */
    public function create(): void {
        $auth  = Auth::requireRole('participant');
        $input = json_decode(file_get_contents('php://input'), true);

        $required = ['subthemes', 'paper_title', 'keyword'];
        foreach ($required as $f) {
            if (empty($input[$f])) Response::error("Field '$f' is required");
        }

        $conn      = getDB();
        $createdBy = $auth['user_id'];
        $createdOn = date('d-m-Y');
        $esc = fn($v) => mysqli_real_escape_string($conn, $v);

        // Resolve registration_id
        $regCode = $this->getRegCode($conn, $createdBy);
        // If participant_id sent use it, otherwise use looked-up regCode
        $regId = $esc($input['participant_id'] ?? $regCode);

        // Auto-increment ID (note DB typo: pre_confernce_id)
        $idQ = mysqli_query($conn, "SELECT pre_confernce_id FROM `pre_conference` ORDER BY id DESC LIMIT 1");
        if (mysqli_num_rows($idQ) === 0) {
            $preId = 'PRE000001';
        } else {
            $row   = mysqli_fetch_assoc($idQ);
            $parts = explode('E', $row['pre_confernce_id']);
            $num   = isset($parts[1]) ? (int)$parts[1] + 1 : 1;
            $preId = 'PRE' . str_pad($num, 6, '0', STR_PAD_LEFT);
        }

        $query = "INSERT INTO `pre_conference`
                    (`pre_confernce_id`,`registration_id`,`sub_theme`,`title_paper`,
                     `keywords`,`abstract_background`,`abstract_rationale`,`abstract_objective`,
                     `abstract_outcome`,`abstract_structure`,`abstract_description`,
                     `participant`,`participant_description`,`max_participants`,
                     `workshop_overview`,`created_by`,`created_on`,`status`,`flag`)
                  VALUES
                    ('{$esc($preId)}','{$regId}','{$esc($input['subthemes'])}',
                     '{$esc($input['paper_title'])}','{$esc($input['keyword'])}',
                     '{$esc($input['paper_abstract'] ?? '')}',
                     '{$esc($input['abstract_rationale'] ?? '')}',
                     '{$esc($input['abstract_objective'] ?? '')}',
                     '{$esc($input['abstract_outcome'] ?? '')}',
                     '{$esc($input['abstract_structure'] ?? '')}',
                     '{$esc($input['abstract_description'] ?? '')}',
                     '{$esc($input['participant'] ?? '')}',
                     '{$esc($input['participant_description'] ?? '')}',
                     '{$esc($input['max_participants'] ?? '')}',
                     '{$esc($input['workshop_overview'] ?? '')}',
                     '{$esc($createdBy)}','{$esc($createdOn)}','0','0')";

        error_log("Pre-conference query: " . $query);
        try {
            if (!mysqli_query($conn, $query)) {
                error_log("SQL error: " . mysqli_error($conn));
                Response::serverError('Pre-conference submission failed: ' . mysqli_error($conn));
            }
        } catch (Exception $e) {
            error_log("Exception: " . $e->getMessage());
            Response::serverError('Pre-conference submission failed: ' . $e->getMessage());
        }

        Response::success(['preconference_id' => $preId], 'Pre-conference submission successful', 201);
    }

    /**
     * GET /api/preconference/my
     * Get own submissions
     */
    public function mySubmissions(): void {
        $auth = Auth::requireRole('participant');
        $conn = getDB();
        $uid  = $auth['user_id'];
        $esc  = fn($v) => mysqli_real_escape_string($conn, $v);

        $regCode = $this->getRegCode($conn, $uid);
        $result  = mysqli_query($conn,
            "SELECT pre_confernce_id AS preconference_id, title_paper AS paper_title,
                    sub_theme AS subthemes, status, created_on
             FROM `pre_conference` WHERE registration_id = '{$esc($regCode)}'"
        );
        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * GET /api/preconference/{id}
     * View one (participant/admin/reviewer)
     */
    public function viewOne(string $preId): void {
        Auth::require();
        $conn  = getDB();
        $preId = mysqli_real_escape_string($conn, $preId);

        $pre = mysqli_fetch_assoc(
            mysqli_query($conn,
                "SELECT * FROM `pre_conference` WHERE pre_confernce_id = '$preId' LIMIT 1")
        );
        if (!$pre) Response::notFound('Pre-conference submission not found');

        // Fetch authors from author_details table
        $authors = [];
        $authorQuery = mysqli_query($conn,
            "SELECT * FROM `author_details` WHERE abstract_id = '$preId' LIMIT 1");
        
        if ($authorQuery && mysqli_num_rows($authorQuery) > 0) {
            $authorRow = mysqli_fetch_assoc($authorQuery);
            
            // Parse comma-separated author data
            $firstNames = explode(',', $authorRow['first_name'] ?? '');
            $middleNames = explode(',', $authorRow['middle_name'] ?? '');
            $lastNames = explode(',', $authorRow['last_name'] ?? '');
            $emails = explode(',', $authorRow['author_email'] ?? '');
            $authorTypes = explode(',', $authorRow['author_type'] ?? '');
            $designations = explode(',', $authorRow['designation'] ?? '');
            $institutions = explode(',', $authorRow['author_institution'] ?? '');
            $cities = explode(',', $authorRow['author_city'] ?? '');
            $states = explode(',', $authorRow['author_state'] ?? '');
            $countries = explode(',', $authorRow['author_country'] ?? '');
            $pincodes = explode(',', $authorRow['author_pincode'] ?? '');
            $prefixes = explode(',', $authorRow['prefixes'] ?? '');
            
            $count = count($firstNames);
            for ($i = 0; $i < $count; $i++) {
                $authors[] = [
                    'prefix' => $prefixes[$i] ?? '',
                    'first_name' => $firstNames[$i] ?? '',
                    'middle_name' => $middleNames[$i] ?? '',
                    'last_name' => $lastNames[$i] ?? '',
                    'email' => $emails[$i] ?? '',
                    'author_type' => $authorTypes[$i] ?? '',
                    'designation' => $designations[$i] ?? '',
                    'institution' => $institutions[$i] ?? '',
                    'city' => $cities[$i] ?? '',
                    'state' => $states[$i] ?? '',
                    'country' => $countries[$i] ?? '',
                    'pincode' => $pincodes[$i] ?? '',
                ];
            }
        }

        Response::success(['preconference' => $pre, 'authors' => $authors]);
    }

    /**
     * GET /api/admin/preconference
     * List all (admin/reviewer)
     */
    public function listAll(): void {
        Auth::requireRole('admin', 'reviewer');
        $conn = getDB();
        $result = mysqli_query($conn,
            "SELECT p.pre_confernce_id AS preconference_id, p.registration_id,
                    p.title_paper AS paper_title, p.sub_theme AS subthemes,
                    p.status, p.created_on, r.full_name
             FROM `pre_conference` p
             LEFT JOIN `registration` r ON p.registration_id = r.registration_code
             ORDER BY p.id DESC"
        );
        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * PUT /api/admin/preconference/{id}/status
     */
    public function updateStatus(string $preId): void {
        Auth::requireRole('admin', 'reviewer');
        $input  = json_decode(file_get_contents('php://input'), true);
        $conn   = getDB();
        $preId  = mysqli_real_escape_string($conn, $preId);
        $status = mysqli_real_escape_string($conn, $input['status'] ?? '2');

        mysqli_query($conn,
            "UPDATE `pre_conference` SET status = '$status' WHERE pre_confernce_id = '$preId'"
        );
        Response::success(null, 'Status updated');
    }

    /**
     * POST /api/admin/preconference/{id}/assign-reviewer
     * Assign a PreConference Reviewer to a preconference submission
     */
    public function assignReviewer(string $preId): void {
        Auth::requireRole('admin');
        $input = json_decode(file_get_contents('php://input'), true);
        $conn  = getDB();
        $esc   = fn($v) => mysqli_real_escape_string($conn, $v ?? '');

        $reviewerCode = $esc($input['reviewer_code'] ?? '');
        if (!$reviewerCode) Response::error('reviewer_code is required');

        $preId = $esc($preId);

        // Fetch the registration_id for this preconference
        $preRow = mysqli_fetch_assoc(
            mysqli_query($conn, "SELECT registration_id FROM `pre_conference` WHERE pre_confernce_id = '$preId' LIMIT 1")
        );
        if (!$preRow) Response::notFound('Pre-conference not found');
        $regId = $esc($preRow['registration_id']);

        // Remove prior assignment for this preconf if any
        mysqli_query($conn, "DELETE FROM `assign_reviewer` WHERE abstract_id = '$preId'");

        // Insert new assignment
        mysqli_query($conn,
            "INSERT INTO `assign_reviewer` (reviewer_id, registration_id, abstract_id, status)
             VALUES ('$reviewerCode', '$regId', '$preId', 0)"
        );

        if (mysqli_affected_rows($conn) === 0) {
            Response::serverError('Failed to assign reviewer: ' . mysqli_error($conn));
        }

        // Update preconference status to Under Review (1)
        mysqli_query($conn,
            "UPDATE `pre_conference` SET status = 1 WHERE pre_confernce_id = '$preId'"
        );

        Response::success(null, 'Reviewer assigned successfully');
    }
}
