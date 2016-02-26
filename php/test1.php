<?php
$stk = array();
push_into_array(true);
push_into_array("&&");
function push_into_array($var){
	global $stk;
	if(empty($stk)){
		array_push($stk,$var);
		echo "pushed into empty";
	}
	else{
		array_push($stk,$var);
		echo "pushed into non empty";
	}
}
?>