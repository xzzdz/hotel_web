<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// เชื่อมต่อกับฐานข้อมูล
$servername = "localhost";
$username = "s64143168"; // หรือชื่อผู้ใช้ที่คุณตั้งไว้
$password = "64143168"; // รหัสผ่าน ถ้าไม่มีให้เว้นว่าง
$dbname = "db64143168";

$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// กำหนดให้รองรับ UTF-8
$conn->set_charset("utf8mb4");

// รับข้อมูลจาก Flutter
$name = $_POST['name'];
$email = $_POST['email'];
$password = $_POST['password'];
$role = $_POST['role'];

// ตรวจสอบว่า email ซ้ำหรือไม่
$check_sql = "SELECT * FROM users WHERE email='$email'";
$check_result = $conn->query($check_sql);

if ($check_result->num_rows > 0) {
    // หาก email ซ้ำ
    echo json_encode([
        "status" => "Error",
        "message" => "Email already exists."
    ], JSON_UNESCAPED_UNICODE);
} else {
    // เพิ่มข้อมูลผู้ใช้ใหม่
    $sql = "INSERT INTO users (name, email, password, role) VALUES ('$name', '$email', '$password', '$role')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode([
            "status" => "success",
            "message" => "User registered successfully."
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            "status" => "Error",
            "message" => "Error: " . $conn->error
        ], JSON_UNESCAPED_UNICODE);
    }
}

$conn->close();
?>
