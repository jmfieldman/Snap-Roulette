
/* Buffer module for base64 */
var Buffer = require('buffer').Buffer;

Parse.Cloud.define("submit_snap", function(request, response) {
	
	Parse.Cloud.useMasterKey();
	
	var taker         = request.user;
	var snap_img_data = request.params.snap_image_data;
	var receivers     = request.params.receivers;
	
	/* Taker must be defined */
	if (taker == null) {
		response.error("user is undefined");
	}
	
	/* Must have receivers */
	if (receivers.length == 0) {
		response.error("receivers cannot be empty");
	}
	
	/* No more than 5 */
	if (receivers.length > 5) {
		response.error("Cannot have more than 5 receivers");
	}

	/* Get buffer */
	var buffer = new Buffer(snap_img_data, 'base64');

	/* Sent snap obj */
	var SentSnap = Parse.Object.extend("SentSnap");

	/* Create snap */
	var Snap = Parse.Object.extend("Snap");
	var snap = new Snap();
	
	var file = new Parse.File("snap.png", { base64: snap_img_data });
	
	snap.set("taker", taker);
	snap.set("data", file);
	
	snap.save(null, {
		success: function(snap) {
			
			/* Now we have to make the SnapSent objects */
			var sent_snaps = [];
			
			for (r = 0; r < receivers.length; r++) {
				var robjId = receivers[r];				
				var ruser  = new Parse.User();
				ruser.set("objectId", robjId);
				
				var sentsnap = new SentSnap();
				sentsnap.set("taker", taker);
				sentsnap.set("receiver", ruser);
				sentsnap.set("snap", snap);
				
				sent_snaps.push(sentsnap);				
			}
			
			Parse.Object.saveAll(sent_snaps, {
				success: function(objs) {
					response.success("All good!");
				},
				error: function(error) { 
					response.error("save all snaps error: " + error);
				}
			});
		},
		error: function(snap, error) {
	    	console.error(error.message);
			response.error(error.message);
	  	}
	});
	
});

/*
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
*/