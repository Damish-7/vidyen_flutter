<?php
require_once __DIR__ . '/../helpers/JWTHelper.php';
require_once __DIR__ . '/../helpers/Response.php';

class Auth {

    /**
     * Require a valid JWT token. Returns decoded payload.
     */
    public static function require(): array {
        $token = JWTHelper::fromHeader();

        if (!$token) {
            Response::unauthorized('Authorization token is required');
        }

        try {
            $payload = JWTHelper::validate($token);
        } catch (Exception $e) {
            Response::unauthorized($e->getMessage());
        }

        return $payload;
    }

    /**
     * Require a specific user type
     */
    public static function requireRole(string ...$roles): array {
        $payload = self::require();

        if (!in_array($payload['usertype'] ?? '', $roles)) {
            Response::error('Access denied for your role', 403);
        }

        return $payload;
    }
}
