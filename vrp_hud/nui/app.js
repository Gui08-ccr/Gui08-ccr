$(document).ready(function(){
	window.addEventListener("message",function(event){
		if (event.data.hud == true){
			$("#hudDisplay").css("display","block");
		}

		if (event.data.hud == false){
			$("#hudDisplay").css("display","none");
		}

		if (event.data.movie == true){
			$("#movieTop").css("display","block");
			$("#movieBottom").css("display","block");
		}

		if (event.data.movie == false){
			$("#movieTop").css("display","none");
			$("#movieBottom").css("display","none");
		}

		$(".infosBack").html("<b>"+ event.data.day +"</b>, <b>"+ event.data.month +"</b>  :  "+ event.data.street);

		if (event.data.talking == true){
			$(".voiceDisplay1").css("background","rgba(255,255,255,0.9)");
			$(".voiceDisplay2").css("background","rgba(255,255,255,0.9)");
			$(".voiceDisplay3").css("background","rgba(255,255,255,0.9)");
		} else {
			$(".voiceDisplay1").css("background","rgba(255,255,255,0.3)");
			$(".voiceDisplay2").css("background","rgba(255,255,255,0.3)");
			$(".voiceDisplay3").css("background","rgba(255,255,255,0.3)");
		}

		if (event.data.voice == 1){
			$(".voiceDisplay1").css("display","none");
			$(".voiceDisplay1").css("margin-top","0");
			$(".voiceDisplay2").css("display","none");
			$(".voiceDisplay2").css("margin-top","0");
			$(".voiceDisplay3").css("display","block");
			$(".voiceDisplay3").css("margin-top","19px");
		}

		if (event.data.voice == 2){
			$(".voiceDisplay1").css("display","none");
			$(".voiceDisplay1").css("margin-top","0");
			$(".voiceDisplay2").css("display","block");
			$(".voiceDisplay2").css("margin-top","10px");
			$(".voiceDisplay3").css("display","block");
			$(".voiceDisplay3").css("margin-top","3px");
		}

		if (event.data.voice == 3){
			$(".voiceDisplay1").css("display","block");
			$(".voiceDisplay1").css("margin-top","1px");
			$(".voiceDisplay2").css("display","block");
			$(".voiceDisplay2").css("margin-top","3px");
			$(".voiceDisplay3").css("display","block");
			$(".voiceDisplay3").css("margin-top","3px");
		}

		if (event.data.health <= 1){
			$(".healthDisplay").css("width","0");
		} else {
			$(".healthDisplay").css("width",event.data.health +"%");
		}

		if (event.data.armour == 0){
			$(".armourBack").css("display","none");
		} else {
			$(".armourBack").css("display","block");
			$(".armourDisplay").css("width",event.data.armour +"%");
		}

		$(".thirstDisplay").css("width",100-event.data.thirst +"%");
		$(".hungerDisplay").css("width",100-event.data.hunger +"%");
		$(".staminaDisplay").css("width",100-event.data.stamina +"%");
		$(".clockBack .hudDisplayText").html(event.data.hour +":"+ event.data.minute);

		if (event.data.car == true){
			var mph = event.data.seatbelt == true ? "<s>KMH</s>":"<b>KMH</b>"
			$("#carDisplay").css("display","block");
			$("#carDisplay").html("<b>F</b>"+ event.data.fuel +"  "+ mph + event.data.speed);
		} else {
			$("#carDisplay").css("display","none");
		}
	})
});