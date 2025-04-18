async function fetchCountries() {
  try {
    const response = await fetch("/api/CHCS/");
    if (!response.ok) {
      throw new Error("Network response was not ok: " + response.statusText);
    }
    const countries = await response.json();
    return countries;
  } catch (error) {
    console.error("Error fetching countries:", error);
  }
}

async function populateCountries() {
  const countries = await fetchCountries();
  const countryInput = document.getElementById("country");

  if (countries) {
    const country = countries.find((c) => c.code === userCountryCode); // Use the global variable
    if (country) {
      countryInput.value = country.name; // Display country name
    }
  }
}

document.addEventListener("DOMContentLoaded", populateCountries);
