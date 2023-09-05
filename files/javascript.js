// Define a variable for cane_urls
let cane_urls = '';

// Fetch the content of the "cane_urls.txt" file
fetch('files/cane_urls.txt')
  .then(response => response.text())
  .then(data => {
    cane_urls = data;
    initializePage(); // Call a function to initialize the page with the loaded URLs
  })
  .catch(error => {
    console.error('Error loading cane_urls.txt:', error);
  });

// Initialize the page with the loaded URLs
function initializePage() {
  const urlsArray = cane_urls.trim().split('\n').map(url => url.trim());
  const randomLinkElement = document.getElementById("randomLink");
  const currentDateElement = document.getElementById("currentDate");

  // Function to set the href attribute to a random URL
  function openRandomURL() {
    const randomIndex = Math.floor(Math.random() * urlsArray.length);
    const randomURL = urlsArray[randomIndex];
    randomLinkElement.href = randomURL;
  }

  // Function to display the current date in "Y-m-d" format
  function displayCurrentDate() {
    const currentDate = new Date();
    const year = currentDate.getFullYear();
    const month = String(currentDate.getMonth() + 1).padStart(2, '0'); // Months are zero-based
    const day = String(currentDate.getDate()).padStart(2, '0');
    const formattedDate = `${year}-${month}-${day}`;
    currentDateElement.textContent = formattedDate;
  }

  // Display the current date when the page loads
  displayCurrentDate();

  randomLinkElement.addEventListener("click", function(event) {
    event.preventDefault(); // Prevent the default link behavior (navigating to the href)
    openRandomURL(); // Set a new random URL when the link is clicked
    window.open(randomLinkElement.href, "_blank"); // Open the random URL in a new tab
  });
}