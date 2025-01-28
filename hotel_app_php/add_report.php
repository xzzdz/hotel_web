
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
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

// ตั้งค่าการเข้ารหัส
$conn->set_charset("utf8mb4");

// รับข้อมูลจาก POST (JSON)
$data = json_decode(file_get_contents("php://input"), true);

// ตรวจสอบว่าข้อมูลครบถ้วนหรือไม่
$username = $_POST['username'] ?? null;
$date = $_POST['date'] ?? null;
$type = $_POST['type'] ?? null;
$status = $_POST['status'] ?? null;
$detail = $_POST['detail'] ?? null;
$location = $_POST['location'] ?? null;


if ($username && $date && $type && $status && $detail && $location) {
    // เตรียมคำสั่ง SQL
    $sql = "INSERT INTO report (username, date, type, status, detail, location) VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);

    if ($stmt) {
        // ผูกพารามิเตอร์
        $stmt->bind_param("ssssss", $username, $date, $type, $status, $detail, $location);

        // รันคำสั่ง SQL
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Data inserted successfully."]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to insert data."]);
        }

        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Failed to prepare statement: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid input."]);
}


// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
?>
