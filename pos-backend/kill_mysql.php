<?php
try {
    $db = new PDO('mysql:host=127.0.0.1;port=3306', 'root', '');
    $stmt = $db->query("SHOW PROCESSLIST");
    $myId = $db->query('SELECT CONNECTION_ID()')->fetchColumn();
    foreach ($stmt->fetchAll() as $row) {
        if ($row['Id'] != $myId) {
            $db->exec("KILL " . $row['Id']);
            echo "Killed " . $row['Id'] . "\n";
        }
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
