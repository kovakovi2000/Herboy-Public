<?php
require_once 'PHPMailer/PHPMailer.php';
require_once 'PHPMailer/Exception.php';
require_once 'PHPMailer/SMTP.php';

$err = array();

global $mail;$mail = new PHPMailer\PHPMailer\PHPMailer();

$mail->isSMTP();  // the mailer is set to use SMTP
$mail->Host = "smtppro.zoho.eu";  // specify main and backup server
$mail->SMTPAuth = true; // SMTP authentication is turned on
$mail->Username = "exilleherboy@gmail.com";  // SMTP username
$mail->Password = "Herboy2583!"; // SMTP password
$mail->SMTPSecure = 'ssl';
$mail->Port = 465;

$mail->From = "noreply@herboyd2.hu";
$mail->FromName = "HerBoyD2";	 // name is optional
//$mail->AddAddress('mihalyne2@gmail.com');
//$mail->AddReplyTo("mihalyne2@gmail.com", "HerBoySystem");

$mail->WordWrap = 50;  // set word wrap to 50 characters
$mail->IsHTML(true); // set email format to HTML
$mail->CharSet = 'UTF-8';
$mail->Subject = "HerboyD2 - Elfelejtettem a jelszavam!";
$mail->AltBody = "";

function Mail_ForgetPassword($dst_email, $lastloginname, $username, $pwcng_token)
{
   global $mail;
   $mail->AddAddress($dst_email);
   $mail->Body    = '<!DOCTYPE html><html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" lang="en"><head><title></title><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><!--[if mso]><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch><o:AllowPNG/></o:OfficeDocumentSettings></xml><![endif]--><style>
*{box-sizing:border-box}body{margin:0;padding:0}a[x-apple-data-detectors]{color:inherit!important;text-decoration:inherit!important}#MessageViewBody a{color:inherit;text-decoration:none}p{line-height:inherit}.desktop_hide,.desktop_hide table{mso-hide:all;display:none;max-height:0;overflow:hidden}.image_block img+div{display:none} @media (max-width:720px){.social_block.desktop_hide .social-table{display:inline-block!important}.mobile_hide{display:none}.row-content{width:100%!important}.stack .column{width:100%;display:block}.mobile_hide{min-height:0;max-height:0;max-width:0;overflow:hidden;font-size:0}.desktop_hide,.desktop_hide table{display:table!important;max-height:none!important}.row-1 .column-2 .block-1.image_block td.pad{padding:0 60px!important}.row-1 .column-1 .block-1.image_block td.pad{padding:35px 0 0!important}}
</style></head><body style="background-color:#fff;margin:0;padding:0;-webkit-text-size-adjust:none;text-size-adjust:none"><table class="nl-container" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;background-color:#fff"><tbody><tr><td><table class="row row-1" align="center" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;background-color:#000"><tbody>
<tr><td><table class="row-content stack" align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;border-radius:0;color:#000;width:700px;margin:0 auto" width="700"><tbody><tr><td class="column column-1" width="25%" style="mso-table-lspace:0;mso-table-rspace:0;font-weight:400;text-align:left;padding-bottom:5px;padding-top:5px;vertical-align:top;border-top:0;border-right:0;border-bottom:0;border-left:0"><table 
class="image_block block-1" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0"><tr><td class="pad" style="width:100%;padding-right:0;padding-left:0"><div class="alignment" align="center" style="line-height:10px"><img src="https://herboyd2.hu/1/images/headline_logo.png" 
style="display:block;height:auto;border:0;max-width:113.75px;width:100%" width="113.75"></div></td></tr></table></td><td class="column column-2" width="75%" style="mso-table-lspace:0;mso-table-rspace:0;font-weight:400;text-align:left;padding-bottom:5px;padding-top:5px;vertical-align:top;border-top:0;border-right:0;border-bottom:0;border-left:0"><table class="image_block block-1" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" 
style="mso-table-lspace:0;mso-table-rspace:0"><tr><td class="pad" style="padding-left:60px;padding-right:60px;padding-top:25px;width:100%"><div class="alignment" align="center" style="line-height:10px"><a href="https://herboyd2.hu" target="_blank" style="outline:none" tabindex="-1"><img 
src="https://herboyd2.hu/1/images/hb_pre.png" style="display:block;height:auto;border:0;max-width:405px;width:100%" width="405" alt="Herboy Onlyd2" title="Herboy Onlyd2"></a></div></td></tr></table></td></tr></tbody></table></td></tr></tbody></table><table class="row row-2" align="center" width="100%" border="0" cellpadding="0" cellspacing="0" 
role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;background-image:url(https://herboyd2.hu/1/images/hero-bg.jpg); background-position:top center;background-repeat:no-repeat"><tbody><tr><td><table class="row-content stack" align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" 
style="mso-table-lspace:0;mso-table-rspace:0;color:#000;width:700px;margin:0 auto" width="700"><tbody><tr><td class="column column-1" width="100%" style="mso-table-lspace:0;mso-table-rspace:0;font-weight:400;text-align:left;padding-top:40px;vertical-align:top;border-top:0;border-right:0;border-bottom:0;border-left:0"><table class="text_block block-1" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;word-break:break-word">
<tr><td class="pad" style="padding-bottom:10px;padding-left:10px;padding-right:10px;padding-top:30px"><div style="font-family:sans-serif"><div class style="font-size:12px;font-family:Arial,Helvetica Neue,Helvetica,sans-serif;mso-line-height-alt:14.399999999999999px;color:#fff;line-height:1.2"><p style="margin:0;font-size:14px;text-align:center;mso-line-height-alt:16.8px">
<span style="font-size:30px;"><strong>Elfelejtetted a jelszavad <br/><span style="color:#cc147f;">'.
$lastloginname
.'</span>?</strong></span></p></div></div></td></tr></table><table class="text_block block-2" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;word-break:break-word"><tr><td class="pad" style="padding-bottom:10px;padding-left:20px;padding-right:20px;padding-top:10px"><div style="font-family:sans-serif"><div class 
style="font-size:12px;font-family:Arial,Helvetica Neue,Helvetica,sans-serif;mso-line-height-alt:18px;color:#fff;line-height:1.5"><p style="margin:0;font-size:14px;text-align:center;mso-line-height-alt:24px">
<span style><span style="font-size:16px;">Ez az emailt azért kaptad mert a weboldalunkon <em>(herboyd2.hu)</em> jelezted felénk, hogy elfelejtetted a jelszavad a <span style="color:#cc147f;">'.
$username
.'</span> felhasználónévhez. Kérlek </span></span><span style="font-size:16px;">kattints</span><span style><span style="font-size:16px;"> a "<strong>Jelszó megváltoztatása"</strong> gombra amennyiben szeretnél új jelszót beállítani.</span></span></p></div></div></td></tr></table><table 
class="button_block block-3" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0"><tr><td class="pad" style="padding-bottom:50px;padding-left:10px;padding-right:10px;padding-top:30px;text-align:center"><div class="alignment" align="center">
<!--[if mso]><v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="https://herboyd2.hu/forgetpassword.php" style="height:48px;width:257px;v-text-anchor:middle;" arcsize="63%" stroke="false" fillcolor="#cc147f"><w:anchorlock/><v:textbox inset="0px,0px,0px,0px"><center style="color:#ffffff; font-family:Arial, sans-serif; font-size:16px"><![endif]-->
<a href="
https://herboyd2.hu/1/forgetpassword.php?t='. $pwcng_token .'
" target="_blank" style="text-decoration:none;display:inline-block;color:#ffffff;background-color:#cc147f;border-radius:30px;width:auto;border-top:0px solid transparent;font-weight:undefined;border-right:0px solid transparent;border-bottom:0px solid transparent;border-left:0px solid transparent;padding-top:8px;padding-bottom:8px;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;font-size:16px;text-align:center;mso-border-alt:none;word-break:keep-all;"><span style="padding-left:40px;padding-right:40px;font-size:16px;display:inline-block;letter-spacing:normal;"><span style="word-break: break-word; line-height: 32px;"><strong>Jelszó megváltoztatása</strong></span></span></a>
<!--[if mso]></center></v:textbox></v:roundrect><![endif]--></div></td></tr></table></td></tr></tbody></table></td></tr></tbody></table><table class="row row-3" align="center" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;background-color:#424242"><tbody><tr><td><table class="row-content stack" align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" 
style="mso-table-lspace:0;mso-table-rspace:0;color:#000;width:700px;margin:0 auto" width="700"><tbody><tr><td class="column column-1" width="100%" style="mso-table-lspace:0;mso-table-rspace:0;font-weight:400;text-align:left;padding-top:40px;vertical-align:top;border-top:0;border-right:0;border-bottom:0;border-left:0"><table class="text_block block-1" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;word-break:break-word">
<tr><td class="pad" style="padding-bottom:10px;padding-left:30px;padding-right:30px;padding-top:10px"><div style="font-family:sans-serif"><div class style="font-size:12px;font-family:Arial,Helvetica Neue,Helvetica,sans-serif;mso-line-height-alt:18px;color:#828282;line-height:1.5"><p style="margin:0;font-size:14px;text-align:center;mso-line-height-alt:21px">
<em>Amennyiben nem te kérted a jelszóváltoztatás kérlek jelezd a részünkre a <span style="color:#799dff;"><a href="https://www.facebook.com/groups/herboyonlyd2" target="_blank" style="text-decoration:underline;color:#799dff;" rel="noopener">facebook csoporton</a></span> keresztül.</em></p></div></div></td></tr></table></td></tr></tbody></table></td></tr></tbody></table><table class="row row-4" align="center" width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation" 
style="mso-table-lspace:0;mso-table-rspace:0;background-color:#424242"><tbody><tr><td><table class="row-content stack" align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;color:#000;width:700px;margin:0 auto" width="700"><tbody><tr><td class="column column-1" width="100%" 
style="mso-table-lspace:0;mso-table-rspace:0;font-weight:400;text-align:left;padding-bottom:25px;padding-top:25px;vertical-align:top;border-top:0;border-right:0;border-bottom:0;border-left:0"><table class="social_block block-1" width="100%" border="0" cellpadding="10" cellspacing="0" role="presentation" style="mso-table-lspace:0;mso-table-rspace:0"><tr><td class="pad"><div class="alignment" align="center"><table class="social-table" width="52px" border="0" cellpadding="0" cellspacing="0" 
role="presentation" style="mso-table-lspace:0;mso-table-rspace:0;display:inline-block"><tr><td style="padding:0 10px 0 10px"><a href="https://www.facebook.com/groups/herboyonlyd2" target="_blank"><img src="https://app-rsrc.getbee.io/public/resources/social-networks-icon-sets/circle-color/facebook@2x.png" width="32" height="32" alt="Facebook" title="Facebook" style="display:block;height:auto;border:0"></a></td></tr></table></div></td></tr></table></td></tr></tbody></table></td></tr>
</tbody></table></td></tr></tbody></table><!-- End --></body></html>';

if(!$mail->Send())
   file_put_contents(
      "/var/www/html/herboyd2.hu/public/_MAILLOG/MAIL_".date('Y-m-d').".log",
      date('Y/m/d H:i:s'). " | " . $dst_email . " | " . $username . " | " . getRealIP() . " | ERROR:\" ". $mail->ErrorInfo ."\"\n",
      FILE_APPEND);
else
   file_put_contents(
      "/var/www/html/herboyd2.hu/public/_MAILLOG/MAIL_".date('Y-m-d').".log",
      date('Y/m/d H:i:s'). " | " . $dst_email . " | " . $username . " | " . getRealIP() . " | Successfully sent!\n",
      FILE_APPEND);
}


//Mail_ForgetPassword('gecimaci2000@gmail.com', "N1*[ʀᴇᴋt] CΛЯЯY KØVΛ", "kova", "83b789b2-084c-4a1f-9268-7c3298b835c0");
?>



