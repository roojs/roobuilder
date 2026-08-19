<?php

require_once __DIR__ . '/Token.php';

/**
 * Structure-first scanner. Nests `{ }` / `[ ]` while scanning.
 * Non-structural content is opaque TEXT.
 */
class Vbp_Tokenizer
{
	var $src = '';
	var $len = 0;
	var $i = 0;
	var $stack = array();
	var $root;
	var $flat = array();

	/** One pass: tokenize + nest `{ }` / `[ ]`. Skips `//` and `/*` in the tree. */
	function parseTree($source)
	{
		$this->src = $source;
		$this->len = strlen($source);
		$this->i = 0;
		$this->flat = array();
		$this->root = new Vbp_Token('[]', '');
		$this->stack = array($this->root);
		while ($this->i < $this->len) {
			if ($this->skipSpace()) {
				continue;
			}
			$this->addToken($this->nextToken());
		}
		if (count($this->stack) != 1) {
			die("Unclosed group at end of file\n");
		}
		return $this->root;
	}

	/** Flat token stream (includes `//` / `/*`) — for dump/debug. */
	function tokenize($source)
	{
		$this->parseTree($source);
		return $this->flat;
	}

	function addToken($t)
	{
		$this->flat[] = $t;
		if ($t->kind == '//' || $t->kind == '/*') {
			return;
		}
		$cur = $this->stack[count($this->stack) - 1];
		if ($t->kind == '{') {
			$g = new Vbp_Token('{}', '{');
			$cur->children[] = $g;
			$this->stack[] = $g;
			return;
		}
		if ($t->kind == '[') {
			$g = new Vbp_Token('[]', '[');
			$cur->children[] = $g;
			$this->stack[] = $g;
			return;
		}
		if ($t->kind == '}') {
			if (count($this->stack) < 2) {
				die("Unmatched }\n");
			}
			$g = array_pop($this->stack);
			if ($g->kind != '{}') {
				die("Unmatched }\n");
			}
			return;
		}
		if ($t->kind == ']') {
			if (count($this->stack) < 2) {
				die("Unmatched ]\n");
			}
			$g = array_pop($this->stack);
			if ($g->kind != '[]') {
				die("Unmatched ]\n");
			}
			return;
		}
		$cur->children[] = $t;
	}

	function skipSpace()
	{
		$span = strspn($this->src, " \t\n\r", $this->i);
		if ($span < 1) {
			return false;
		}
		$this->i += $span;
		return true;
	}

	function nextToken()
	{
		$from = $this->i;
		$c = $this->src[$this->i];
		$n = ($this->i + 1 < $this->len) ? $this->src[$this->i + 1] : '';

		if ($c == '/' && $n == '/') {
			return $this->lineComment($from);
		}
		if ($c == '/' && $n == '*') {
			return $this->blockComment($from);
		}
		if ($c == '@' && $n == '"') {
			$this->i++;
			return $this->quotedString('"', $from);
		}
		if ($c == '"' && $n == '"' && $this->i + 2 < $this->len && $this->src[$this->i + 2] == '"') {
			return $this->quotedString('"""', $from);
		}
		if ($c == "'" && $n == "'" && $this->i + 2 < $this->len && $this->src[$this->i + 2] == "'") {
			return $this->quotedString("'''", $from);
		}
		if ($c == '"' || $c == "'") {
			return $this->quotedString($c, $from);
		}

		if (strpos("{}[];,=", $c) !== false) {
			$this->i++;
			return new Vbp_Token($c, $c);
		}

		$this->i += strcspn($this->src, "{}[];,= \t\n\r/\"'", $this->i);
		if ($this->i + 1 < $this->len && $this->src[$this->i] == '[' && $this->src[$this->i + 1] == ']') {
			$this->i += 2;
		}
		if ($this->i < $this->len && $this->src[$this->i] == '?') {
			$this->i++;
		}
		return new Vbp_Token('TEXT', substr($this->src, $from, $this->i - $from));
	}

	function lineComment($from)
	{
		$eol = strpos($this->src, "\n", $this->i);
		$this->i = ($eol === false) ? $this->len : $eol;
		return new Vbp_Token('//', substr($this->src, $from, $this->i - $from));
	}

	function blockComment($from)
	{
		$isDoc = ($this->i + 2 < $this->len && $this->src[$this->i + 2] == '*');
		$this->i += 2;
		if ($isDoc) {
			$this->i++;
		}
		$end = strpos($this->src, "*/", $this->i);
		if ($end !== false) {
			$this->i = $end + 2;
			return new Vbp_Token('/*', substr($this->src, $from, $this->i - $from));
		}
		die("Unterminated comment\n");
	}

	function quotedString($quote, $from)
	{
		$n = strlen($quote);
		$this->i += $n;
		while (true) {
			$pos = strpos($this->src, $quote, $this->i);
			if ($pos === false) {
				die("Unterminated string\n");
			}
			if ($n == 1) {
				$bs = 0;
				$j = $pos - 1;
				while ($j >= $this->i && $this->src[$j] == '\\') {
					$bs++;
					$j--;
				}
				if ($bs % 2 == 1) {
					$this->i = $pos + 1;
					continue;
				}
			}
			$this->i = $pos + $n;
			return new Vbp_Token('TEXT', substr($this->src, $from, $this->i - $from));
		}
	}
}
