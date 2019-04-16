<?php


class fsql {
    var $pdo;
    function __construct()
    {
        $this->pdo = new PDO("sqlite:". JDIR . "doc.db");
        $this->create();
    }
    function create()
    {
         $this->pdo->exec("
              CREATE TABLE IF NOT EXISTS node (
                    dtype VARCHAR (16) NOT NULL,
                    name VARCHAR (255) NOT NULL,
                    href VARCHAR (255) NOT NULL,
                    memberOf VARCHAR (255) NOT NULL,
                    
                          
                          ")
        
        
    }
    
    
}
