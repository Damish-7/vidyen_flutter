<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../middleware/Auth.php';

class RegistrationController {

    /**
     * POST /api/registration
     * Public registration - no token needed
     */
    public function create(): void {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            error_log('Registration input: ' . json_encode($input));

            // Validate required fields (Flutter field names)
            $required = ['full_name', 'gender', 'type_of_delegate', 'email', 'password'];
            foreach ($required as $field) {
                if (empty($input[$field])) {
                    Response::error("Field '$field' is required");
                }
            }

            $conn = getDB();

            // Check for duplicate email
            $email = mysqli_real_escape_string($conn, $input['email']);
            $check = mysqli_query($conn, "SELECT id FROM registration WHERE email = '$email' LIMIT 1");
            if (mysqli_num_rows($check) > 0) {
                Response::error('This email is already registered');
            }

            // Generate registration code (VIDYEN/XXXXXXX pattern)
            $codeResult = mysqli_query($conn, "SELECT registration_code FROM registration ORDER BY id DESC LIMIT 1");
            if (mysqli_num_rows($codeResult) === 0) {
                $regCode = 'VIDYEN/1000004';
            } else {
                $lastRow = mysqli_fetch_assoc($codeResult);
                $lastCode = $lastRow['registration_code'];
                // Extract numeric suffix and increment
                $parts   = explode('/', $lastCode);
                $num     = isset($parts[1]) ? (int)$parts[1] + 1 : 1000004;
                $regCode = 'VIDYEN/' . $num;
            }

            $esc = fn($v) => mysqli_real_escape_string($conn, $v);

            // Map Flutter field names to actual DB column names
            $query = "INSERT INTO `registration`
                        (`registration_code`,`honorofic`,`full_name`,`age`,`gender`,
                         `type_of_delegate`,`designation`,`college_name`,`university_name`,
                         `full_address`,`city`,`state`,`country`,`pincode`,`email`,`phone_number`,
                         `pre_conference`,`type_preconference`,`scientific_presentation`,`status`,`flag`)
                      VALUES
                        ('{$esc($regCode)}',
                         '{$esc($input['title'] ?? '')}',
                         '{$esc($input['full_name'])}',
                         '{$esc($input['age'] ?? '')}',
                         '{$esc($input['gender'])}',
                         '{$esc($input['type_of_delegate'])}',
                         '{$esc($input['designation'] ?? '')}',
                         '{$esc($input['institution'] ?? '')}',
                         '{$esc($input['department'] ?? '')}',
                         '{$esc($input['address'] ?? '')}',
                         '{$esc($input['city'] ?? '')}',
                         '{$esc($input['state'] ?? '')}',
                         '{$esc($input['country'] ?? '')}',
                         '{$esc($input['pincode'] ?? '')}',
                         '{$esc($email)}',
                         '{$esc($input['phone'] ?? '')}',
                         '{$esc($input['preconference'] ?? '0')}',
                         '{$esc($input['type_preconference'] ?? '')}',
                         '{$esc($input['abstract_submission'] ?? '0')}',
                         '0',
                         '0')";

            error_log('Registration query: ' . $query);
            if (!mysqli_query($conn, $query)) {
                error_log('Registration insert failed: ' . mysqli_error($conn));
                Response::serverError('Registration failed: ' . mysqli_error($conn));
            }

            // Create login entry
            $password = $esc($input['password']);
            $name     = $esc($input['full_name']);
            
            // Generate user_id from registration code
            $userId = $regCode;
            
            $loginQ   = "INSERT INTO `login` (`user_id`,`user_email`,`password`,`usertype`,`user_name`,`status`,`flag`)
                         VALUES ('$userId','$email','$password','participant','$name','0','0')";
            
            if (!mysqli_query($conn, $loginQ)) {
                // Rollback registration if login creation fails (optional)
                Response::serverError('Login account creation failed: ' . mysqli_error($conn));
            }

            Response::success(['registration_code' => $regCode], 'Registration submitted successfully. Await approval.', 201);
        
        } catch (mysqli_sql_exception $e) {
            error_log('MySQL Error: ' . $e->getMessage() . ' | Code: ' . $e->getCode());
            Response::serverError('Database error: ' . $e->getMessage() . ' (Code: ' . $e->getCode() . ')');
        } catch (Exception $e) {
            error_log('Exception: ' . $e->getMessage() . ' | ' . $e->getTraceAsString());
            Response::serverError('Registration error: ' . $e->getMessage() . ' | File: ' . $e->getFile() . ' | Line: ' . $e->getLine());
        }
    }

    /**
     * GET /api/registration/me
     * Get own registration (participant)
     */
    public function getMyRegistration(): void {
        $auth = Auth::require();
        $conn = getDB();

        $userId = mysqli_real_escape_string($conn, $auth['user_id']);

        // Get user_id's email first, then find registration
        $emailQ = mysqli_query($conn, "SELECT user_email FROM `login` WHERE user_id = '$userId' LIMIT 1");
        $loginRow = mysqli_fetch_assoc($emailQ);
        if (!$loginRow) Response::notFound('User not found');

        $email = mysqli_real_escape_string($conn, $loginRow['user_email']);
        $query = "SELECT * FROM `registration` WHERE `email` = '$email' LIMIT 1";
        $result = mysqli_query($conn, $query);

        if (mysqli_num_rows($result) === 0) {
            Response::notFound('Registration not found');
        }

        Response::success(mysqli_fetch_assoc($result));
    }

    /**
     * GET /api/admin/registrations
     * List all registrations (admin only)
     */
    public function listAll(): void {
        Auth::requireRole('admin');
        $conn = getDB();

        $query = "SELECT id, registration_code, honorofic as title, full_name, type_of_delegate, 
                         designation, college_name as institution, university_name, full_address,
                         email, phone_number, city, state, country, pincode, age, gender, status 
                  FROM `registration` ORDER BY id DESC";
        $result = mysqli_query($conn, $query);

        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * GET /api/admin/registrations/{code}
     * View single registration (admin)
     */
    public function viewOne(string $regCode): void {
        Auth::requireRole('admin');
        $conn = getDB();
        $regCode = mysqli_real_escape_string($conn, $regCode);

        $query  = "SELECT * FROM `registration` WHERE `registration_code` = '$regCode' LIMIT 1";
        $result = mysqli_query($conn, $query);

        if (mysqli_num_rows($result) === 0) Response::notFound('Registration not found');
        Response::success(mysqli_fetch_assoc($result));
    }

    /**
     * PUT /api/admin/registrations/{code}/activate
     * Activate a participant (admin)
     */
    public function activate(string $regCode): void {
        Auth::requireRole('admin');
        $conn   = getDB();
        $regCode = mysqli_real_escape_string($conn, $regCode);

        error_log("Activating registration: $regCode");
        
        // Update registration status
        $result1 = mysqli_query($conn, "UPDATE `registration` SET status = '1' WHERE registration_code = '$regCode'");
        if (!$result1) {
            error_log("Failed to update registration: " . mysqli_error($conn));
            Response::serverError('Failed to update registration status');
        }
        
        $affected = mysqli_affected_rows($conn);
        error_log("Registration update affected rows: $affected");

        // Also activate login
        $emailQ = mysqli_query($conn, "SELECT email FROM registration WHERE registration_code = '$regCode' LIMIT 1");
        if ($row = mysqli_fetch_assoc($emailQ)) {
            $email = mysqli_real_escape_string($conn, $row['email']);
            $result2 = mysqli_query($conn, "UPDATE `login` SET status = '1' WHERE user_email = '$email'");
            if (!$result2) {
                error_log("Failed to update login: " . mysqli_error($conn));
            }
            $affected2 = mysqli_affected_rows($conn);
            error_log("Login update affected rows: $affected2");
        }

        Response::success(['affected_rows' => $affected], 'Participant activated');
    }
}
