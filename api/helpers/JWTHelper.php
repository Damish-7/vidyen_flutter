<?php
/**
 * JWT Helper - Pure PHP, no external library required
 * Implements HS256 signing
 */
class JWTHelper {

    /**
     * Generate a JWT token
     */
    public static function generate(array $payload): string {
        $header = base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));

        $payload['iat'] = time();
        $payload['exp'] = time() + JWT_EXPIRY;

        $payloadEncoded = base64_encode(json_encode($payload));

        $signature = base64_encode(
            hash_hmac('sha256', "$header.$payloadEncoded", JWT_SECRET, true)
        );

        return "$header.$payloadEncoded.$signature";
    }

    /**
     * Validate and decode a JWT token
     * Returns payload array on success, or throws exception
     */
    public static function validate(string $token): array {
        $parts = explode('.', $token);

        if (count($parts) !== 3) {
            throw new Exception('Invalid token format');
        }

        [$header, $payload, $signature] = $parts;

        $expectedSig = base64_encode(
            hash_hmac('sha256', "$header.$payload", JWT_SECRET, true)
        );

        if (!hash_equals($expectedSig, $signature)) {
            throw new Exception('Invalid token signature');
        }

        $data = json_decode(base64_decode($payload), true);

        if (!$data) {
            throw new Exception('Cannot decode token payload');
        }

        if (isset($data['exp']) && $data['exp'] < time()) {
            throw new Exception('Token has expired');
        }

        return $data;
    }

    /**
     * Extract token from Authorization header
     */
    public static function fromHeader(): ?string {
        $headers = apache_request_headers();
        $auth = $headers['Authorization'] ?? $headers['authorization'] ?? '';

        if (strpos($auth, 'Bearer ') === 0) {
            return substr($auth, 7);
        }

        // Also check for token in GET param (for downloads)
        if (!empty($_GET['token'])) {
            return $_GET['token'];
        }

        return null;
    }
}
