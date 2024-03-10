async function countClicks() {
    // Retrieve the counter value from local storage or initialize it to 0
    let counter = parseInt(localStorage.getItem('counter')) || 0;

    // Increment the counter each time the page is visited
    counter++;

    // After counter reaches 10, reset it to 1 (to show an ad link every 10 visits)
    if (counter > 10) {
        counter = 1;
    }

    // Save the updated counter value in local storage
    localStorage.setItem('counter', counter);

    return counter;
}

async function setLinkList() {
    let link_list;
    let counter = await countClicks();

    if (counter === 3) {
        link_list = 'https://canefreestyle.com/files/drew_links.txt';
    } else {
        link_list = 'https://canefreestyle.com/files/cane_links.txt';
    }

    return link_list;
}

async function getRandomURL() {
    // Fetch the content of the specified link_list file
    let link_list = await setLinkList();

    try {
        const response = await fetch(link_list);

        if (!response.ok) {
            throw new Error(`Network response was not ok: ${response.status}`);
        }

        const data = await response.text();

        // Select a random URL from the link_list
        const urlsArray = data.trim().split('\n').map(url => url.trim());
        const randomIndex = Math.floor(Math.random() * urlsArray.length);

        random_url = urlsArray[randomIndex].toString();

        return random_url;
    } catch (error) {
        // Display the error in the mainContainer element
        document.getElementById("mainContainer").innerHTML = `Error: ${error.message}`;

        // Return null to indicate an error
        return null; 
    }
}

async function displayRandomURL() {
    let counter = await countClicks();
    let link_list = await setLinkList();
    let randomURL = await getRandomURL();

    if (randomURL) {
        // Display the counter, link list, and random URL
        document.getElementById("mainContainer").innerHTML = `Counter: ${counter}<br>Link List: ${link_list}<br>Random URL: ${randomURL}`;
    }
}

// async function displayRandomURL() {
//     let randomURL = await getRandomURL();

//     if (randomURL) {
//         // Redirect to randomURL
//         window.location.href = randomURL;

//         // document.getElementById("mainContainer").innerHTML = `randomURL: ${randomURL}`;
//     }
// }

displayRandomURL();