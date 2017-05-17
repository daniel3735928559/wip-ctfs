# uCTF

Micro CTF server: Quickly get a CTF up and running in 6 easy steps!

Micro CTF server is built on NodeJS and Express in less than 100 lines of Javascript.

## Usage

* Ensure you have NodeJS and npm installed.  

## Running an existing CTF

To run an existing CTF, first (in this directory) run:

```
npm install
```

Then:

```
node app.js [path to CTF root directory]
```

This will run the CTF on port 8080.  If you want a different port, specify it as an optional second argument: 

```
node app.js [path to CTF root directory] [port number]
```

If you want to reset the CTF to have no users, add a third argument (NB: you must also specify the port number in this case): 

```
node app.js [path to CTF root directory] [port number] reset
```

### Examples

To run the example CTF on port 8080, do (from this directory): 

```
node app.js ./data 8080 reset
```

To start a fresh copy of the linux scripting challenges in this repository as a CTF on port 8080, do (from this directory): 

```
node app.js ../challenges/script/linux 8080 reset
```

To run the windows scripting challenges in this repository as a CTF on port 8080, preserving the user data from last time it was run, do (from this directory): 

```
node app.js ../challenges/script/windows 8080
```

## Creating your own CTF

* Create a directory for your CTF with the following files: 

  * `users.json` whose contents should start as `{}`

  * `config.json` whose contents should look like: 

```
{
  "intro":"<Text on the dashboard page of your CTF>",
  "categories":["<category1>","<category2>",...]
}
```

  * `challenges/`.

* Create separate JSON files for each of your challenges (with any filenames) and place them in the `challenges/` folder.  Each of these should be formatted as: 

```
{
  "name":"<challenge name>",
  "category":"<category name>",
  "points":<points>,
  "description":"<description>",
  "files":[<list of files>],
  "links":[<list of links>],
  "answer":"<answer string>"
}

```

* Run `npm install`.

* Run `node app.js <path to CTF directory> <port>`, or, if you'd like to remove all your users and start afresh, run `node app.js <path to CTF directory> <port> reset`
