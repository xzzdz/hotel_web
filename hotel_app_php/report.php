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

// ตั้งค่าการเข้ารหัสเป็น utf8mb4 เพื่อรองรับภาษาไทย
$conn->set_charset("utf8mb4");


// รับข้อมูลการแจ้งซ่อมทั้งหมด
$sql = "SELECT * FROM report  ORDER BY date DESC";
$result = $conn->query($sql);

$reports = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

// ตั้งค่า Header ให้เป็น JSON UTF-8
header('Content-Type: application/json; charset=UTF-8');

// ส่งข้อมูล JSON โดยใช้ JSON_UNESCAPED_UNICODE เพื่อรองรับภาษาไทย
echo json_encode($reports, JSON_UNESCAPED_UNICODE);

$conn->close();




?>
