<?php
// Path to the directory containing the PDFs
$pdfDirectory = $_SERVER['DOCUMENT_ROOT'] . '/var/www/html/szamlazzhu/pdf/';

// Check if the directory exists
if (is_dir($pdfDirectory)) {
    // Open the directory
    $files = scandir($pdfDirectory);

    // Loop through the files
    foreach ($files as $file) {
        // Check if the file is a PDF
        if (pathinfo($file, PATHINFO_EXTENSION) === 'pdf') {
            $filePath = $pdfDirectory . $file;

            // Attempt to delete the file
            if (unlink($filePath)) {
                error_log("Deleted PDF file: $filePath");
            } else {
                error_log("Failed to delete PDF file: $filePath");
            }
        }
    }
} else {
    error_log("PDF directory does not exist: $pdfDirectory");
}
?>
