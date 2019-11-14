<?php
$options = [
    'version' => '6.6.6',
    'static_export_settings' => '6.6.6',
    'rewriteWPPaths' => '1',
    'removeConditionalHeadComments' => '1',
    'removeWPMeta' => '1',
    'removeWPLinks' => '1',
    'removeHTMLComments' => '1',
];
echo serialize( $options );
