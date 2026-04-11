<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../middleware/Auth.php';

class AbstractController {

    /**
     * POST /api/abstracts
     * Submit a new abstract (participant)
     */
    public function create(): void {
        $auth = Auth::requireRole('participant');
        $input = json_decode(file_get_contents('php://input'), true);

        $required = ['register_id','sub_themes','type_presentation','cat_presentation',
                     'title_paper','keywords','abstract_details'];
        foreach ($required as $f) {
            if (empty($input[$f])) Response::error("Field '$f' is required");
        }

        $conn = getDB();
        $createdBy  = $auth['user_id'];
        $createdOn  = date('d-m-Y');

        // Auto-increment abstract ID
        $idQ = mysqli_query($conn, "SELECT abstract_id FROM `abstract` ORDER BY abstract_id DESC LIMIT 1");
        if (mysqli_num_rows($idQ) === 0) {
            $abstractId = 'AUT000001';
        } else {
            $row = mysqli_fetch_assoc($idQ);
            $abstractId = ++$row['abstract_id'];
        }

        $esc = fn($v) => mysqli_real_escape_string($conn, $v);

        $query = "INSERT INTO `abstract`
                    (`registration_id`,`abstract_id`,`sub_theme`,`type_of_presentation`,
                     `category_presentation`,`paper_title`,`keywords`,`paper_abstract`,
                     `created_by`,`created_on`)
                  VALUES
                    ('{$esc($input['register_id'])}','$abstractId',
                     '{$esc($input['sub_themes'])}','{$esc($input['type_presentation'])}',
                     '{$esc($input['cat_presentation'])}','{$esc($input['title_paper'])}',
                     '{$esc($input['keywords'])}','{$esc(addslashes($input['abstract_details']))}',
                     '$createdBy','$createdOn')";

        if (!mysqli_query($conn, $query)) {
            Response::serverError('Abstract submission failed: ' . mysqli_error($conn));
        }

        // Insert authors if provided
        if (!empty($input['authors']) && is_array($input['authors'])) {
            foreach ($input['authors'] as $author) {
                $aQuery = "INSERT INTO `author_details`
                            (`registration_id`,`abstract_id`,`first_name`,`middle_name`,`last_name`,
                             `author_email`,`author_type`,`designation`,`author_institution`,
                             `author_city`,`author_state`,`author_country`,`author_pincode`,
                             `created_by`,`created_on`)
                           VALUES
                            ('{$esc($input['register_id'])}','$abstractId',
                             '{$esc($author['first_name'] ?? '')}','{$esc($author['middle_name'] ?? '')}',
                             '{$esc($author['last_name'] ?? '')}','{$esc($author['email'] ?? '')}',
                             '{$esc($author['type_author'] ?? '')}','{$esc($author['designation'] ?? '')}',
                             '{$esc($author['institution'] ?? '')}','{$esc($author['city'] ?? '')}',
                             '{$esc($author['state'] ?? '')}','{$esc($author['country'] ?? '')}',
                             '{$esc($author['pincode'] ?? '')}','$createdBy','$createdOn')";
                mysqli_query($conn, $aQuery);
            }
        }

        Response::success(['abstract_id' => $abstractId], 'Abstract submitted successfully', 201);
    }

    /**
     * GET /api/abstracts/my
     * Get my abstracts (participant)
     */
    public function myAbstracts(): void {
        $auth = Auth::requireRole('participant');
        $conn = getDB();

        $userId = mysqli_real_escape_string($conn, $auth['user_id']);

        // Get registration_code from login email
        $emailQ = mysqli_query($conn, "SELECT user_email FROM `login` WHERE user_id = '$userId' LIMIT 1");
        $loginRow = mysqli_fetch_assoc($emailQ);
        if (!$loginRow) Response::notFound('User not found');

        $email = mysqli_real_escape_string($conn, $loginRow['user_email']);
        $regQ  = mysqli_query($conn, "SELECT registration_code FROM registration WHERE email = '$email' LIMIT 1");
        $regRow = mysqli_fetch_assoc($regQ);
        if (!$regRow) Response::notFound('Registration not found');

        $regId = mysqli_real_escape_string($conn, $regRow['registration_code']);
        $result = mysqli_query($conn, "SELECT abstract_id, paper_title, sub_theme, type_of_presentation, category_presentation, status, created_on FROM `abstract` WHERE registration_id = '$regId'");

        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * GET /api/abstracts/{id}
     * View full abstract + authors
     */
    public function viewOne(string $abstractId): void {
        $auth = Auth::require();
        $conn = getDB();
        $abstractId = mysqli_real_escape_string($conn, $abstractId);

        $abstract = mysqli_fetch_assoc(
            mysqli_query($conn, "SELECT * FROM `abstract` WHERE abstract_id = '$abstractId' LIMIT 1")
        );
        if (!$abstract) Response::notFound('Abstract not found');

        $authorsResult = mysqli_query($conn, "SELECT * FROM `author_details` WHERE abstract_id = '$abstractId'");
        $authors = [];
        while ($a = mysqli_fetch_assoc($authorsResult)) $authors[] = $a;

        Response::success(['abstract' => $abstract, 'authors' => $authors]);
    }

    /**
     * GET /api/admin/abstracts
     * List all abstracts (admin/reviewer)
     */
    public function listAll(): void {
        Auth::requireRole('admin', 'reviewer');
        $conn = getDB();

        $result = mysqli_query($conn,
            "SELECT a.abstract_id, a.registration_id, a.paper_title, a.sub_theme,
                    a.type_of_presentation, a.status, a.created_on,
                    r.full_name, r.email,
                    rv.name AS reviewer_name
             FROM `abstract` a
             LEFT JOIN `registration` r ON a.registration_id = r.registration_code
             LEFT JOIN `assign_reviewer` ar ON a.abstract_id = ar.abstract_id
             LEFT JOIN `reviewer` rv ON ar.reviewer_id = rv.reviewer_code
             ORDER BY a.abstract_id DESC"
        );

        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * PUT /api/admin/abstracts/{id}/status
     * Update abstract status (admin)
     * Body: { "status": "2", "comment": "..." }
     */
    public function updateStatus(string $abstractId): void {
        Auth::requireRole('admin', 'reviewer');
        $input = json_decode(file_get_contents('php://input'), true);
        $conn  = getDB();

        $abstractId = mysqli_real_escape_string($conn, $abstractId);
        $status     = mysqli_real_escape_string($conn, $input['status'] ?? '2');
        $comment    = mysqli_real_escape_string($conn, $input['comment'] ?? '');

        mysqli_query($conn, "UPDATE `abstract` SET status = '$status' WHERE abstract_id = '$abstractId'");
        Response::success(null, 'Abstract status updated');
    }
}
