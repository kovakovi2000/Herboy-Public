<?php
// get_countries.php

header('Content-Type: application/json');

// Define an array of countries in Hungarian
$countries = [
    ["code" => "AL", "name" => "Albánia"],
    ["code" => "AD", "name" => "Andorra"],
    ["code" => "AT", "name" => "Ausztria"],
    ["code" => "BY", "name" => "Belarusz"],
    ["code" => "BE", "name" => "Belgium"],
    ["code" => "BA", "name" => "Bosznia-Hercegovina"],
    ["code" => "BG", "name" => "Bulgária"],
    ["code" => "CY", "name" => "Ciprus"],
    ["code" => "CZ", "name" => "Csehország"],
    ["code" => "DK", "name" => "Dánia"],
    ["code" => "EE", "name" => "Észtország"],
    ["code" => "FI", "name" => "Finnország"],
    ["code" => "FR", "name" => "Franciaország"],
    ["code" => "GR", "name" => "Görögország"],
    ["code" => "NL", "name" => "Hollandia"],
    ["code" => "HR", "name" => "Horvátország"],
    ["code" => "IE", "name" => "Írország"],
    ["code" => "PL", "name" => "Lengyelország"],
    ["code" => "LV", "name" => "Lettország"],
    ["code" => "LT", "name" => "Litvánia"],
    ["code" => "LI", "name" => "Liechtenstein"],
    ["code" => "LU", "name" => "Luxemburg"],
    ["code" => "MT", "name" => "Málta"],
    ["code" => "MD", "name" => "Moldova"],
    ["code" => "MC", "name" => "Monaco"],
    ["code" => "ME", "name" => "Montenegró"],
    ["code" => "DE", "name" => "Németország"],
    ["code" => "NO", "name" => "Norvégia"],
    ["code" => "IT", "name" => "Olaszország"],
    ["code" => "PT", "name" => "Portugália"],
    ["code" => "RO", "name" => "Románia"],
    ["code" => "RU", "name" => "Oroszország"],
    ["code" => "SM", "name" => "San Marino"],
    ["code" => "ES", "name" => "Spanyolország"],
    ["code" => "SE", "name" => "Svédország"],
    ["code" => "CH", "name" => "Svájc"],
    ["code" => "SK", "name" => "Szlovákia"],
    ["code" => "SI", "name" => "Szlovénia"],
    ["code" => "RS", "name" => "Szerbia"],
    ["code" => "UA", "name" => "Ukrajna"],
    ["code" => "VA", "name" => "Vatikánváros"],
    ["code" => "HU", "name" => "Magyarország"],
    ["code" => "GB", "name" => "Egyesült Királyság"]
];

// Custom comparison function for Hungarian alphabet sorting
function hu_strcmp($a, $b) {
    // Hungarian alphabet ordering
    $hungarian_alphabet = "aábcdeéfghiíjklmnoóöőpqrstuúüűvwxyz";
    
    // Convert names to lowercase to ensure case-insensitive comparison
    $a = mb_strtolower($a['name'], 'UTF-8');
    $b = mb_strtolower($b['name'], 'UTF-8');
    
    // Iterate through each character of the names to compare according to Hungarian alphabet
    $a_len = mb_strlen($a, 'UTF-8');
    $b_len = mb_strlen($b, 'UTF-8');
    
    for ($i = 0; $i < min($a_len, $b_len); $i++) {
        $a_char = mb_substr($a, $i, 1, 'UTF-8');
        $b_char = mb_substr($b, $i, 1, 'UTF-8');
        
        // Find positions in the Hungarian alphabet
        $a_pos = mb_strpos($hungarian_alphabet, $a_char);
        $b_pos = mb_strpos($hungarian_alphabet, $b_char);
        
        // Compare the positions of characters
        if ($a_pos !== $b_pos) {
            return $a_pos - $b_pos;
        }
    }
    
    // If both strings are equal up to the length of the shorter string, compare lengths
    return $a_len - $b_len;
}

// Sort the countries using the custom Hungarian alphabet comparator
usort($countries, 'hu_strcmp');

// Return the countries as a JSON response
echo json_encode($countries);
?>
