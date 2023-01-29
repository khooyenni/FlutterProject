<?php

	if(!isset($_POST)){
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
		die();
	}
	
	include_once("dbconnect.php");
	
	$userid = $_POST['userid'];
	$hsname = ucwords(addslashes($_POST['hsname']));
	$hsdesc= ucfirst(addslashes($_POST['hsdesc']));
	$hsprice = $_POST['hsprice'];
	$qty = $_POST['qty'];
	$state = ucwords(addslashes($_POST['state']));
	$local= ucwords(addslashes($_POST['local']));
	$lat = $_POST['lat'];
	$lon = $_POST['lon'];
	$hscontact= $_POST['hscontact'];
	$image1 = $_POST['image1'];
	$image2 = $_POST['image2'];
	$image3 = $_POST['image3'];
	

$sqlinsert = "INSERT INTO `tbl_homestay`(`user_id`, `homestay_name`, `homestay_desc`, `homestay_price`, `homestay_qtyroom`, 
`homestay_contact`, `homestay_state`, `homestay_local`, `homestay_lat`, `homestay_lng`) VALUES ('
$userid','$hsname','$hsdesc','$hsprice','$qty','$hscontact','$state','$local','$lat','$lon')";

try{
		if($conn->query($sqlinsert) === TRUE){
			$decoded_string1 = base64_decode($image1);
			$decoded_string2 = base64_decode($image2);
			$decoded_string3 = base64_decode($image3);
			$filename = mysqli_insert_id($conn);
			$path1 = '../assets/homestayImages/'.$filename.'.1.png';
			$path2 = '../assets/homestayImages/'.$filename.'.2.png';
			$path3 = '../assets/homestayImages/'.$filename.'.3.png';
			file_put_contents($path1, $decoded_string1);
			file_put_contents($path2, $decoded_string2);
			file_put_contents($path3, $decoded_string3);
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}
	catch (Exception $e){
		$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
	}
	$conn->close();
	
	function sendJsonResponse($sentArray){
		header('Content-Type: application/json');
		echo json_encode($sentArray);
	}

?>