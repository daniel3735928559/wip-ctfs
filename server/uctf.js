var fs = require('fs');
var uuid = require('uuid/v4');

var uCTF = function(data){
    this.data = data;
    this.users = JSON.parse(fs.readFileSync(data+'/users.json','utf-8'));
    this.config = JSON.parse(fs.readFileSync(data+'/config.json','utf-8'));
    this.categories = this.config.categories;
    this.challenges = [];
    var files = fs.readdirSync(data+'/challenges/');
    for(var i = 0; i < files.length; i++){
	var d = JSON.parse(fs.readFileSync(data+'/challenges/'+files[i],'utf-8'));
	d.cid = i;
	this.challenges.push(d);
    }
    this.cbc = {}
    for(var i = 0; i < this.categories.length; i++){
	this.cbc[this.categories[i]] = [];
	for(var j = 0; j < this.challenges.length; j++){
	    if(this.challenges[j].category == this.categories[i]) this.cbc[this.categories[i]].push(this.challenges[j]);
	}
	this.cbc[this.categories[i]] = this.cbc[this.categories[i]].sort(function(a1,a2){
	    return a1.points < a2.points ? -1 : (a1.points > a2.points ? 1 : 0);
	});
    }
}

uCTF.prototype.save = function(){
    fs.writeFileSync(this.data+'/users.json',JSON.stringify(this.users), {"encoding":"utf-8"});
}

uCTF.prototype.new_user = function(){
    var new_uuid = uuid();
    while(this.users[new_uuid]) new_uuid = uuid.v4();
    this.users[new_uuid] = {"solved":{}, "points":0};
    this.save();
    return new_uuid;
}

uCTF.prototype.check = function(id, cid, answer){
    if(this.challenges[cid]['answer'] == answer){
	if(!this.users[id].solved[cid]) this.users[id].points += this.challenges[cid].points; 
	this.users[id].solved[cid] = {"answer":answer};
	this.save();
	return true;
    }
    return false;
}

module.exports = {"uCTF":uCTF};
