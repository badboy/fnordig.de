---
permalink: /search
title: Search
layout: simple.liquid
data:
  route: search
---

<form>
  <p><input id="searchbox" type="search" placeholder="Search fnordig" style="width: 60%"></p>
</form>
<div id="results"></div>

<script>
function debounce(func, wait, immediate) {
  let timeout;
  return function() {
    let context = this, args = arguments;
    let later = () => {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };
    let callNow = immediate && !timeout;
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
    if (callNow) func.apply(context, args);
  };
};

const htmlEscape = (s) => s.replace(
  />/g, '&gt;'
).replace(
  /</g, '&lt;'
).replace(
  /&/g, '&'
).replace(
  /"/g, '&quot;'
).replace(
  /'/g, '&#039;'
);

const highlight = (s) => htmlEscape(s).replace(
  /b4de2a49c8/g, '<b>'
).replace(
  /8c94a2ed4b/g, '</b>'
);

function permalink(link, ts) {
    let d = ts.replace(/ ([-+]....)/, "$1").replace(/ /, "T");
    let date = new Date(d);
    return link.replace(/\{\{ *year *}}/, date.getFullYear().toString().padStart(4, '0')
    ).replace(/\{\{ *month *}}/, (date.getMonth() + 1).toString().padStart(2, '0')
    ).replace(/\{\{ *day *}}/, date.getDate().toString().padStart(2, '0'));
}

function datefmt(ts) {
    let d = ts.replace(/ ([-+]....)/, "$1").replace(/ /, "T");
    let date = new Date(d);

    let year = date.getFullYear().toString().padStart(4, '0');
    let month = (date.getMonth() + 1).toString().padStart(2, '0');
    let day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// Prevent form submission
document.querySelector("form").onsubmit = (e) => e.preventDefault();

// Grab a reference to the <input type="search">
const searchbox = document.getElementById("searchbox");

// Used to avoid race-conditions
let requestInFlight = null;

searchbox.onkeyup = debounce(() => {
  const q = searchbox.value;
  if (!q) { return; }

  // Construct the API URL, using encodeURIComponent() for the parameters
  const url = `https://fnordig.de/_search?search=${encodeURIComponent(q)}`;
  // Unique object used just for race-condition comparison
  let currentRequest = {};
  requestInFlight = currentRequest;
  fetch(url).then(r => r.json()).then(d => {
    if (requestInFlight !== currentRequest) {
      // Avoid race conditions where a slow request returns
      // after a faster one.
      return;
    }
    let results = d.map(r => {
        let link = permalink(r.permalink, r.published_date);
        return `
          <div class="result">
            <h3><a href="${link}">${htmlEscape(r.title)}</a></h3>
            <p><small>${datefmt(r.published_date)}</small></p>
            <p>${highlight(r.snippet)}</p>
          </div>
        `
    }).join("");
    document.getElementById("results").innerHTML = results;
  });
}, 100); // debounce every 100ms
</script>
