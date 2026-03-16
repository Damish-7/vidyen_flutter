<?php
/**
 * Router script for PHP built-in development server
 * 
 * Usage: php -S localhost:8000 router.php
 * 
 * This file handles routing for the PHP built-in server.
 * - Static files (images, CSS, JS, etc.) are served directly
 * - All other requests are routed through index.php
 */

$uri = $_SERVER['REQUEST_URI'];
$path = parse_url($uri, PHP_URL_PATH);

// Serve real files directly
if ($path !== '/' && file_exists(__DIR__ . $path)) {
    return false;
}

// Route everything else through index.php
$_SERVER['SCRIPT_NAME'] = '/index.php';
require_once __DIR__ . '/index.php';
