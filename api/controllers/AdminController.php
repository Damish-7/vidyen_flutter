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
     * List reviewers
     */
    public function listReviewers(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $result = mysqli_query($conn,
            "SELECT user_id, user_email, name, status FROM `login` WHERE usertype = 'reviewer'"
        );
        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }
}
