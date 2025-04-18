let offset = 0;
const limit = 25;

function loadItems() {
  const xhr = new XMLHttpRequest();
  xhr.open("GET", `?action=loadItems&offset=${offset}&limit=${limit}`, true);
  xhr.onload = function () {
    if (this.status === 200) {
      try {
        const items = JSON.parse(this.responseText);
        const tableBody = document.querySelector("#itemsTable tbody");
        items.forEach((item) => {
          const row = document.createElement("tr");
          row.innerHTML = `
                        <td style='text-align: left;'>${item.buytime}</td>
                        <td style='text-align: center;'>${item.buyname}</td>
                        <td style='text-align: right;'>${item.buycost} PrémiumPont</td>
                    `;
          tableBody.appendChild(row);
        });
        offset += items.length;
      } catch (e) {
        console.error("JSON parsing error:", e);
      }
    }
  };
  xhr.send();
}

const scrollableTables = document.querySelectorAll(".scrollable-table");
scrollableTables.forEach((table) => {
  table.addEventListener("mouseenter", function () {
    document.body.classList.add("no-scroll");
  });

  table.addEventListener("mouseleave", function () {
    document.body.classList.remove("no-scroll");
  });

  table.addEventListener("scroll", function () {
    if (this.scrollTop + this.clientHeight >= this.scrollHeight - 10) {
      loadItems();
    }
  });
});

loadItems();
