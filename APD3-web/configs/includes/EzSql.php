<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/includes/Utils.php");

class EzSql {
    public $dblist = array();
    public $mysqli;

    function __construct($address = "127.0.0.1", $username = "root", $password = "", $database = array("apd3"))
    {
        $this->dblist = array();
        date_default_timezone_set("Europe/Budapest");

        foreach ( $database as $db_name) {
            $tmp_mysqli = mysqli_connect($address, $username, $password, $db_name);
            
            if ($tmp_mysqli->connect_errno)
                error_log('Connection error: ' . $tmp_mysqli->connect_errno);
            else
                array_push($this->dblist, $tmp_mysqli);
        }
        $this->mysqli = $this->dblist[0];     }

    function close()
    {
        foreach ($this->dblist as $db) {
            mysqli_close($db);
        }
    }

    function set_database($dbid)
    {
        $this->mysqli = $this->dblist[$dbid];
    }

    function get_database()
    {
        $i = 0;
        while(true)
        {
            if($this->mysqli == $this->dblist[$i])
                return $i;
            $i++;
        }
    }

    function query($query)
    {
        return mysqli_query($this->mysqli, $query);
    }

    function select($table, $values = null, $where = null, $limit = null)
    {
        $query = "SELECT ";
        if (!empty($values)) {
            $query .= implode(", ", $values);
        } else {
            $query .= "*";
        }
        $query .= " FROM `{$table}`";
        if (!empty($where)) {
            $query .= " WHERE $where";
        }
        if (!empty($limit)) {
            $query .= " LIMIT {$limit}";
        }
        $query .= ";";
        return mysqli_query($this->mysqli, $query);
    }

    function select_row_q($query)
    {
        if ($temp = mysqli_query($this->mysqli, $query)) {
            return mysqli_fetch_array($temp);
        } else {
            return null;
        }
    }

    function select_row($table, $values = null, $where = null, $limit = 1)
    {
        $query = "SELECT ";
        if (!empty($values)) {
            $query .= implode(", ", $values);
        } else {
            $query .= "*";
        }
        $query .= " FROM `{$table}`";
        if (!empty($where)) {
            $query .= " WHERE $where";
        }
        $query .= " LIMIT {$limit}";
        if ($temp = mysqli_query($this->mysqli, $query)) {
            return mysqli_fetch_array($temp);
        } else {
            return null;
        }
    }

    function insert($table, $keys, $values)
    {
                $escaped_values = array_map([$this, 'escape'], $values);
        $query = "INSERT INTO `{$table}`(`";
        $query .= implode("`, `", $keys);
        $query .= "`) VALUES ('" . implode("', '", $escaped_values);
        $query .= "');";
        return mysqli_query($this->mysqli, $query);
    }

    function update($table, $values, $where)
    {
                $escaped_values = array_map([$this, 'escape'], $values);
        $setClause = implode(", ", array_map(function($key, $value) {
            return "`$key` = '$value'";
        }, array_keys($escaped_values), $escaped_values));
    
        $query = "UPDATE `{$table}` SET {$setClause} WHERE {$where};";
        
        return mysqli_query($this->mysqli, $query);
    }

    function delete($table, $where)
    {
        $query = "DELETE FROM `{$table}`";
        $query .= " WHERE $where";
        $query .= ";";
        return mysqli_query($this->mysqli, $query);
    }

        function escape($value) {
        return mysqli_real_escape_string($this->mysqli, $value);
    }


    // New prepare method
    function prepare($query)
    {
        $stmt = $this->mysqli->prepare($query);
        if ($stmt === false) {
            error_log('Prepare failed: ' . htmlspecialchars($this->mysqli->error));
            return false;
        }
        return $stmt;
    }

    // Execute prepared statement with parameters
    function execute($stmt, $types, ...$params)
    {
        // Bind parameters
        $stmt->bind_param($types, ...$params);
        return $stmt->execute();
    }

    // Fetch result from prepared statement
    function fetch($stmt)
    {
        return $stmt->get_result()->fetch_assoc();
    }
}