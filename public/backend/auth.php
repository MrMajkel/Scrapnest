<?php
session_start();

if (!isset($_SESSION['user'])) {
    header("Location: /logowanie");
    exit;
}

header("Expires: 0");
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");
?>
