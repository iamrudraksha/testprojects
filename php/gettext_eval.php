<?php
$n=0;
$str = " (n==0 ? (0) : (n==1 ? (1) : (n==2 ? (2) : (n%100>=3&&n%100<=10 ? (3) : (n%100>=11 ? (4) : (5))))))";
$var = 0;
$stk = array();
$i=0;
$ans = 0;
$k=0;
function push_into_stack($var){
	global $stk;
	if(empty($stk)||$var==="&&"||$var==="||"||$stk[count($stk)-1]=="("||$stk[count($stk)-1]==")"){
		array_push($stk, $var);
	}
	else if($stk[count($stk)-1]=="&&" || $stk[count($stk)-1]=="||" ){
			switch ($stk[count($stk)-1]) {
				case "&&":
					array_pop($stk);
					$var = $var&&array_pop($stk);
					push_into_stack($var);
					break;
			
				case "||":
					array_pop($stk);
					$var = $var||array_pop($stk);
					push_into_stack($var);
					break;
			}
	}
}
function nextnum($i){
	global $str,$i;
	$l=0;
	while(!ctype_digit(substr($str,$i,1)))
		$i++;
	if(ctype_digit(substr($str,$i,1))){
		$c = $i;
		while(ctype_digit(substr($str,$i,1))){
			$i++;
			$l++;
		}
		$num =  substr($str,$c,$l);
		if(substr($str,$i,1) === ")")
			$i++;
		//required value
		return $num;
	}	
}
while($i<strlen($str)){
	#skips if blank space occurs
	if(substr($str,$i,1)==' '){
			$i++;
			continue;
	}
	if(substr($str,$i,1)==="n"){
		$i++;
		//required value
		$ans = $n;
	}
	#cheking comparison operator
	if(substr($str,$i,1)=="="||substr($str,$i,1)=="<"||substr($str,$i,1)=="!"||substr($str,$i,1)==">"){
		switch(substr($str,$i,1)){
			case "=":
				$i++;
				if(substr($str,$i,1)=="="){
					$var = $n==nextnum($i);
					$ans = $var;
					push_into_stack($var);
				}
				break;
			case "!":
				$i++;
				$var = $n!=nextnum($i);
				$ans = $var;
				push_into_stack($var);
				break;
			case "<":
				$i++;
				if(ctype_digit(substr($str,$i,1))){
					$var = $n<nextnum($i);
					$ans = $var;
					push_into_stack($var);
				}
				else{
					$var = $n<=nextnum($i);
					$ans = $var;
					push_into_stack($var);
				}
				break;
			case ">":
				$i++;
				if(ctype_digit(substr($str,$i,1))){
					$var = $n>nextnum($i);
					$ans = $var;
					push_into_stack($var);
				}
				else{
					$var = $n>=nextnum($i);
					$ans = $var;
					push_into_stack($var);
				}
				break;
			}
		#$i++;
	}
	##case of modulo and div operators
	if(substr($str,$i,1)=="%"||substr($str, $i,1)=="/"){
		switch(substr($str,$i,1)){
			case "%":
				$i++;
				$n = $n%nextnum($i);
				break;
			case "/":
				$i++;
				$n = $n/nextnum($i);
				break;
		}
	}
	#case of ternary operatorys
	if(substr($str,$i,1)=="?"||substr($str, $i,1)==":"){
		switch(substr($str, $i,1)){
			case "?":
				$temp = nextnum($i);
				if(array_pop($stk)){
					$ans = $temp;
					break 2;
				}
				break;
			case ":":
				$i++;
				continue 2;
		}
	}
	#case of && and ||
	if(substr($str,$i,1)=="&"||substr($str, $i,1)=="|"||substr($str, $i,1)=="("||substr($str, $i,1)==")"){
		switch (substr($str,$i,1)) {
			case "&":
				$i++;
				array_push($stk, "&&");
				$i++;
				break;
			case "|":
				$i++;
				array_push($stk, "||");
				$i++;
				break;
			case "(":
				$i++;
				array_push($stk, "(");
				break;
			case ")":
				$c = 0;
				while($var!=")"){
					$var = array_pop($stk);
				}
				$var = array_pop($stk);
				push_into_stack($var);
				$i++;
				break;
		}
	}
}
echo $ans;
echo "\n";
?>
