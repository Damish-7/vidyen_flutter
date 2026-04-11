<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../middleware/Auth.php';

class AdminController {

    /**
     * GET /api/admin/dashboard
     * Summary counts for admin dashboard
     */
    public function dashboard(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $stats = [];

        $tables = [
            'total_registrations' => "SELECT COUNT(*) as cnt FROM `registration`",
            'active_participants'  => "SELECT COUNT(*) as cnt FROM `registration` WHERE status = '1'",
            'pending_approval'     => "SELECT COUNT(*) as cnt FROM `registration` WHERE status = '0'",
            'total_abstracts'      => "SELECT COUNT(*) as cnt FROM `abstract`",
            'evaluated_abstracts'  => "SELECT COUNT(*) as cnt FROM `abstract` WHERE status = '2'",
            'total_preconference'  => "SELECT COUNT(*) as cnt FROM `pre_conference`",
            'total_workshops'      => "SELECT COUNT(*) as cnt FROM `workshop`",
        ];

        foreach ($tables as $key => $query) {
            $r = @mysqli_query($conn, $query);
            $stats[$key] = $r ? (int)mysqli_fetch_assoc($r)['cnt'] : 0;
        }

        Response::success($stats);
    }

    /**
     * GET /api/admin/users
     * List all login users (admin)
     */
    public function listUsers(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $result = mysqli_query($conn,
            "SELECT user_id, user_email, usertype, user_name, status FROM `login` ORDER BY user_id DESC"
        );
        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * PUT /api/admin/users/{id}/toggle-status
     */
    public function toggleUserStatus(string $userId): void {
        Auth::requireRole('admin');
        $conn   = getDB();
        $userId = mysqli_real_escape_string($conn, $userId);

        $cur = mysqli_fetch_assoc(mysqli_query($conn,
            "SELECT status FROM `login` WHERE user_id = '$userId' LIMIT 1"
        ));
        if (!$cur) Response::notFound('User not found');

        $newStatus = $cur['status'] == '1' ? '0' : '1';
        mysqli_query($conn, "UPDATE `login` SET status = '$newStatus' WHERE user_id = '$userId'");
        Response::success(['new_status' => $newStatus], 'User status updated');
    }

    /**
     * GET /api/admin/messages
     * View all contact messages (admin)
     */
    public function messages(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $result = @mysqli_query($conn,
            "SELECT * FROM `contact` ORDER BY id DESC"
        );
        $rows = [];
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        }
        Response::success($rows);
    }

    /**
     * GET /api/admin/reviewers
     * List all reviewers from reviewer table
     */
    public function listReviewers(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $result = mysqli_query($conn,
            "SELECT id, reviewer_code, name, email, phone_number, designation, institution, address, review_type
             FROM `reviewer` ORDER BY id DESC"
        );
        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * GET /api/admin/reviewers/{id}
     * View single reviewer
     */
    public function viewReviewer(string $id): void {
        Auth::requireRole('admin');
        $conn = getDB();
        $id   = mysqli_real_escape_string($conn, $id);

        $row = mysqli_fetch_assoc(
            mysqli_query($conn,
                "SELECT id, reviewer_code, name, email, phone_number, designation,
                        institution, address, review_type
                 FROM `reviewer` WHERE id = '$id' LIMIT 1")
        );
        if (!$row) Response::notFound('Reviewer not found');
        Response::success($row);
    }

    /**
     * POST /api/admin/reviewers
     * Add a new reviewer
     */
    public function addReviewer(): void {
        Auth::requireRole('admin');
        $input = json_decode(file_get_contents('php://input'), true);
        $conn  = getDB();
        $esc   = fn($v) => mysqli_real_escape_string($conn, $v ?? '');

        $required = ['name', 'email', 'review_type'];
        foreach ($required as $f) {
            if (empty($input[$f])) Response::error("Field '$f' is required");
        }

        // Generate reviewer_code
        $lastRow = mysqli_fetch_assoc(
            mysqli_query($conn, "SELECT reviewer_code FROM `reviewer` ORDER BY id DESC LIMIT 1")
        );
        if ($lastRow) {
            $parts = explode('R', $lastRow['reviewer_code']);
            $num   = isset($parts[1]) ? (int)$parts[1] + 1 : 1;
            $code  = 'RVR' . str_pad($num, 4, '0', STR_PAD_LEFT);
        } else {
            $code = 'RVR0001';
        }

        mysqli_query($conn,
            "INSERT INTO `reviewer` (reviewer_code, name, email, phone_number, designation, institution, address, review_type)
             VALUES ('{$esc($code)}','{$esc($input['name'])}','{$esc($input['email'])}',
                     '{$esc($input['phone'])}','{$esc($input['designation'])}',
                     '{$esc($input['institution'])}','{$esc($input['address'])}',
                     '{$esc($input['review_type'])}')"
        );

        if (mysqli_affected_rows($conn) === 0) {
            Response::serverError('Failed to add reviewer: ' . mysqli_error($conn));
        }

        Response::success(['reviewer_code' => $code], 'Reviewer added successfully', 201);
    }

    /**
     * GET /api/reviewer/dashboard
     * Stats for the logged-in reviewer
     */
    public function reviewerDashboard(): void {
        $auth = Auth::requireRole('reviewer');
        $conn = getDB();
        $reviewerId = mysqli_real_escape_string($conn, $auth['user_id']);

        // Get reviewer type
        $r = @mysqli_query($conn, "SELECT review_type FROM `reviewer` WHERE reviewer_code = '$reviewerId' LIMIT 1");
        $row = $r ? mysqli_fetch_assoc($r) : null;
        $reviewType = $row['review_type'] ?? '';

        // Stats from assign_reviewer
        $total = 0; $pending = 0; $reviewed = 0;
        $rTotal = @mysqli_query($conn, "SELECT COUNT(*) as cnt FROM `assign_reviewer` WHERE reviewer_id = '$reviewerId'");
        if ($rTotal) $total = (int)(mysqli_fetch_assoc($rTotal)['cnt'] ?? 0);

        $rPending = @mysqli_query($conn, "SELECT COUNT(*) as cnt FROM `assign_reviewer` WHERE reviewer_id = '$reviewerId' AND status != 1");
        if ($rPending) $pending = (int)(mysqli_fetch_assoc($rPending)['cnt'] ?? 0);

        $rReviewed = @mysqli_query($conn, "SELECT COUNT(*) as cnt FROM `assign_reviewer` WHERE reviewer_id = '$reviewerId' AND status = 1");
        if ($rReviewed) $reviewed = (int)(mysqli_fetch_assoc($rReviewed)['cnt'] ?? 0);

        Response::success([
            'review_type' => $reviewType,
            'total'       => $total,
            'pending'     => $pending,
            'reviewed'    => $reviewed,
        ]);
    }

    /**
     * GET /reviewer/abstracts
     * List assigned abstracts for the logged-in reviewer (joined with abstract details)
     */
    public function reviewerAbstracts(): void {
        $auth = Auth::requireRole('reviewer');
        $conn = getDB();
        $reviewerId = mysqli_real_escape_string($conn, $auth['user_id']);

        $result = @mysqli_query($conn,
            "SELECT ar.id, ar.reviewer_id, ar.registration_id, ar.abstract_id, ar.status,
                    a.paper_title, a.sub_theme, a.type_of_presentation, a.status AS abstract_status
             FROM `assign_reviewer` ar
             LEFT JOIN `abstract` a ON ar.abstract_id = a.abstract_id
             WHERE ar.reviewer_id = '$reviewerId'
             ORDER BY ar.id ASC"
        );

        $rows = [];
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        }
        Response::success($rows);
    }
}
