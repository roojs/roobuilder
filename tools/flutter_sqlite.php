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
                          
                          
                          ")
        
        
    }
    
    
}
