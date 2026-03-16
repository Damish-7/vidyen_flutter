<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../helpers/JWTHelper.php';
require_once __DIR__ . '/../helpers/Response.php';

class AuthController {

    /**
     * POST /api/auth/login
     * Body: { "username": "...", "password": "..." }
     */
    public function login(): void {
        $input = json_decode(file_get_contents('php://input'), true);

        $username = trim($input['username'] ?? '');
        $password = trim($input['password'] ?? '');

        if (!$username || !$password) {
            Response::error('Username and password are required');
        }

        $conn = getDB();
        $username = mysqli_real_escape_string($conn, $username);
        $password = mysqli_real_escape_string($conn, $password);

        $query = "SELECT * FROM `login` WHERE `user_email` = '$username' AND `password` = '$password' LIMIT 1";
        $result = mysqli_query($conn, $query);

        if (mysqli_num_rows($result) === 0) {
            Response::error('Invalid credentials', 401);
        }

        $user = mysqli_fetch_assoc($result);

        if ($user['status'] == '0') {
            Response::error('Account approval is still in process', 403);
        }

        // Generate JWT
        $token = JWTHelper::generate([
            'user_id'  => $user['user_id'],
            'email'    => $user['user_email'],
            'usertype' => $user['usertype'],
            'name'     => $user['user_name'] ?? ''
        ]);

        Response::success([
            'token'    => $token,
            'usertype' => $user['usertype'],
            'user_id'  => $user['user_id'],
            'name'     => $user['user_name'] ?? '',
            'email'    => $user['user_email'],
            'expires_in' => JWT_EXPIRY
        ], 'Login successful');
    }

    /**
     * POST /api/auth/change-password
     * Body: { "new_password": "..." }
     * Requires: Bearer token
     */
    public function changePassword(): void {
        require_once __DIR__ . '/../middleware/Auth.php';
        $auth = Auth::require();

        $input = json_decode(file_get_contents('php://input'), true);
        $newPassword = trim($input['new_password'] ?? '');

        if (strlen($newPassword) < 6) {
            Response::error('Password must be at least 6 characters');
        }

        $conn = getDB();
        $userId = mysqli_real_escape_string($conn, $auth['user_id']);
        $newPassword = mysqli_real_escape_string($conn, $newPassword);

        $query = "UPDATE `login` SET `password` = '$newPassword', `status` = '2' WHERE `user_id` = '$userId'";
        $result = mysqli_query($conn, $query);

        if ($result) {
            Response::success(null, 'Password changed successfully');
        } else {
            Response::serverError('Failed to update password');
        }
    }

    /**
     * GET /api/auth/me
     * Returns currently logged in user info
     */
    public function me(): void {
        require_once __DIR__ . '/../middleware/Auth.php';
        $auth = Auth::require();

        $conn = getDB();
        $userId = mysqli_real_escape_string($conn, $auth['user_id']);

        $query = "SELECT user_id, user_email, usertype, user_name, status FROM `login` WHERE user_id = '$userId' LIMIT 1";
        $result = mysqli_query($conn, $query);

        if (mysqli_num_rows($result) === 0) {
            Response::notFound('User not found');
        }

        $user = mysqli_fetch_assoc($result);
        Response::success($user);
    }
}
