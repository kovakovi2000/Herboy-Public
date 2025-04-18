<?php

class HunterObfuscator
{
    private $code;
    private $key;

    public function __construct($Code, $html = false)
    {
        if ($html) {
            $Code = $this->cleanHtml($Code);
            $this->code = $this->html2Js($Code);
        } else {
            $Code = $this->cleanJS($Code);
            $this->code = $Code;
        }

        // Generate a random encryption key
        $this->key = bin2hex(random_bytes(16)); // 16-byte key for better security
    }

    private function encryptCode($code)
    {
        // XOR encryption with the generated key
        $encrypted = '';
        for ($i = 0; $i < strlen($code); $i++) {
            $encrypted .= chr(ord($code[$i]) ^ ord($this->key[$i % strlen($this->key)]));
        }
        return base64_encode($encrypted);
    }

    private function addAdvancedAntiDebugging()
    {
        // Advanced anti-debugging features
        return <<<JS
(function() {
    var isDebuggerDetected = function() {
        // Basic detection via timing
        var start = Date.now();
        debugger;
        return (Date.now() - start) > 100;
    };
    
    var preventDebugging = function() {
        if (isDebuggerDetected()) {
            console.error("Debugger detected! Exiting...");
            while (true) {}
        }
    };
    
    // Periodic debugger check
    setInterval(preventDebugging, 500);
    
    // Tamper-proof the script
    Object.freeze(console);
    Object.freeze(Function.prototype.toString);
})();
JS;
    }

    public function Obfuscate()
    {
        // Encrypt the code
        $encryptedCode = $this->encryptCode($this->code);
    
        // Safely encode the encrypted string for embedding
        $encodedEncryptedCode = json_encode($encryptedCode);
    
        // Generate the decryption logic
        $decryptionLogic = <<<JS
    (function() {
        var key = "{$this->key}";
        var encrypted = {$encodedEncryptedCode};
        var decode = function(data, key) {
            var decoded = atob(data);
            var output = '';
            for (var i = 0; i < decoded.length; i++) {
                output += String.fromCharCode(decoded.charCodeAt(i) ^ key.charCodeAt(i % key.length));
            }
            return output;
        };
        eval(decode(encrypted, key));
    })();
    JS;
    
        // Add advanced anti-debugging
        return $this->addAdvancedAntiDebugging() . $decryptionLogic;
    }

    private function cleanHtml($code)
    {
        return preg_replace('/<!--(.|\s)*?-->/', '', $code);
    }

    private function cleanJS($code)
    {
        $pattern = '/(?:(?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:(?<!\:|\\\|\')\/\/.*))/';
        $code = preg_replace($pattern, '', $code);
        $search = array(
            '/\>[^\S ]+/s',     // strip whitespaces after tags, except space
            '/[^\S ]+\</s',     // strip whitespaces before tags, except space
            '/(\s)+/s',         // shorten multiple whitespace sequences
            '/<!--(.|\s)*?-->/' // Remove HTML comments
        );
        $replace = array(
            '>',
            '<',
            '\\1',
            ''
        );
        return preg_replace($search, $replace, $code);
    }

    private function html2Js($code)
    {
        $code = preg_replace('/\s+/', ' ', $code); // Minify HTML
        return "document.write('" . addslashes($code) . "');";
    }
}