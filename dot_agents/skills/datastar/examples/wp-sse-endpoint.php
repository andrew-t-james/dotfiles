<?php
/**
 * DataStar SSE Endpoint for WordPress
 * ====================================
 *
 * This is a complete example of a WordPress AJAX handler for DataStar SSE.
 * Add this to your plugin/theme and register via admin-ajax or REST API.
 *
 * CRITICAL GOTCHAS HANDLED:
 * - Output buffering disabled (WordPress adds multiple levels!)
 * - Compression disabled
 * - Proper SSE headers
 * - Nonce verification
 * - Signal reading from POST body
 */

class My_DataStar_Handler {

    public function __construct() {
        // Register AJAX handlers (logged in and not logged in)
        add_action('wp_ajax_my_datastar_action', [$this, 'handle_sse']);
        add_action('wp_ajax_nopriv_my_datastar_action', [$this, 'handle_sse']);
    }

    /**
     * Main SSE handler
     */
    public function handle_sse() {
        // Read signals from DataStar request
        $signals = $this->read_signals();

        // Verify nonce (if you're using one in signals)
        $nonce = $signals['nonce'] ?? '';
        if (!wp_verify_nonce($nonce, 'my_datastar_nonce')) {
            $this->send_headers();
            $this->send_error('Invalid security token. Please refresh the page.');
            exit;
        }

        // Send SSE headers (MUST be before any output!)
        $this->send_headers();

        // Process the request based on signals
        $action = $signals['action'] ?? 'default';

        switch ($action) {
            case 'save':
                $this->handle_save($signals);
                break;
            case 'load':
                $this->handle_load($signals);
                break;
            default:
                $this->send_error('Unknown action');
        }

        exit;
    }

    /**
     * Read signals from DataStar request
     */
    private function read_signals(): array {
        if ($_SERVER['REQUEST_METHOD'] === 'GET') {
            $raw = isset($_GET['datastar']) ? $_GET['datastar'] : '{}';
        } else {
            $raw = file_get_contents('php://input');
        }

        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : [];
    }

    /**
     * Send SSE headers - CRITICAL!
     *
     * WordPress adds multiple output buffer levels.
     * We MUST disable ALL of them before sending SSE.
     */
    private function send_headers(): void {
        if (headers_sent()) {
            return;
        }

        // CRITICAL: Disable ALL output buffering
        // WordPress typically adds 2-3 levels!
        while (ob_get_level()) {
            ob_end_clean();
        }

        // Prevent PHP/WordPress from buffering
        set_time_limit(0);
        ignore_user_abort(true);

        // SSE headers
        header('Content-Type: text/event-stream');
        header('Cache-Control: no-cache, no-store, must-revalidate');
        header('Connection: keep-alive');
        header('X-Accel-Buffering: no'); // Nginx

        // CORS if needed
        header('Access-Control-Allow-Origin: *');

        // Disable compression
        ini_set('output_buffering', 'off');
        ini_set('zlib.output_compression', false);

        if (function_exists('apache_setenv')) {
            apache_setenv('no-gzip', '1');
        }
    }

    /**
     * Patch DOM elements
     *
     * @param string $html HTML to patch into DOM
     * @param string|null $selector Optional CSS selector for target
     */
    private function patch_elements(string $html, ?string $selector = null): void {
        echo "event: datastar-patch-elements\n";

        if ($selector) {
            echo "data: selector {$selector}\n";
        }

        // HTML must be on single line (no newlines in data!)
        $html = preg_replace('/\s+/', ' ', trim($html));
        echo "data: elements {$html}\n\n";

        if (ob_get_level()) {
            ob_flush();
        }
        flush();
    }

    /**
     * Patch signals (reactive state)
     *
     * @param array $signals Key-value pairs to merge into signals
     */
    private function patch_signals(array $signals): void {
        echo "event: datastar-patch-signals\n";
        echo "data: signals " . json_encode($signals) . "\n\n";

        if (ob_get_level()) {
            ob_flush();
        }
        flush();
    }

    /**
     * Send error response
     */
    private function send_error(string $message): void {
        $this->patch_elements(
            '<div id="notice" class="notice notice-error"><p>' . esc_html($message) . '</p></div>'
        );
        $this->patch_signals(['loading' => false, 'error' => $message]);
    }

    /**
     * Send success response
     */
    private function send_success(string $message): void {
        // Use timestamp to force animation restart (Gotcha #19)
        $ts = time();
        $this->patch_elements(
            '<div id="notice" class="notice notice-success" data-ts="' . $ts . '"><p>' . esc_html($message) . '</p></div>'
        );
        $this->patch_signals(['loading' => false, 'success' => true]);
    }

    /**
     * Example: Handle save action
     */
    private function handle_save(array $signals): void {
        $value = sanitize_text_field($signals['value'] ?? '');

        if (empty($value)) {
            $this->send_error('Value cannot be empty');
            return;
        }

        // Save to database
        update_option('my_setting', $value);

        // Send success response
        $this->send_success('Settings saved successfully!');

        // Optionally update other parts of the page
        $this->patch_elements(
            '<span id="current-value">' . esc_html($value) . '</span>',
            '#sidebar .value-display' // Optional selector
        );
    }

    /**
     * Example: Handle load action
     */
    private function handle_load(array $signals): void {
        $value = get_option('my_setting', 'default');

        $this->patch_signals([
            'value' => $value,
            'loading' => false,
        ]);

        $this->patch_elements(
            '<span id="current-value">' . esc_html($value) . '</span>'
        );
    }
}

// Initialize
new My_DataStar_Handler();

/*
FRONTEND USAGE EXAMPLE:
=======================

<div data-signals="{
    value: '',
    loading: false,
    success: false,
    error: '',
    nonce: '<?= wp_create_nonce('my_datastar_nonce') ?>',
    action: 'save'
}">
    <input data-bind:value placeholder="Enter value..." />

    <button data-on:click="$action = 'save'; @post('<?= admin_url('admin-ajax.php?action=my_datastar_action') ?>')"
            data-indicator:loading>
        <span data-show="!$loading">Save</span>
        <span data-show="$loading" style="display:none">Saving...</span>
    </button>

    <!-- Notice container - MUST exist for patching! -->
    <div id="notice"></div>

    <!-- Current value display -->
    <p>Current: <span id="current-value">...</span></p>

    <!-- Load on page load -->
    <div data-on:load__window__once="$action = 'load'; @get('<?= admin_url('admin-ajax.php?action=my_datastar_action') ?>')"></div>
</div>
*/
