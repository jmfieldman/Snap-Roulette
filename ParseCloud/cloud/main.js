
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
	
	var file = new Parse.File("snap.jpg", { base64: snap_img_data });
	
	snap.set("taker", taker);
	snap.set("data", file);
		
	snap.save(null, {
		success: function(snap) {
	
			taker.increment("snapCount");
			taker.save();
			
			/* Now we have to make the SnapSent objects */
			var sent_snaps = [];
			var rec_users  = [];
			
			/* The users this snap was sent to */
			var sent_to_relation    = snap.relation("sentToUsers");
			//var sent_snaps_relation = snap.relation("sentSnaps");
			
			for (r = 0; r < receivers.length; r++) {
				var robjId = receivers[r];				
				var ruser  = new Parse.User();
				ruser.set("objectId", robjId);
				//rec_users.push(ruser);
				sent_to_relation.add(ruser);
				
				var sentsnap = new SentSnap();
				sentsnap.set("taker", taker);
				sentsnap.set("receiver", ruser);
				sentsnap.set("snap", snap);
				sentsnap.set("heart", false);
				
				sent_snaps.push(sentsnap);				
			}
			
			Parse.Object.saveAll(sent_snaps, {
				success: function(objs) {
										
					for (o = 0; o < objs.length; o++) {
						//sent_snaps_relation.add(objs[o]);
						snap.add("sentSnaps", objs[o]);
					}
					
					snap.save(null, {
						success: function(snap) {
							response.success("All good!");
						},
						error: function(error) { 
							response.error("save sentsnaps for snap error: " + error.message);
						}
					});										
				},
				error: function(error) { 
					response.error("save all snaps error: " + error.message);
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
