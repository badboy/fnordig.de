var storedTheme = localStorage.getItem('theme') || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");

if (storedTheme) {
  document.documentElement.setAttribute('data-theme', storedTheme)

  switch (storedTheme) {
    case "dark":
      document.getElementById("theme-dark").checked = true;
      break;
    case "light":
      document.getElementById("theme-light").checked = true;
      break;
  }
}

let radios = document.querySelectorAll("[name=theme-switcher]");
for (let switcher of radios) {
  switcher.addEventListener("change", (e) => {
    let targetTheme = "light"
    switch (e.target.id) {
      case "theme-dark":
        targetTheme = "dark";
        break;
      case "theme-light":
        targetTheme = "light";
        break;
    }

    console.log(`switched to ${targetTheme}`);
    localStorage.setItem('theme', targetTheme);
  });
}
