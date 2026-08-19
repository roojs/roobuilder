<?php
/**
 * One node in the token tree. Groups (`{}` / `[]`) nest via children;
 * everything else is a leaf (`TEXT`, `=`, `;`, …).
 */

class Vbp_Token
{
	var $kind;
	var $text;
	var $children = array();

	function __construct($kind, $text)
	{
		$this->kind = $kind;
		$this->text = $text;
	}

	function isLeafKind($kind)
	{
		return $this->kind == $kind;
	}

	function isIdent($text = null)
	{
		if ($this->kind != 'TEXT') {
			return false;
		}
		if (!preg_match('/^[A-Za-z_][A-Za-z0-9_.-]*(\[\])?\??$/', $this->text)) {
			return false;
		}
		if ($text === null) {
			return true;
		}
		return $this->text == $text;
	}
}
