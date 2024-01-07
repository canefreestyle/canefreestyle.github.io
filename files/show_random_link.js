// Define a variable for cane_links
let link_list = '';
let counter = 0;

document.getElementById("Drew").addEventListener("click", function() {
    // Navigate to Drew's page if the small Drew link is clicked
    window.open("drew/index.html", "_blank");
});

// Add an event listener to run the necessary functions before the user clicks
document.getElementById("mainContainer").addEventListener("click", function() {
    countClicks();
    setLinkList();

    // Fetch the random URL and open it after resolving the promise
    getRandomURL().then(randomURL => {
        openRandomURL(randomURL);
    });
});

function countClicks() {
    // Each time the user clicks the page, increment the counter by 1
    counter++;

    // After counter reaches 10 reset it to 1 (to show an ad link every 10 clicks)
    if (counter > 10) {
        counter = 1;
    }
}

function setLinkList() {
    if (counter === 10) {
        link_list = 'https://canefreestyle.com/files/cane_links.txt';
    } else {
        link_list = 'https://canefreestyle.com/files/cane_links.txt';
    }
}

function getRandomURL() {
    // Fetch the content of the specified link_list file
    return fetch(link_list)
        .then(response => response.text())
        .then(data => {
            // Select a random URL from the link_list
            const urlsArray = data.trim().split('\n').map(url => url.trim());
            const randomIndex = Math.floor(Math.random() * urlsArray.length);
            return urlsArray[randomIndex].toString();
        })
        .catch(error => {
            // Display the error in the mainContainer element
            document.getElementById("mainContainer").innerHTML = `Error: ${error}`;
        });
}

function openRandomURL(randomURL) {
    var windowReference = window.open("about:blank",'_blank');
    windowReference.location = randomURL;
}
