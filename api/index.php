<?php
/**
 * VIDYEN Conference API
 * Token-based REST API
 * Base URL: /vidyen/api/
 *
 * Routes:
 *   POST   /auth/login
 *   POST   /auth/change-password
 *   GET    /auth/me
 *
 *   POST   /registration
 *   GET    /registration/me
 *
 *   POST   /abstracts
 *   GET    /abstracts/my
 *   GET    /abstracts/{id}
 *
 *   POST   /preconference
 *   GET    /preconference/my
 *   GET    /preconference/{id}
 *
 *   POST   /workshop
 *   GET    /workshop/my
 *   GET    /workshop/{id}
 *
 *   GET    /certificates/my
 *   GET    /certificates/{type}/{regCode}
 *
 *   GET    /admin/dashboard
 *   GET    /admin/registrations
 *   GET    /admin/registrations/{code}
 *   PUT    /admin/registrations/{code}/activate
 *   GET    /admin/abstracts
 *   PUT    /admin/abstracts/{id}/status
 *   GET    /admin/preconference
 *   PUT    /admin/preconference/{id}/status
 *   GET    /admin/workshop
 *   PUT    /admin/workshop/{id}/status
 *   GET    /admin/certificates
 *   GET    /admin/users
 *   PUT    /admin/users/{id}/toggle-status
 *   GET    /admin/messages
 *   GET    /admin/reviewers
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers/JWTHelper.php';
require_once __DIR__ . '/helpers/Response.php';

// Global exception handler — ensures all unhandled errors return JSON
set_exception_handler(function (\Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status'  => false,
        'message' => 'Server error: ' . $e->getMessage(),
        'data'    => null
    ]);
    exit();
});

// Get request path and method
$requestUri    = $_SERVER['REQUEST_URI'];
$scriptName    = dirname($_SERVER['SCRIPT_NAME']);
$path          = str_replace($scriptName, '', parse_url($requestUri, PHP_URL_PATH));
$path          = '/' . trim($path, '/');
$method        = $_SERVER['REQUEST_METHOD'];

// Split path into segments
$segments = array_values(array_filter(explode('/', $path)));

// Helper: load controller
function loadController(string $name): object {
    $file = __DIR__ . "/controllers/{$name}.php";
    if (!file_exists($file)) Response::notFound("Controller not found");
    require_once $file;
    return new $name();
}

// ─── Routing ─────────────────────────────────────────────────────────────────

$seg0 = $segments[0] ?? '';
$seg1 = $segments[1] ?? '';
$seg2 = $segments[2] ?? '';
$seg3 = $segments[3] ?? '';

// AUTH routes  /auth/...
if ($seg0 === 'auth') {
    $ctrl = loadController('AuthController');
    if ($seg1 === 'login'           && $method === 'POST') { $ctrl->login();          exit(); }
    if ($seg1 === 'change-password' && $method === 'POST') { $ctrl->changePassword(); exit(); }
    if ($seg1 === 'me'              && $method === 'GET')  { $ctrl->me();             exit(); }
    Response::notFound('Auth route not found');
}

// REGISTRATION routes  /registration/...
if ($seg0 === 'registration') {
    $ctrl = loadController('RegistrationController');
    if ($method === 'POST' && !$seg1)        { $ctrl->create();              exit(); }
    if ($method === 'GET'  && $seg1 === 'me') { $ctrl->getMyRegistration();  exit(); }
    Response::notFound('Registration route not found');
}

// ABSTRACTS routes  /abstracts/...
if ($seg0 === 'abstracts') {
    $ctrl = loadController('AbstractController');
    if ($method === 'POST' && !$seg1)          { $ctrl->create();              exit(); }
    if ($method === 'GET'  && $seg1 === 'my')  { $ctrl->myAbstracts();        exit(); }
    if ($method === 'GET'  && $seg1)           { $ctrl->viewOne($seg1);       exit(); }
    Response::notFound('Abstracts route not found');
}

// PRE-CONFERENCE routes  /preconference/...
if ($seg0 === 'preconference') {
    $ctrl = loadController('PreConferenceController');
    if ($method === 'POST' && !$seg1)          { $ctrl->create();             exit(); }
    if ($method === 'GET'  && $seg1 === 'my')  { $ctrl->mySubmissions();     exit(); }
    if ($method === 'GET'  && $seg1)           { $ctrl->viewOne($seg1);      exit(); }
    Response::notFound('Preconference route not found');
}

// WORKSHOP routes  /workshop/...
if ($seg0 === 'workshop') {
    $ctrl = loadController('WorkshopController');
    if ($method === 'POST' && !$seg1)          { $ctrl->create();             exit(); }
    if ($method === 'GET'  && $seg1 === 'my')  { $ctrl->mySubmissions();     exit(); }
    if ($method === 'GET'  && $seg1)           { $ctrl->viewOne($seg1);      exit(); }
    Response::notFound('Workshop route not found');
}

// REVIEWER routes  /reviewer/...
if ($seg0 === 'reviewer') {
    if ($seg1 === 'dashboard' && $method === 'GET') {
        loadController('AdminController')->reviewerDashboard(); exit();
    }
    if ($seg1 === 'abstracts' && $method === 'GET') {
        loadController('AdminController')->reviewerAbstracts(); exit();
    }
    Response::notFound('Reviewer route not found');
}

// CERTIFICATES routes  /certificates/...
if ($seg0 === 'certificates') {
    $ctrl = loadController('CertificateController');
    if ($method === 'GET' && $seg1 === 'my')           { $ctrl->myCertificates();             exit(); }
    if ($method === 'GET' && $seg1 === 'co-authors')   { $ctrl->myCoAuthors();                exit(); }
    if ($method === 'GET' && $seg1 && $seg2)           { $ctrl->downloadInfo($seg1, $seg2);   exit(); }
    Response::notFound('Certificates route not found');
}

// ADMIN routes  /admin/...
if ($seg0 === 'admin') {
    if ($seg1 === 'dashboard') {
        loadController('AdminController')->dashboard(); exit();
    }

    if ($seg1 === 'registrations') {
        $ctrl = loadController('RegistrationController');
        if ($method === 'GET' && !$seg2) { $ctrl->listAll(); exit(); }
        
        // Handle activate endpoint: /admin/registrations/VIDYEN/1000021/activate
        // Registration code contains slash, so we need to check last segment
        $lastSeg = end($segments);
        if ($method === 'PUT' && $lastSeg === 'activate') {
            // Reconstruct registration code from segments between 'registrations' and 'activate'
            $codeSegments = array_slice($segments, 2, -1); // Skip 'admin', 'registrations' and 'activate'
            $regCode = implode('/', $codeSegments);
            $ctrl->activate($regCode);
            exit();
        }
        
        // View single registration by code (not implemented yet)
        if ($method === 'GET' && $seg2) { 
            // Reconstruct full registration code
            $codeSegments = array_slice($segments, 2);
            $regCode = implode('/', $codeSegments);
            $ctrl->viewOne($regCode);
            exit();
        }
        
        Response::notFound('Admin registrations route not found');
    }

    if ($seg1 === 'abstracts') {
        $ctrl = loadController('AbstractController');
        if ($method === 'GET'  && !$seg2)                              { $ctrl->listAll();             exit(); }
        if ($method === 'PUT'  && $seg2 && $seg3 === 'status')         { $ctrl->updateStatus($seg2);   exit(); }
        if ($method === 'POST' && $seg2 && $seg3 === 'assign-reviewer') { $ctrl->assignReviewer($seg2); exit(); }
        Response::notFound('Admin abstracts route not found');
    }

    if ($seg1 === 'preconference') {
        $ctrl = loadController('PreConferenceController');
        if ($method === 'GET'  && !$seg2)                              { $ctrl->listAll();           exit(); }
        if ($method === 'PUT'  && $seg2 && $seg3 === 'status')         { $ctrl->updateStatus($seg2); exit(); }
        if ($method === 'POST' && $seg2 && $seg3 === 'assign-reviewer') { $ctrl->assignReviewer($seg2); exit(); }
        Response::notFound('Admin preconference route not found');
    }

    if ($seg1 === 'workshop') {
        $ctrl = loadController('WorkshopController');
        if ($method === 'GET'  && !$seg2)                              { $ctrl->listAll();             exit(); }
        if ($method === 'PUT'  && $seg2 && $seg3 === 'status')         { $ctrl->updateStatus($seg2);   exit(); }
        if ($method === 'POST' && $seg2 && $seg3 === 'assign-reviewer') { $ctrl->assignReviewer($seg2); exit(); }
        Response::notFound('Admin workshop route not found');
    }

    if ($seg1 === 'certificates') {
        $ctrl = loadController('CertificateController');
        if ($method === 'GET'    && !$seg2)                  { $ctrl->listAll();        exit(); }
        if ($method === 'POST'   && $seg2 === 'generate')    { $ctrl->generate();       exit(); }
        if ($method === 'DELETE' && $seg2)                   { $ctrl->revoke($seg2);    exit(); }
        Response::notFound('Admin certificates route not found');
    }

    if ($seg1 === 'co-authors') {
        $ctrl = loadController('CertificateController');
        if ($method === 'GET') { $ctrl->listCoAuthors(); exit(); }
        Response::notFound('Co-authors route not found');
    }

    if ($seg1 === 'users') {
        $ctrl = loadController('AdminController');
        if ($method === 'GET' && !$seg2)                         { $ctrl->listUsers();            exit(); }
        if ($method === 'PUT' && $seg2 && $seg3 === 'toggle-status') { $ctrl->toggleUserStatus($seg2); exit(); }
        Response::notFound('Admin users route not found');
    }

    if ($seg1 === 'messages') {
        loadController('AdminController')->messages(); exit();
    }

    if ($seg1 === 'reviewers') {
        $ctrl = loadController('AdminController');
        if ($method === 'GET'  && !$seg2)  { $ctrl->listReviewers();     exit(); }
        if ($method === 'GET'  && $seg2)   { $ctrl->viewReviewer($seg2); exit(); }
        if ($method === 'POST' && !$seg2)  { $ctrl->addReviewer();       exit(); }
        Response::notFound('Admin reviewers route not found');
    }

    if ($seg1 === 'conference-rooms') {
        $ctrl = loadController('ConferenceRoomController');
        if ($method === 'GET'    && !$seg2) { $ctrl->listAll();       exit(); }
        if ($method === 'POST'   && !$seg2) { $ctrl->create();        exit(); }
        if ($method === 'PUT'    && $seg2)  { $ctrl->update($seg2);   exit(); }
        if ($method === 'DELETE' && $seg2)  { $ctrl->delete($seg2);   exit(); }
        Response::notFound('Conference rooms route not found');
    }

    Response::notFound('Admin route not found');
}

// Fallback
Response::notFound('VIDYEN API: Route not found. See /vidyen/api/ for docs.');
