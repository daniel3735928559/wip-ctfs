var uctf = require('./uctf').uCTF;
var express = require('express');
var express_hbs = require('express-handlebars');
var app = express();
var ctf = new uctf();

var solved_helper = function(user, cid){
    console.log(user,cid)
    if(user.solved[cid])
	return "btn-success";
    return "btn-danger";
};

app.engine('hbs', express_hbs({extname:'hbs', defaultLayout:'main.hbs',helpers:{"solved":solved_helper}}));
app.set('view engine', 'hbs');
app.use('/files', express.static('data/files'));
app.use('/static', express.static('views/static'));
app.get('/', function(req, res){ res.redirect('/' + ctf.new_user()); });

app.get('/favicon.ico', function(req, res){
    res.status(404).send('Not found');
});

app.get('/:id/', function(req, res){
    res.render('home',{"uid":req.params.id, "user":ctf.users[req.params.id],"challenges":ctf.cbc});
});

app.get('/:id/:cid', function(req, res){
    var result = false;
    if(req.query.answer)
	result = ctf.check(req.params.id,req.params.cid,req.query.answer,req.query.note)?
	"correct":"incorrect";
    console.log("result",result)
    res.render('challenge',{"solution":ctf.users[req.params.id].solved[req.params.cid], "challenge":ctf.challenges[req.params.cid], "result":result});
});

app.listen(8080, function () {
  console.log('CTF is running on port 8080!')
});
