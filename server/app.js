var uctf = require('./uctf').uCTF;
var express = require('express');
var express_hbs = require('express-handlebars');
var app = express();
var data = 'data';
var port = 8080;

if(process.argv.length > 5) console.log(process.argv[0] + " <data folder> <port> [reset]")
if(process.argv.length >= 3) data = process.argv[2];
if(process.argv.length >= 4) port = parseInt(process.argv[3]);
var ctf = new uctf(data);
if(process.argv.length >= 5 && process.argv[4] == "reset"){ ctf.users = {}; ctf.save(); } 

var solved_helper = function(user, cid){
    if(user.solved[cid])
	return "btn-success";
    return "btn-danger";
};

app.engine('hbs', express_hbs({extname:'hbs', defaultLayout:'main.hbs',helpers:{"solved":solved_helper}}));
app.set('view engine', 'hbs');
app.use('/files', express.static(data+'/files'));
app.get('/new', function(req, res){ res.redirect('/' + ctf.new_user()); });

app.get('/favicon.ico', function(req, res){ res.status(404).send('Not found'); });

app.get('/:id?/', function(req, res){
    res.render('home',{
	"uid":req.params.id,
	"config":ctf.config,
	"user":ctf.users[req.params.id],
	"challenges":ctf.cbc});
});

app.get('/:id/:cid', function(req, res){
    var status = "Unsolved";
    if(req.query.answer) status = ctf.check(req.params.id,req.params.cid,req.query.answer)? "Correct" : "Incorrect";
    else if(ctf.users[req.params.id].solved && ctf.users[req.params.id].solved[req.params.cid]) status = "Solved"
    if(status != "Correct")
	res.render('challenge',{
	    "uid":req.params.id,
	    "solution":ctf.users[req.params.id].solved[req.params.cid],
	    "challenge":ctf.challenges[req.params.cid],
	    "status":status});
    else
	res.redirect("/"+req.params.id);
});

app.listen(port, function(){ console.log('CTF is running on port '+port) });
