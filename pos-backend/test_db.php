<?php
try {
    $db = new PDO('mysql:host=127.0.0.1;port=3306', 'root', '', [PDO::ATTR_TIMEOUT => 2]);
    $stmt = $db->query('SHOW DATABASES');
    print_r($stmt->fetchAll());
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
