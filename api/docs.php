<?php
header('Content-Type: application/json');
echo json_encode([
    'name'        => 'VIDYEN Conference REST API',
    'version'     => '1.0.0',
    'description' => 'Token-based JSON API for VIDYEN Conference Management',
    'base_url'    => 'http://localhost/vidyen_flutter/api',
    'auth'        => 'Bearer JWT (POST /auth/login to obtain token)',
    'endpoints'   => [
        'auth'        => [
            'POST /auth/login'           => 'Login - returns JWT token',
            'POST /auth/change-password' => 'Change password (authenticated)',
            'GET  /auth/me'              => 'Get current user (authenticated)',
        ],
        'registration'=> [
            'POST /registration'         => 'Create registration (public)',
            'GET  /registration/me'      => 'Get my registration (authenticated)',
        ],
        'abstracts'   => [
            'POST /abstracts'            => 'Submit abstract',
            'GET  /abstracts/my'         => 'My abstracts',
            'GET  /abstracts/{id}'       => 'View abstract + authors',
        ],
        'preconference'=> [
            'POST /preconference'        => 'Submit pre-conference',
            'GET  /preconference/my'     => 'My pre-conference submissions',
            'GET  /preconference/{id}'   => 'View one',
        ],
        'workshop'    => [
            'POST /workshop'             => 'Submit workshop',
            'GET  /workshop/my'          => 'My workshops',
            'GET  /workshop/{id}'        => 'View one',
        ],
        'certificates'=> [
            'GET  /certificates/my'              => 'My certificates',
            'GET  /certificates/{type}/{regCode}'=> 'Certificate download URL',
        ],
        'admin'       => [
            'GET  /admin/dashboard'                    => 'Stats',
            'GET  /admin/registrations'                => 'All registrations',
            'GET  /admin/registrations/{code}'         => 'View one',
            'PUT  /admin/registrations/{code}/activate'=> 'Activate participant',
            'GET  /admin/abstracts'                    => 'All abstracts',
            'PUT  /admin/abstracts/{id}/status'        => 'Update status',
            'GET  /admin/preconference'                => 'All pre-conference',
            'PUT  /admin/preconference/{id}/status'    => 'Update status',
            'GET  /admin/workshop'                     => 'All workshops',
            'PUT  /admin/workshop/{id}/status'         => 'Update status',
            'GET  /admin/certificates'                 => 'All certificates',
            'GET  /admin/users'                        => 'All users',
            'PUT  /admin/users/{id}/toggle-status'     => 'Toggle user active status',
            'GET  /admin/messages'                     => 'Contact messages',
            'GET  /admin/reviewers'                    => 'All reviewers',
        ],
    ],
    'example_login' => [
        'request' => [
            'method' => 'POST',
            'url'    => 'http://localhost/vidyen/api/auth/login',
            'body'   => ['username' => 'email@example.com', 'password' => 'yourpassword'],
        ],
        'response' => [
            'status'  => true,
            'message' => 'Login successful',
            'data'    => [
                'token'     => 'eyJhbGci...',
                'usertype'  => 'admin|participant|reviewer',
                'user_id'   => '1',
                'expires_in'=> 86400,
            ],
        ],
    ],
], JSON_PRETTY_PRINT);
