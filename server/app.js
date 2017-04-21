var uctf = require('./uctf').uCTF;
var express = require('express');
var express_hbs = require('express-handlebars');
var app = express();
var ctf = new uctf();

app.engine('hbs', express_hbs({extname:'hbs', defaultLayout:'main.hbs'}));
app.set('view engine', 'hbs');
app.use('/files', express.static('data/files'))
app.get('/', function(req, res){ res.redirect('/' + ctf.new_user()); });

app.get('/:id/', function(req, res){
    res.render('home',{"id":req.params.id, "user":ctf.users[req.params.id], "challenges":ctf.cbc});
});

app.get('/:id/:cid', function(req, res){
    res.render('challenge',ctf.challenges[req.params.cid]);
});

app.listen(8080, function () {
  console.log('CTF is running on port 8080!')
});
