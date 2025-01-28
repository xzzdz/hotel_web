<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// เชื่อมต่อกับฐานข้อมูล
$servername = "localhost";
$username = "s64143168";
$password = "64143168";
$dbname = "db64143168";

$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// กำหนดให้รองรับ UTF-8
$conn->set_charset("utf8mb4");

// ดึงข้อมูลผู้ใช้
$sql = "SELECT id, name, email, role FROM users";
$result = $conn->query($sql);

$users = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
    echo json_encode([
        "status" => "success",
        "data" => $users
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode([
        "status" => "Error",
        "message" => "No users found."
    ], JSON_UNESCAPED_UNICODE);
}

$conn->close();

?>
