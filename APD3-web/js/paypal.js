const lastLoginName = phpData.lastLoginName;
const userId = phpData.userId;
const itemTitle = phpData.itemTitle;
const itemPrice = phpData.itemPrice;

let paypalButton = document.getElementById("paypal-button-container");
paypalButton.style.pointerEvents = "none";
paypalButton.style.opacity = "0.5";

function validateForm() {
  const form = document.getElementById("payment-form");
  return form.checkValidity();
}

function togglePayPalButton() {
  if (validateForm()) {
    paypalButton.style.pointerEvents = "auto";
    paypalButton.style.opacity = "1";
  } else {
    paypalButton.style.pointerEvents = "none";
    paypalButton.style.opacity = "0.5";
  }
}

document
  .getElementById("address")
  .addEventListener("input", togglePayPalButton);
document.getElementById("city").addEventListener("input", togglePayPalButton);
document
  .getElementById("postal_code")
  .addEventListener("input", togglePayPalButton);
document
  .getElementById("country")
  .addEventListener("change", togglePayPalButton);

togglePayPalButton();

paypal
  .Buttons({
    createOrder: function (data, actions) {
      if (!validateForm()) {
        return false;
      }
      return actions.order.create({
        purchase_units: [
          {
            amount: {
              currency_code: "HUF",
              value: itemPrice,
            },
            description: `Vásárló: ${lastLoginName} - Felhasználói azonosító: #${userId} - PrémiumPont: ${itemTitle} - Ára: ${itemPrice}`,
            shipping: {
              address: {
                address_line_1: document.getElementById("address").value,
                admin_area_2: document.getElementById("city").value,
                postal_code: document.getElementById("postal_code").value,
                country_code: phpData.country,
              },
            },
          },
        ],
      });
    },
    onApprove: function (data, actions) {
      return actions.order.capture().then(function (details) {
        const buyerName =
          details.payer.name.given_name + " " + details.payer.name.surname;
        const country = phpData.country;
        const transactionId = details.id;
        const transactionAmount = parseFloat(
          details.purchase_units[0].amount.value
        );
        const convertedAmount = itemPrice;

        const exchangeRate = convertedAmount / transactionAmount;

        fetch("update_points", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            lastLoginName: lastLoginName,
            userId: userId,
            points: itemTitle,
            price: itemPrice,
            buyerName: buyerName,
            address: document.getElementById("address").value,
            city: document.getElementById("city").value,
            postal_code: document.getElementById("postal_code").value,
            country: country,
            transactionId: transactionId,
            exchangeRate: exchangeRate,
          }),
        })
          .then((response) => response.json())
          .then((data) => {
            if (data.status === "success") {
              showNotification(
                "Sikeres vásárlás! A számlád letöltéséhez kérlek várj 10 másodpercet.",
                "#4CAF50"
              );

              if (data.pdfUrl) {
                setTimeout(() => {
                  const link = document.createElement("a");
                  link.href = data.pdfUrl;
                  link.download = "";

                  document.body.appendChild(link);
                  link.click();
                  document.body.removeChild(link);
                }, 10000);
              }
            } else {
              showNotification("Hiba történt: " + data.message, "red");
            }
          });
        // .catch((error) => {
        //   console.error("Error:", error);
        //  });
      });
    },

    onCancel: function (data) {
      // Log the cancellation to the server
      fetch("update_points", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          userId: userId,
          transactionId: data.orderID,
          points: itemTitle,
          price: itemPrice,
          buyerName: lastLoginName,
          address: document.getElementById("address").value,
          city: document.getElementById("city").value,
          postal_code: document.getElementById("postal_code").value,
          country: phpData.country,
          exchangeRate: 1, // You might want to define how to handle this in a cancelled state
        }),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.status === "error") {
            showNotification("Vásárlás lemondva. " + data.message, "red");
          }
        });
    },

    onError: function (err) {
      // Handle errors
      console.error(err);
      showNotification("Hiba történt a PayPal feldolgozása során.", "red");
    },
    style: {
      layout: "vertical",
      color: "gold",
      shape: "pill",
      height: 35,
      size: "responsive",
      label: "pay",
    },
  })
  .render("#paypal-button-container");
