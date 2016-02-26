<?php
$str = " &$%1243";
$i =1;
function next_num($i){
	global $str,$i;
	$l =0;
	while(!ctype_digit(substr($str,$i,1)))
		$i++;
	if(ctype_digit(substr($str,$i,1))){
		$c = $i;
		while(ctype_digit(substr($str,$i,1))){
			$i++;
			$l++;
		}
		$num =  substr($str,$c,$l);
		//required value
		$ans = $num;
		return $num;
	}	
}
$k = next_num(0);
echo $k;
echo " ";
echo $i;
?>