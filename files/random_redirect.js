// Declare global variables
let counter;
let link_list;
let randomURL;

async function countClicks() {
    // Retrieve the counter value from local storage or initialize it to 0
    counter = parseInt(localStorage.getItem('counter')) || 0;

    // Increment the counter each time the page is visited
    counter++;

    // After counter reaches 10, reset it to 1 (to show an ad link every 10 visits)
    if (counter > 10) {
        counter = 1;
    }

    // Save the updated counter value in local storage
    localStorage.setItem('counter', counter);
}

async function setLinkList() {
    // Fetch the counter value
    await countClicks();

    // Determine the link list based on the counter value
    if (counter === 3) {
        link_list = 'https://canefreestyle.com/links/drew_links.txt';
    } else {
        link_list = 'https://canefreestyle.com/links/cane_links.txt';
    }
}

async function getRandomURL() {
    // Fetch the link list
    await setLinkList();

    try {
        const response = await fetch(link_list);

        if (!response.ok) {
            throw new Error(`Network response was not ok: ${response.status} ${link_list}`);
        }

        const data = await response.text();

        // Select a random URL from the link_list
        const urlsArray = data.trim().split('\n').map(url => url.trim());
        const randomIndex = Math.floor(Math.random() * urlsArray.length);

        // Set the randomURL value
        randomURL = urlsArray[randomIndex].toString();
    } catch (error) {
        // Display the error in the mainContainer element
        document.getElementById("mainContainer").innerHTML = `Error: ${error.message}`;

        // Reset the randomURL value
        randomURL = null;
    }
}

async function displayRandomURL() {
    // Fetch the random URL
    await getRandomURL();

    if (randomURL) {
        // Redirect to randomURL
        window.location.href = randomURL;
    }

    // if (randomURL) {
    //     // Display the counter, link list, and random URL
    //     document.getElementById("mainContainer").innerHTML = `Click Count: ${counter}<br>Link List: ${link_list}<br>Random URL: ${randomURL}`;
    // }
}

// Call the displayRandomURL function
displayRandomURL();