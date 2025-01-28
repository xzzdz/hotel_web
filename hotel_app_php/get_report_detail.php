<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "s64143168";
$password = "64143168";
$dbname = "db64143168";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$conn->set_charset("utf8mb4");

$id = $_POST['id'] ?? '';

if (empty($id)) {
    echo json_encode(['status' => 'error', 'message' => 'ID ไม่ครบถ้วน']);
    exit;
}

// $sql = "SELECT id, type, detail, status, assigned_to, date, username FROM report WHERE id = ?";
$sql = "SELECT * FROM report WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    $result = $stmt->get_result();
    if ($result->num_rows > 0) {
        $report = $result->fetch_assoc();
        echo json_encode(['status' => 'success', 'report' => $report], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'ไม่พบข้อมูล']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'ข้อผิดพลาดในการดึงข้อมูล']);
}

$stmt->close();
$conn->close();
?>
