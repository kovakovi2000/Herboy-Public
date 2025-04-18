<?php
if(!ErrorManager::isDevelpor()) {
    include_once($_SERVER['DOCUMENT_ROOT'] . "/dev.php");
    exit();
}
ErrorManager::$force_no_display = true;
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/Config.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/_socket.php");
require_once($_SERVER['DOCUMENT_ROOT'] . '/szamlazzhu/szamlaagent/autoload.php');

ini_set('error_log', $_SERVER['DOCUMENT_ROOT'] . '/szamlazzhu/logs_e/payments.log');

use SzamlaAgent\SzamlaAgentAPI;
use SzamlaAgent\Invoice;
use SzamlaAgent\Header;
use SzamlaAgent\Seller;
use SzamlaAgent\Buyer;
use SzamlaAgent\Log;
use SzamlaAgent\Document;
use SzamlaAgent\InvoiceItem;
use SzamlaAgent\Item;

global $sql;
header('Content-Type: application/json');

error_log("Received input: " . print_r(file_get_contents('php://input'), true));

$input = json_decode(file_get_contents('php://input'), true);

if (isset($input['userId'], $input['points'], $input['price'], $input['buyerName'], $input['address'], $input['city'], $input['postal_code'], $input['country'], $input['transactionId'], $input['exchangeRate'])) {
    
    error_log("Parsed input: " . print_r($input, true));

    $lastLoginName = html_entity_decode(isset($input['lastLoginName']) ? $input['lastLoginName'] : 'Unknown', ENT_QUOTES, 'UTF-8');
    $userId = $input['userId'];
    $points = $input['points'];
    $price = $input['price'];
    $buyerName = $input['buyerName'];
    $address = $input['address'];
    $city = $input['city'];
    $postal_code = $input['postal_code'];
    $country = $input['country'];
    $transactionId = $input['transactionId'] ?? 'UNKNOWN';
    $exchangeRate = $input['exchangeRate'];
    
    $account_id = $userId;
    error_log("account_id: $account_id");
    
    $name = $lastLoginName;
    $amount_pp = $points;
    $IsGift = 0;
    $paymethodid = 5;
    $comment = $userId;
    $active = 0;

$currentMonth = date('n');

if ($currentMonth == 11) {
    $bonusPoints = intval($points * 0.2);
    $totalPoints = $points + $bonusPoints;
    $pointsDescription = "$points PrémiumPont + $bonusPoints PrémiumPont (20% Bónusz)";
} elseif ($currentMonth == 12) {
    $bonusPoints = intval($points * 0.33);
    $totalPoints = $points + $bonusPoints;
    $pointsDescription = "$points PrémiumPont + $bonusPoints PrémiumPont (33% Bónusz)";
} else {
    $bonusPoints = 0;
    $totalPoints = $points;
    $pointsDescription = "$points PrémiumPont";
}
    function verifyPaypalTransaction($transactionId) {
        $clientId = 'AZNFTrpKE63EyYz9HbPvb0rObBWSJF-iXIIogAgKcMkS-cp1ZaSder2KdERANj2whPSyWYi9ljtIGQT7';
        $clientSecret = 'EM-cnaJEnzsY0F7RqSiwBI0B_OUyMkDGKOgFbPiWmyxauFKETLDcUBKHl7lDy4hqo4gvQV0Gyg1nmmAm';
    
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "https://api-m.paypal.com/v1/oauth2/token");
        curl_setopt($ch, CURLOPT_HTTPHEADER, ["Accept: application/json", "Accept-Language: en_US"]);
        curl_setopt($ch, CURLOPT_USERPWD, "$clientId:$clientSecret");
        curl_setopt($ch, CURLOPT_POSTFIELDS, "grant_type=client_credentials");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        curl_close($ch);
    
        $accessToken = json_decode($response)->access_token;
    
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "https://api-m.paypal.com/v2/checkout/orders/$transactionId");
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Content-Type: application/json",
            "Authorization: Bearer $accessToken"
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $orderDetails = json_decode(curl_exec($ch));
        curl_close($ch);
    
        if ($orderDetails && $orderDetails->status === "COMPLETED") {
            return true;
        } else {
            error_log("Invalid transaction ID or transaction not completed.");
            return false;
        }
    }
    
    $transactionId = $input['transactionId'];
    if (!verifyPaypalTransaction($transactionId)) {
        // Log the failed transaction to PurchaseLog2
        error_log("Transaction verification failed. Logging to PurchaseLog2.");
    
        $stmtInsertOrder2 = $sql->prepare("INSERT INTO " . Config::$t_PurchaseLog2_name . " (paymethodid, amount, comment, Active, smsid, smssendernum) VALUES (?, ?, ?, ?, NULL, NULL)");
        $comment = "$userId";
        $amount = $totalPoints;
        $active = 0;
        $paymethodid = 10;
        $stmtInsertOrder2->bind_param("iisi", $paymethodid, $amount, $comment, $active);
    
        if ($stmtInsertOrder2->execute()) {
            error_log("Failed transaction logged successfully in PurchaseLog2.");
        } else {
            error_log("Failed to log failed transaction in PurchaseLog2.");
        }
    
        echo json_encode(["status" => "error", "message" => "Transaction verification failed."]);
        exit;
    }

    error_log("Starting SQL INSERT for PurchaseLog (buyerName: $buyerName, userId: $userId, points: $totalPoints, price: $price)");

 
    $stmtInsertOrder = $sql->prepare("INSERT INTO " . Config::$t_PurchaseLog_name . " (buyerName, userId, points, price) VALUES (?, ?, ?, ?)");
    $stmtInsertOrder->bind_param("sidi", $buyerName, $userId, $totalPoints, $price);

    if ($stmtInsertOrder->execute()) {
        error_log("PurchaseLog entry inserted successfully.");

        error_log("Starting SQL INSERT for PurchaseLog2 (paymethodid: $paymethodid, amount: $totalPoints, comment: $comment, Active: $active)");

        $stmtInsertOrder2 = $sql->prepare("INSERT INTO " . Config::$t_PurchaseLog2_name . " (paymethodid, amount, comment, Active, smsid, smssendernum) VALUES (?, ?, ?, ?, NULL, NULL)");
        $stmtInsertOrder2->bind_param("iisi", $paymethodid, $totalPoints, $comment, $active);

        if ($stmtInsertOrder2->execute()) {
            error_log("PurchaseLog2 entry inserted successfully.");

            error_log("Starting SQL UPDATE for PremiumPoint (points: $totalPoints, userId: $userId)");

            $stmt = $sql->prepare("UPDATE " . Config::$t_regsystem_name . " SET PremiumPoint = PremiumPoint + ? WHERE id = ?");
            $stmt->bind_param("ii", $totalPoints, $userId);
            
            if ($stmt->execute()) {
                error_log("Premium points updated successfully.");

            error_log("Calling ex_bought_pp with: account_id=$account_id, name=$lastLoginName, amount_pp=$totalPoints, IsGift=$IsGift");

            $passargs = array("i", $account_id, "s", $lastLoginName, "i", $totalPoints, "i", $IsGift);
            $ret = sck_CallPawnFunc("regbackup.amxx", "ex_bought_pp", $passargs);

            error_log("Socket call response: " . print_r($ret, true));

            try {
                $apiKey = 'r54iqyxifnanbz4iqyxik3sj9k4iqyxif9r4uf4iqy';
                $agent = SzamlaAgentAPI::create($apiKey, true);

                error_log("Generating invoice for transactionId: $transactionId");

                $invoice = new \SzamlaAgent\Document\Invoice\Invoice(\SzamlaAgent\Document\Invoice\Invoice::INVOICE_TYPE_E_INVOICE);
                $header = $invoice->getHeader();
                $header->setOrderNumber($transactionId);
                $header->setExchangeRate($exchangeRate);
                $header->setPrefix('HRBOY');
                $invoice->setHeader($header);
                $invoice->setSeller(new \SzamlaAgent\Seller('OTP Bank Nyrt.', '11773470-00904887'));

                $buyer = new \SzamlaAgent\Buyer($buyerName, $postal_code, $city, $address, $country);
                $invoice->setBuyer($buyer);

                $quantity = 1;
                $item = new \SzamlaAgent\Item\InvoiceItem($pointsDescription, $price);
                $item->setQuantity($quantity);
                $item->setNetUnitPrice($price);
                $item->setNetPrice($price * $quantity);
                $item->setGrossAmount($price * $quantity);
                $item->setVat('AAM');
                $item->setVatAmount(0);
                $item->setComment("Játékos neve: $lastLoginName , Játékos ID: $userId");

                $invoice->addItem($item);

                $result = $agent->generateInvoice($invoice);

                if ($result) {
                    error_log("Invoice generated successfully. Document number: " . $result->getDocumentNumber());

                    $pdfContent = $agent->getInvoicePdf($result->getDocumentNumber());

                    if ($pdfContent) {
                        $pdfFilePath = $_SERVER['DOCUMENT_ROOT'] . '/szamlazzhu/pdf/' . $result->getDocumentNumber() . '.pdf';
                        file_put_contents($pdfFilePath, $pdfContent);

                        error_log("Invoice PDF saved successfully: $pdfFilePath");

                        echo json_encode([
                            "status" => "success",
                            "message" => "Premium points updated and invoice generated successfully.",
                            "invoiceId" => $result->getDocumentNumber(),
                            "pdfUrl" => './szamlazzhu/pdf/' . $result->getDocumentNumber() . '.pdf'
                        ]);
                    } else {
                        error_log("Failed to retrieve invoice PDF.");
                        echo json_encode(["status" => "error", "message" => "Failed to retrieve invoice PDF."]);
                    }
                } else {
                    error_log("Failed to create invoice.");
                    echo json_encode(["status" => "error", "message" => "Failed to create invoice."]);
                }
            } catch (Exception $e) {
                error_log("Invoice generation failed: " . $e->getMessage());
                echo json_encode(["status" => "error", "message" => "Invoice generation failed: " . $e->getMessage()]);
            }
        } else {
            error_log("Failed to update premium points for userId: $userId");
            echo json_encode(["status" => "error", "message" => "Failed to update premium points."]);
        }
    } else {
        error_log("Failed to insert PurchaseLog entry.");
        echo json_encode(["status" => "error", "message" => "Failed to insert order details."]);
    }

    $stmt->close();
} else {
    error_log("Invalid input received: " . print_r($input, true));
    echo json_encode(["status" => "error", "message" => "Invalid input."]);
}
}
?>
