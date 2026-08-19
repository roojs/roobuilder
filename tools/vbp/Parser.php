<?php
require_once __DIR__ . '/Token.php';
require_once __DIR__ . '/Tokenizer.php';

/**
 * Structural pass: token tree → minimal tree for Pman_Core_Bjs.
 */
class Vbp_Parser
{
	function parse($source)
	{
		$tok = new Vbp_Tokenizer();
		$root = $tok->parseTree($source);
		return $this->parseFile($root->children);
	}

	function parseFile($nodes)
	{
		$file = (object) array(
			'name' => '',
			'vbp-version' => 1,
			'parent' => '',
			'title' => '',
			'permname' => '',
			'modOrder' => '',
			'tree' => null,
		);
		$i = 0;
		$n = count($nodes);
		while ($i < $n) {
			$cur = $nodes[$i];
			if ($cur->isIdent('using')) {
				$i++;
				while ($i < $n && !$this->isObjectStart($nodes, $i)
					&& !($i + 1 < $n && $nodes[$i]->isIdent() && $nodes[$i + 1]->isLeafKind('='))) {
					$i++;
				}
				continue;
			}
			if ($i + 1 < $n && $cur->isIdent() && $nodes[$i + 1]->isLeafKind('=')) {
				$key = $nodes[$i]->text;
				$i += 2;
				$val = $this->takeHeaderValue($nodes, $i);
				if ($key == 'vbp-version') {
					$file->{'vbp-version'} = is_numeric($val) ? intval($val) : $val;
					continue;
				}
				if (!isset($file->{$key})) {
					continue;
				}
				$file->{$key} = $this->unquote($val);
				continue;
			}
			if ($this->isObjectStart($nodes, $i)) {
				$file->tree = $this->parseObject($nodes, $i, '');
				continue;
			}
			$this->err($cur, 'unexpected file-level token');
		}
		return $file;
	}

	function isObjectStart($nodes, $i)
	{
		if ($i >= count($nodes) || !$nodes[$i]->isIdent()) {
			return false;
		}
		$text = $nodes[$i]->text;
		if ($text == 'using' || $this->isUserKw($text) || $text == 'construct'
			|| $text == 'listeners' || $text == 'methods') {
			return false;
		}
		if ($i + 1 < count($nodes) && $nodes[$i + 1]->kind == '{}') {
			return true;
		}
		if ($i + 2 < count($nodes) && $nodes[$i + 1]->isIdent()
			&& $nodes[$i + 2]->kind == '{}') {
			return true;
		}
		return false;
	}

	function parseObject($nodes, &$i, $propName)
	{
		$type = $nodes[$i]->text;
		$i++;
		$id = '';
		if ($i < count($nodes) && $nodes[$i]->isIdent()) {
			$id = $nodes[$i]->text;
			$i++;
		}
		if ($i >= count($nodes) || $nodes[$i]->kind != '{}') {
			$this->err($nodes[$i - 1], 'expected { after type');
		}
		$body = $nodes[$i];
		$i++;
		$obj = (object) array(
			'prop-type' => $type,
			'prop-name' => $propName != '' ? $propName : null,
			'children' => $id != '' ? array($this->prop('id', $id, '')) : array(),
		);
		$this->fillObject($obj, $body->children);
		return $obj;
	}

	function fillObject($obj, $kids)
	{
		$i = 0;
		$n = count($kids);
		while ($i < $n) {
			$cur = $kids[$i];
			if ($cur->isLeafKind('/*')) {
				$i++;
				continue;
			}
			if ($cur->kind == '[]') {
				foreach ($this->splitComma($cur->children) as $peer) {
					$j = 0;
					$obj->children[] = $this->parseObject($peer, $j, '');
				}
				$i++;
				continue;
			}
			if ($cur->isIdent() && $this->isUserKw($cur->text)) {
				$this->skipValueStatement($kids, $i);
				continue;
			}
			if ($cur->isIdent('construct')) {
				$this->skipKeywordGroup($kids, $i, '{}', 'expected { after construct');
				continue;
			}
			if ($cur->isIdent('listeners')) {
				$this->skipKeywordGroup($kids, $i, '[]', 'expected [ after listeners');
				continue;
			}
			if ($cur->isIdent('methods')) {
				$this->skipKeywordGroup($kids, $i, '[]', 'expected [ after methods');
				continue;
			}
			if ($cur->isIdent('special')) {
				$this->skipValueStatement($kids, $i);
				continue;
			}
			if ($this->isObjectStart($kids, $i)) {
				$child = $this->parseObject($kids, $i, '');
				if ($i < $n && $kids[$i]->isLeafKind(';')) {
					$i++;
				}
				$obj->children[] = $child;
				continue;
			}
			if ($cur->isIdent() && $i + 1 < $n && $kids[$i + 1]->isLeafKind('=')) {
				$obj->children[] = $this->parseAssign($kids, $i);
				continue;
			}
			if ($cur->isIdent() && $i + 1 < $n && $kids[$i + 1]->isLeafKind(';')) {
				$obj->children[] = $this->prop($cur->text, '', '');
				$i += 2;
				continue;
			}
			$this->err($cur, 'unexpected object body token');
		}
	}

	function skipKeywordGroup($nodes, &$i, $kind, $msg)
	{
		$i++;
		if ($i >= count($nodes) || $nodes[$i]->kind != $kind) {
			$this->err($nodes[$i - 1], $msg);
		}
		$i++;
	}

	function skipValueStatement($nodes, &$i)
	{
		$n = count($nodes);
		while ($i < $n && !$nodes[$i]->isLeafKind(';')) {
			$i++;
		}
		if ($i < $n && $nodes[$i]->isLeafKind(';')) {
			$i++;
		}
	}

	function isUserKw($text)
	{
		return $text == 'var' || $text == 'public' || $text == 'private' || $text == 'protected';
	}

	function parseVar($nodes, &$i)
	{
		$i++;
		$from = $i;
		$depth = 0;
		$n = count($nodes);
		while ($i < $n) {
			$cur = $nodes[$i];
			if ($depth == 0 && ($cur->isLeafKind('=') || $cur->isLeafKind(';'))) {
				break;
			}
			if ($cur->kind == 'TEXT') {
				$depth += substr_count($cur->text, '<') - substr_count($cur->text, '>');
			}
			$i++;
		}
		if ($from >= $i) {
			$this->err($nodes[$from - 1], 'expected name after var');
		}
		$nameAt = $i - 1;
		while ($nameAt >= $from && $nodes[$nameAt]->kind != 'TEXT') {
			$nameAt--;
		}
		if ($nameAt < $from) {
			$this->err($nodes[$from], 'expected name after var');
		}
		$type = trim($this->joinNodes($nodes, $from, $nameAt));
		$name = $nodes[$nameAt]->text;
		$val = '';
		if ($i < $n && $nodes[$i]->isLeafKind('=')) {
			$i++;
			$val = $this->takeValue($nodes, $i);
		} elseif ($i < $n && $nodes[$i]->isLeafKind(';')) {
			$i++;
		} else {
			$this->err($nodes[$i - 1], 'expected = or ; after var name');
		}
		return $this->prop($name, $val, $type);
	}

	function parseConstruct($nodes, &$i)
	{
		$i++;
		if ($i >= count($nodes) || $nodes[$i]->kind != '{}') {
			$this->err($nodes[$i - 1], 'expected { after construct');
		}
		$body = $this->joinNodes(array($nodes[$i]));
		$i++;
		return $this->prop('init', $body, '');
	}

	function parseNamedList($obj, $nodes, &$i, $nodeType)
	{
		$i++;
		if ($i >= count($nodes) || $nodes[$i]->kind != '[]') {
			$this->err($nodes[$i - 1], 'expected [ after list keyword');
		}
		$list = $nodes[$i];
		$i++;
		foreach ($this->splitComma($list->children) as $peer) {
			if (count($peer) < 1) {
				continue;
			}
			$j = 0;
			if ($nodeType == 8) {
				if ($peer[$j]->kind != 'TEXT') {
					$this->err($peer[$j], 'expected listener name');
				}
				$name = $peer[$j]->text;
				if (strpos($name, '|') === 0) {
					$name = substr($name, 1);
				}
				$j++;
				$obj->children[] = $this->prop($name, $this->joinNodes($peer, $j), '');
				continue;
			}
			if (!$peer[$j]->isIdent()) {
				$this->err($peer[$j], 'expected method name');
			}
			$type = '';
			$name = $peer[$j]->text;
			$j++;
			if ($j < count($peer) && $peer[$j]->isIdent()) {
				$type = $name;
				$name = $peer[$j]->text;
				$j++;
			}
			$obj->children[] = $this->prop($name, $this->joinNodes($peer, $j), $type);
		}
	}

	function parseAssign($nodes, &$i)
	{
		$name = $nodes[$i]->text;
		$i++;
		if ($i >= count($nodes) || !$nodes[$i]->isLeafKind('=')) {
			$this->err($nodes[$i - 1], 'expected =');
		}
		$i++;
		if ($this->isObjectStart($nodes, $i)) {
			$child = $this->parseObject($nodes, $i, $name);
			if ($i < count($nodes) && $nodes[$i]->isLeafKind(';')) {
				$i++;
			}
			return $child;
		}
		$val = $this->takeValue($nodes, $i);
		return $this->prop($name, $val, '');
	}

	function takeHeaderValue($nodes, &$i)
	{
		$n = count($nodes);
		$from = $i;
		while ($i < $n && !$nodes[$i]->isLeafKind(';')
			&& !($i + 1 < $n && $nodes[$i]->isIdent() && $nodes[$i + 1]->isLeafKind('='))
			&& !$this->isObjectStart($nodes, $i)) {
			$i++;
		}
		if ($from == $i) {
			die("missing header value\n");
		}
		$text = $this->joinNodes($nodes, $from, $i);
		if ($i < $n && $nodes[$i]->isLeafKind(';')) {
			$i++;
		}
		return $text;
	}

	function takeValue($nodes, &$i)
	{
		$n = count($nodes);
		$from = $i;
		$saw_group = false;
		while ($i < $n && !$nodes[$i]->isLeafKind(';')) {
			if ($i > $from && $saw_group && $this->isStmtStart($nodes, $i)) {
				return $this->joinNodes($nodes, $from, $i);
			}
			if ($nodes[$i]->kind == '{}' || $nodes[$i]->kind == '[]') {
				$saw_group = true;
			}
			$i++;
		}
		if ($i >= $n) {
			if ($i > $from) {
				return $this->joinNodes($nodes, $from, $i);
			}
			die("missing ; for value\n");
		}
		$text = $this->joinNodes($nodes, $from, $i);
		$i++;
		return $text;
	}

	function isStmtStart($nodes, $i)
	{
		$cur = $nodes[$i];
		if ($cur->kind == '[]' || $cur->isLeafKind('/*')) {
			return true;
		}
		if (!$cur->isIdent()) {
			return false;
		}
		$text = $cur->text;
		if ($this->isUserKw($text) || $text == 'construct' || $text == 'listeners'
			|| $text == 'methods' || $text == 'special') {
			return true;
		}
		if ($i + 1 < count($nodes) && ($nodes[$i + 1]->isLeafKind('=')
			|| $nodes[$i + 1]->isLeafKind(';')
			|| $nodes[$i + 1]->kind == '{}'
			|| $nodes[$i + 1]->kind == '[]')) {
			return true;
		}
		if ($i + 2 < count($nodes) && $nodes[$i + 1]->isIdent()
			&& $nodes[$i + 2]->kind == '{}') {
			return true;
		}
		return false;
	}

	function splitComma($nodes)
	{
		$peers = array();
		$cur = array();
		foreach ($nodes as $n) {
			if ($n->isLeafKind(',')) {
				if (count($cur) > 0) {
					$peers[] = $cur;
				}
				$cur = array();
				continue;
			}
			$cur[] = $n;
		}
		if (count($cur) > 0) {
			$peers[] = $cur;
		}
		return $peers;
	}

	function joinNodes($nodes, $from = 0, $to = null)
	{
		if ($to === null) {
			$to = count($nodes);
		}
		$out = '';
		for ($i = $from; $i < $to; $i++) {
			$out .= $this->nodeText($nodes[$i]);
		}
		return $out;
	}

	function nodeText($n)
	{
		if ($n->kind != '{}' && $n->kind != '[]') {
			return $n->text;
		}
		$out = '';
		foreach ($n->children as $c) {
			$out .= $this->nodeText($c);
		}
		return $out;
	}

	function unquote($val)
	{
		$s = trim($val);
		if (strlen($s) >= 2 && (($s[0] == '"' && substr($s, -1) == '"')
			|| ($s[0] == "'" && substr($s, -1) == "'"))) {
			return substr($s, 1, -1);
		}
		return $s;
	}

	function prop($name, $val, $type)
	{
		return (object) array(
			'prop-name' => $name,
			'prop-val' => $val != '' ? $val : null,
			'prop-type' => $type != '' ? $type : null,
		);
	}

	function err($n, $msg)
	{
		if ($n->kind != '{}' && $n->kind != '[]') {
			die($msg . ' (' . $n->kind . ' ' . $n->text . ")\n");
		}
		die($msg . ' (' . $n->kind . ")\n");
	}
}
