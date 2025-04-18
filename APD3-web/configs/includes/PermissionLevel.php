<?php
include_once($_SERVER['DOCUMENT_ROOT'] . "/configs/ServerList.php");
class PermissionLevel {
    public $AdminLvl = array();
    public $VipLvl = array();
    public $Perm;
    public $anticheat = false;

    public function __construct($anticheat = false)
    {
        global $servers;
        $this->AdminLvl = array_fill(0, sizeof($servers), -1);
        $this->VipLvl = array_fill(0, sizeof($servers), -1);
        $this->anticheat = $anticheat;
    }

    function isAdmin()
    {
        return max($this->AdminLvl);
    }

    function isVip()
    {
        return max($this->VipLvl);
    }

    function GetPerm()
    {
        $adminMax = max($this->AdminLvl);
        $vipMax = max($this->VipLvl);
        if($adminMax == 0)
        {
            if($vipMax == 0)
                $this->Perm = Config::$perms[0];
            else
                $this->Perm = Config::$perms[0]; //$this->Perm = Config::$perms['vip'][$vipMax];
        }
        elseif($adminMax == -1)
            $this->Perm = Config::$perms['admin'][0];
        else
            $this->Perm = Config::$perms['admin'][$adminMax];
            
        return $this->Perm->style;
    }

    function update($keys = array())
    {
        if(empty($keys))
        {
            $sql_user_row = $sql::select_row_q("SELECT * FROM `".Config::$regsystem_table_name."` WHERE `id` = {$this->id} LIMIT 1;");
            $arraykeys = array_keys($sql_user_row);
            for ($i=1; $i < sizeof($arraykeys); $i+=2)
                $this->update_value($arraykeys[$i], $sql_user_row[$arraykeys[$i]]);
        }
        else
        {
            $formated_keys = implode(", ", $keys);
            $sql_user_row = $sql::select_row_q("SELECT {$formated_keys} FROM `".Config::$regsystem_table_name."` WHERE `id` = {$this->id} LIMIT 1;");
            foreach ($variable as $key => $value)
                $this->update_value($value, $sql_user_row[$value]);
        }
    }

    public function update_value($key, $value)
    {
        switch ($key) {
            case 'AdminLvL1': {
                $this->AdminLvl[1] = $value;
                break;
            }
            case 'VipLvL1': {
                $this->VipLvl[1] = $value;
                break;
            }
            case 'VipLvL2': {
                $this->VipLvl[2] = $value;
                break;
            }
            case 'VipLvL3': {
                $this->VipLvl[3] = $value;
                break;
            }
            case 'VipLvL4': {
                $this->VipLvl[4] = $value;
                break;
            }
            case 'VipLvL5': {
                $this->VipLvl[5] = $value;
                break;
            }
            case 'VipLvL6': {
                $this->VipLvl[6] = $value;
                break;
            }
            default:
                return false;
                break;
        }
        return true;
    }
}