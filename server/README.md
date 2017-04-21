# uCTF

The world's smallest CTF server

## Usage

* Create separate JSON files for each of your challenges (with any filenames) and place them in `data/challenges/`.

* Create a JSON array of category names and place them in `data/categories.json`.

* Run `npm install`.

* Run `node app.js`

## Challenge format


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
