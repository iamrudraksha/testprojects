//Naveen added comment here
<?php
	$stk = array();
	function push_into_stack($var){
		global $stk;
		if(empty($stk)||$var=="&&"||$var=="||"){
			echo "something is pushed";
			array_push($stk, $var);
		}
		else if($stk[count($stk)-1]=="&&" || $stk[count($stk)-1]=="||" ){
			switch ($stk[count($stk)-1]) {
				case "&&":
					# code...
					array_pop($stk);
					echo  "&& is selected";
					$var = $var&&array_pop($stk);
					push_into_stack($var);
					break;
			
				case "||":
					# code...
					echo "|| is selected";
					array_pop($stk);
					$var = $var||array_pop($stk);
					push_into_stack($var);
					break;
				}
			}
		}
		push_into_stack(false);
		push_into_stack("&&");
		push_into_stack(false);
		$k = array_pop($stk);
		if($k==true){
			echo "wow!!!";
		}
?>
