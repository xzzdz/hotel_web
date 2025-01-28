<?php


$targetDir = "uploads/";


if (!is_writable($targetDir)) {
    echo "not writable '$targetDir' ";
    exit;
}


if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['test_file'])) {
    $file = $_FILES['test_file'];
    $fileName = basename($file['name']);
    $targetFile = $targetDir . uniqid() . "_" . $fileName; 


    if ($file['error'] !== UPLOAD_ERR_OK) {
        echo "Error cannot upload: " . $file['error'];
        exit;
    }


    if (move_uploaded_file($file['tmp_name'], $targetFile)) {
        echo "Successfully uploaded: " . $fileName;
    } else {
        echo "Error cannot upload: " . $file['error'];
    }
} else {
    echo "Invalid request";
}

?>


<form action="test_upload.php" method="POST" enctype="multipart/form-data">
    choss file:
    <input type="file" name="test_file">
    <button type="submit">upload</button>
</form>
