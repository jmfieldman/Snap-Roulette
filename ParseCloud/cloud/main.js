
/* Buffer module for base64 */
var Buffer = require('buffer').Buffer;

function send_push_to_one(user, txt) {
	var query = new Parse.Query(Parse.Installation);
	query.equalTo('user', user);
	Parse.Push.send({ 
		where: query,
		data: {
			alert: txt
		}
	});
}

function send_push_to_all(users, txt) {
	var query = new Parse.Query(Parse.Installation);
	query.containedIn('user', users);
	Parse.Push.send({ 
		where: query,
		data: {
			alert: txt
		}
	});
}


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
			
			var msg = "from " + taker.get('fullname');
			
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
				snap.add("sentToUserArray", ruser);
				rec_users.push(ruser);
				sent_to_relation.add(ruser);
				
				var sentsnap = new SentSnap();
				sentsnap.set("taker", taker);
				sentsnap.set("receiver", ruser);
				sentsnap.set("snap", snap);
				
				sent_snaps.push(sentsnap);				
			}						
			//console.log("about to save snap: " + msg);
			
			Parse.Object.saveAll(sent_snaps, {
				success: function(objs) {
					
					//console.log("snap saved");					
					for (o = 0; o < objs.length; o++) {
						//sent_snaps_relation.add(objs[o]);
						snap.add("sentSnaps", objs[o]);
					}
					
					snap.save(null, {
						success: function(snap) {
							send_push_to_all(rec_users, msg);
							response.success("All good!");
						},
						error: function(error) { 
							response.error("save sentsnaps for snap error: " + error.message + " error: " + error);
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

Parse.Cloud.define("set_emote", function(request, response) {

	Parse.Cloud.useMasterKey();
	
	var user          = request.user;
	var emote_val     = request.params.emote;
	var is_taker      = request.params.isTaker;
	var snapId        = request.params.snapId;
	
	if (is_taker) {
		/* This is for users emoting their own snaps! */
		var Snap = Parse.Object.extend("Snap");
		var query = new Parse.Query(Snap);
		query.include("taker");
		query.get(snapId, {
			success: function(snap) {
				var takerObj = snap.get("taker");
				if (takerObj.objectId == user.objectId) {
					snap.set("emote", emote_val);
					snap.save(null, {
						success: function(snap) {
							response.success("All good!");
						},
						error: function(error) { 
							response.error("save snaps isTaker=1 error: " + error.message);
						}
					});
				} else {
					response.error("snap query isTaker=1 user mismatch: user: " + user.objectId + " taker: " + snap.taker.objectId);
				}
			},
			error: function(object, error) {
				response.error("snap query failed isTaker=1: " + error.message);
			}
		});
	} else {
		/* Setting emote for another user's snap; modify SentSnap */
		var Snap = Parse.Object.extend("Snap");
		var snap = new Snap();
		snap.id = snapId;
		
		var SentSnap = Parse.Object.extend("SentSnap");
		var query = new Parse.Query(SentSnap);
		query.equalTo("snap", snap);
		query.equalTo("receiver", user);
		query.include("snap");
		
		query.first({
		  success: function(object) {
		    	object.set("emote", emote_val);
				object.save(null, {
					success: function(obj) {						
						
						var s = object.get("snap");
						s.save(null, {
							success: function(obj2) {
								response.success("All good!");
							},
							error: function(error) {
								response.error("save snaps isTaker=0 save Snap error: " + error.message);
							}
						})
					},
					error: function(error) {
						response.error("save snaps isTaker=0 save SentSnap error: " + error.message);
					}
				});
		  },
		  error: function(error) {
		    	response.error("snap query failed isTaker=0: " + error.message);
		  }
		});
	}
	

});

/*
Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	
	if (request.user.objectId !== request.object.objectId) {
		response.error("User must be the current user");
	} else {
		response.success();
	}	
});
*/