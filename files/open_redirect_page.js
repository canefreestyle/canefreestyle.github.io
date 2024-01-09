document.getElementById("mainContainer").addEventListener("click", function() {
    // Create a new anchor element
    var newLink = document.createElement("a");
    newLink.href = "files/redirect_page.html";
    newLink.target = "_blank";

    // Trigger a click on the new anchor element
    document.body.appendChild(newLink);
    newLink.click();
    document.body.removeChild(newLink);
});