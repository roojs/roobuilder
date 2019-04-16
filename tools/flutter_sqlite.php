<?php


class fsql {
    var $pdo;
    function __construct()
    {
        $this->pdo = new PDO("sqlite:". TDIR . "doc.db");
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->create();
    }
    function create()
    {
         $this->pdo->exec("
              CREATE TABLE IF NOT EXISTS node (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,

                    href VARCHAR (255) NOT NULL DEFAULT '',
                    name VARCHAR (255) NOT NULL DEFAULT '',
                    type VARCHAR (16) NOT NULL DEFAULT '',
                    overriddenDepth INTEGER NOT NULL DEFAULT '',
                    qualifiedName VARCHAR (255) NOT NULL DEFAULT '',
                    enclosedBy_name VARCHAR (255) NOT NULL DEFAULT '',
                    enclosedBy_type VARCHAR (16) NOT NULL DEFAULT '',
                    -- derived data / html extracted...
                    
                    memberOf VARCHAR (255) NOT NULL DEFAULT '',
                    is_constructor INTEGER NOT NULL DEFAULT 0,
                    is_static INTEGER NOT NULL DEFAULT 0,
                    is_depricated INTEGER NOT NULL DEFAULT 0,
                    example TEXT,
                    desc TEXT,
                    
                    is_fake_namespace  INTEGER NOT NULL DEFAULT 0,
                    is_mixin  INTEGER NOT NULL DEFAULT 0,
                    is_enum  INTEGER NOT NULL DEFAULT 0,
                    is_typedef  INTEGER NOT NULL DEFAULT 0,
                    is_constant  INTEGER NOT NULL DEFAULT 0,
                    is_abstract  INTEGER NOT NULL DEFAULT 0,
                    parent_id  INTEGER NOT NULL DEFAULT 0,
                    
                    extends VARCHAR(255)  NOT NULL DEFAULT ''
                );
                    
        ");
        
        
    }
    
    function lookup($k,$v)
    {
        $s = $this->pdo->prepare("SELECT id FROM node where $k=?");
        $s->execute(array($v));
        $r = $s->fetchAll();
        return $r ? $r[0]['id'] : 0;
    }
    function update($id, $o)
    {
        print_r($o);
        foreach((array) $o as $k=>$v) {
            if (is_a($v,'stdClass')) {
                foreach((array)$v as $ik  => $iv) {
                    $kk[] = $k . '_' . $ik;
                    $vv[] = '?';
                    $vvv[] = $iv;
                    $kv[]="{$k}_{$ik}=?";
                }
                continue;
            }
            $kk[] = $k;
            $vv[] = '?';
            $vvv[] = $v;
            $kv[]="{$k}=?";
        }
        if (!$id) {
            $s = $this->pdo->prepare("INSERT INTO node (".
                implode(',',$kk) . ") VALUES (".
                implode(',',$vv) . ")");
            var_dump($s);
            $s->execute($vvv);
            return;
        }
        $s = $this->pdo->prepare("UPDATE node SET ".
                implode(',',$kv) . " WHERE id = $id");
        $s->execute($vvv);
    }
    
    
    
    
    function fromIndex($o)
    {
        $id = $this->lookup('href', $o->href);
        $this->update($id, $o);
        
    }
    function parseIndex()
    {
        $js = json_decode(file_get_contents(FDIR.'index.json'));
        foreach($js as $o) {
            $sq->fromIndex($o);
        }
    }
    function parse($type)
    {
        $s = $this->pdo->prepare("SELECT * FROM node  WHERE type = ?");
        $s->execute(array($type));
        $res = $s->fetchAll();
        foreach($res as $r) {
            $this->parse{$type}($r);
        }
        
    }
    function parseClass($o)
    {
        print_R($o);exit;
        
    }
    
    
}


define( 'FDIR', '/home/alan/Downloads/flutterdocs/flutter/');
define( 'TDIR', '/home/alan/gitlive/flutter-docs-json/');


$sq = new fsql();
//$sq->parseIndex();
$sq->parse('class');
