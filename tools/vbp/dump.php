<?php
/**
 * Dump VBP tokenizer / token tree / structural parse.
 *
 *   php tools/vbp/dump.php tokens docs/sample.vbp
 *   php tools/vbp/dump.php tree docs/sample.vbp
 *   php tools/vbp/dump.php parse docs/sample.vbp
 */

require_once __DIR__ . '/Tokenizer.php';
require_once __DIR__ . '/Parser.php';

if ($argc < 3) {
	fwrite(STDERR, "usage: php tools/vbp/dump.php tokens|tree|parse <file.vbp>\n");
	exit(1);
}

$mode = $argv[1];
$path = $argv[2];
$src = file_get_contents($path);
if ($src === false) {
	fwrite(STDERR, "cannot read $path\n");
	exit(1);
}

$flags = JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE;
$tok = new Vbp_Tokenizer();

if ($mode == 'tokens') {
	$out = array();
	foreach ($tok->tokenize($src) as $t) {
		$out[] = array(
			'kind' => $t->kind,
			'text' => $t->text,
		);
	}
	echo json_encode($out, $flags), "\n";
	exit(0);
}
if ($mode == 'tree') {
	$root = $tok->parseTree($src);
	echo json_encode((array) $root, $flags), "\n";
	exit(0);
}
if ($mode == 'parse') {
	$parser = new Vbp_Parser();
	echo json_encode($parser->parse($src), $flags), "\n";
	exit(0);
}
fwrite(STDERR, "unknown mode $mode\n");
exit(1);
