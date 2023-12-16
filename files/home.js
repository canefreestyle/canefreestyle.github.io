// Define a variable for cane_links
let cane_links = '';

// Function to open a random URL in a new tab
function openRandomURL() {
    const urlsArray = cane_links.trim().split('\n').map(url => url.trim());
    const randomIndex = Math.floor(Math.random() * urlsArray.length);
    const randomURL = urlsArray[randomIndex];
    window.open(randomURL, "_blank");
}

document.getElementById("Drew").addEventListener("click", function(event) {
    // Prevent the default link behavior (navigating to the href)
    event.preventDefault(); 
    window.open("drew/index.html", "_blank");
});

document.getElementById("mainContainer").addEventListener("click", function() {
    // Open a random URL in a new tab when the link is clicked
    openRandomURL(); 
});

// Function to count the lines in cane_links
function countCaneLinks() {
  const urlsArray = cane_links.trim().split('\n').map(url => url.trim());
  const formattedCount = urlsArray.length.toLocaleString(); 
  document.getElementById("caneLinksCount").textContent = formattedCount;
}

// Fetch the content of the "cane_links.txt" file
fetch('https://canefreestyle.com/files/cane_links.txt')
    .then(response => response.text())
    .then(data => {
        cane_links = data;
        countCaneLinks();
})

.catch(error => {
    console.error('Error loading cane_links.txt:', error);
});