# uCTF

Micro CTF server: Get a CTF up and running quickly

## Usage

* Ensure you have NodeJS and npm installed.  

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

## Example

To run the script challenges in this repository as a CTF on port 8080, do: 

```
node app.js ../challenges/scripts/ 8080 reset
```
