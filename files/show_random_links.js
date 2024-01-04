// Define a variable for cane_links
let link_list = '';

// Set counter to 0 and update it on the client side
let counter = 0;

function countClicks() {
    // Each time the user clicks the page, increment the counter by 1
    counter++;

    // After counter reaches 10 reset it to 1 (to show an ad link every 10 clicks)
    if (counter > 10) {
        counter = 1;
    }
}

document.getElementById("Drew").addEventListener("click", function() {
    // Navigate to Drew's page if the small Drew link is clicked
    window.open("drew/index.html", "_blank");
});

document.getElementById("mainContainer").addEventListener("click", function() {
    countClicks();
    setLinkList();
    openRandomURL();
});

function openRandomURL() {
    // Fetch the content of the specified link_list file
    fetch(link_list)
        .then(response => response.text())
        .then(data => {
            // Select a random URL from the link_list
            const urlsArray = data.trim().split('\n').map(url => url.trim());
            const randomIndex = Math.floor(Math.random() * urlsArray.length);
            const randomURL = urlsArray[randomIndex];
 
            // document.getElementById("mainContainer").innerHTML = `randomURL: ${randomURL}`;
            window.open(randomURL, "_blank");
        })
        .catch(error => {
            document.getElementById("mainContainer").innerHTML = `Error: ${error}`;
        });
}

function setLinkList() {
    if (counter === 10) {
        link_list = 'https://canefreestyle.com/files/cane_links.txt';
    } else {
        link_list = 'https://canefreestyle.com/files/cane_links.txt';
    }
}
