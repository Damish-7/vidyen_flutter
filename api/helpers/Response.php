<?php
/**
 * JSON Response Helper
 */
class Response {

    public static function success($data = null, string $message = 'Success', int $code = 200): void {
        http_response_code($code);
        echo json_encode([
            'status'  => true,
            'message' => $message,
            'data'    => $data
        ]);
        exit();
    }

    public static function error(string $message = 'Error', int $code = 400, $data = null): void {
        http_response_code($code);
        echo json_encode([
            'status'  => false,
            'message' => $message,
            'data'    => $data
        ]);
        exit();
    }

    public static function unauthorized(string $message = 'Unauthorized'): void {
        self::error($message, 401);
    }

    public static function notFound(string $message = 'Not Found'): void {
        self::error($message, 404);
    }

    public static function serverError(string $message = 'Internal Server Error'): void {
        self::error($message, 500);
    }
}
