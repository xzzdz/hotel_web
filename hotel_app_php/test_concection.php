<?php
$servername = "localhost";
$username = "s64143168"; // หรือชื่อผู้ใช้ที่คุณตั้งไว้
$password = "64143168"; // รหัสผ่าน ถ้าไม่มีให้เว้นว่าง
$dbname = "db64143168";

// สร้างการเชื่อมต่อ
$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";

// ปิดการเชื่อมต่อ
$conn->close();
?>
