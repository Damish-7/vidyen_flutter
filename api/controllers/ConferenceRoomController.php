<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../middleware/Auth.php';

class ConferenceRoomController {

    /**
     * GET /api/admin/conference-rooms
     * List all rooms (not deleted)
     */
    public function listAll(): void {
        Auth::require();
        $conn = getDB();

        $result = mysqli_query($conn,
            "SELECT id, name, type, links, created_on
             FROM `conference_room` WHERE deleted = 0 ORDER BY id DESC"
        );
        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) $rows[] = $row;
        Response::success($rows);
    }

    /**
     * POST /api/admin/conference-rooms
     * Add a new conference room
     */
    public function create(): void {
        $auth  = Auth::requireRole('admin');
        $input = json_decode(file_get_contents('php://input'), true);
        $conn  = getDB();
        $esc   = fn($v) => mysqli_real_escape_string($conn, $v ?? '');

        if (empty($input['name'])) Response::error('name is required');
        if (empty($input['type'])) Response::error('type is required');

        $createdBy = $auth['user_id'];
        $createdOn = date('d-m-Y');

        mysqli_query($conn,
            "INSERT INTO `conference_room` (name, type, links, created_by, created_on, deleted)
             VALUES ('{$esc($input['name'])}','{$esc($input['type'])}',
                     '{$esc($input['links'])}','$createdBy','$createdOn',0)"
        );

        if (mysqli_affected_rows($conn) === 0) {
            Response::serverError('Failed to add conference room: ' . mysqli_error($conn));
        }

        Response::success(['id' => mysqli_insert_id($conn)], 'Conference room added successfully', 201);
    }

    /**
     * PUT /api/admin/conference-rooms/{id}
     * Edit a conference room
     */
    public function update(string $id): void {
        Auth::requireRole('admin');
        $input = json_decode(file_get_contents('php://input'), true);
        $conn  = getDB();
        $esc   = fn($v) => mysqli_real_escape_string($conn, $v ?? '');
        $id    = mysqli_real_escape_string($conn, $id);

        if (empty($input['name'])) Response::error('name is required');
        if (empty($input['type'])) Response::error('type is required');

        mysqli_query($conn,
            "UPDATE `conference_room`
             SET name='{$esc($input['name'])}', type='{$esc($input['type'])}',
                 links='{$esc($input['links'])}'
             WHERE id='$id' AND deleted=0"
        );

        Response::success(null, 'Conference room updated');
    }

    /**
     * DELETE /api/admin/conference-rooms/{id}
     * Soft-delete a conference room
     */
    public function delete(string $id): void {
        Auth::requireRole('admin');
        $conn = getDB();
        $id   = mysqli_real_escape_string($conn, $id);

        mysqli_query($conn,
            "UPDATE `conference_room` SET deleted=1 WHERE id='$id'"
        );

        Response::success(null, 'Conference room deleted');
    }
}
