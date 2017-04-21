var fs = require('fs');
var uuid = require('uuid/v4');

var uCTF = function(){
    this.users = JSON.parse(fs.readFileSync('data/users.json','utf-8'));
    this.categories = JSON.parse(fs.readFileSync('data/categories.json','utf-8'));
    this.challenges = [];
    var files = fs.readdirSync('data/challenges/');
    for(var i = 0; i < files.length; i++){
	var d = JSON.parse(fs.readFileSync('data/challenges/'+files[i],'utf-8'));
	d.cid = i;
	this.challenges.push(d);
    }
    this.cbc = {}
    for(var i = 0; i < this.categories.length; i++){
	this.cbc[this.categories[i]] = [];
	for(var j = 0; j < this.challenges.length; j++){
	    if(this.challenges[j].category == this.categories[i]) this.cbc[this.categories[i]].push(this.challenges[j]);
	}
    }
}

uCTF.prototype.save = function(){
    fs.writeFileSync('data/users.json',JSON.stringify(this.users), {"encoding":"utf-8"});
}

uCTF.prototype.new_user = function(){
    var new_uuid = uuid();
    console.log(new_uuid);
    while(this.users[new_uuid]) new_uuid = uuid.v4();
    this.users[new_uuid] = {"solved":{}};
    this.save();
    return new_uuid;
}

uCTF.prototype.check = function(id, cid, answer, note){
    if(this.challenges[cid]['answer'] == answer){
	console.log("CORRECT!");
	this.users[id].solved[cid] = {"answer":answer,"note":note};
	this.save();
	return true;
    }
    return false;
}

module.exports = {"uCTF":uCTF};
