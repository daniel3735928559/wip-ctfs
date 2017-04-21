var submit_flag = function(){
    $.post("/submit",{"answer":$("#answer").val(),"note":$("#note").val()}, function(data){
	console.log(data);
    }, "json");
}
