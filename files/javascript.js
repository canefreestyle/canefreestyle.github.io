// Define a variable for cane_links
let cane_links = '';

// Function to open a random URL in a new tab
function openRandomURL() {
    const urlsArray = cane_links.trim().split('\n').map(url => url.trim());
    const randomIndex = Math.floor(Math.random() * urlsArray.length);
    const randomURL = urlsArray[randomIndex];
    window.open(randomURL, "_blank");
}

// Function to display the current date in "Y-m-d" format
function displayCurrentDate() {
    const currentDate = new Date();
    const year = currentDate.getFullYear();
    const month = String(currentDate.getMonth() + 1).padStart(2, '0'); // Months are zero-based
    const day = String(currentDate.getDate()).padStart(2, '0');
    const formattedDate = `${year}-${month}-${day}`;
    document.getElementById("currentDate").textContent = formattedDate;
}

// Display the current date when the page loads
displayCurrentDate();

// Function to count the lines in cane_links
function countCaneLinks() {
  const urlsArray = cane_links.trim().split('\n').map(url => url.trim());
  const formattedCount = urlsArray.length.toLocaleString(); // Format the count with commas
  document.getElementById("caneLinksCount").textContent = formattedCount;
}

document.getElementById("randomLink").addEventListener("click", function(event) {
    event.preventDefault(); // Prevent the default link behavior (navigating to the href)
    openRandomURL(); // Open a random URL in a new tab when the link is clicked
});

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