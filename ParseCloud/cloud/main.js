
Parse.Cloud.beforeSave("Snap", function(request, response) {
	
	var user  = request.user;
	var taker = request.object.get("taker");
	
	if (user.objectId !== taker.objectId) {
		response.error("Taker must be the current user");
	} else {
		response.success();
	}	
});


Parse.Cloud.beforeSave("SentSnap", function(request, response) {
	
	var user  = request.user;
	var taker = request.object.get("taker");
	
	if (user.objectId !== taker.objectId) {
		response.error("Taker must be the current user");
	} else {
		response.success();
	}	
});