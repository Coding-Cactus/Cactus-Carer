function convert_days(elems) {
	elems.forEach(elem => {
		if (!["Spring", "Dry Soil"].includes(elem.innerText)) {
			if (Number(elem.innerText) === 0) {
				elem.style.color = "var(--highlight)";
			} else {
				elem.style.color = "";
			}
			const date = new Date(new Date().getTime() + Number(elem.innerText)*86400000);
			elem.innerText = date.getDate() + "/" + (date.getMonth()+1) + "/" + date.getFullYear();
		}
	});
}
convert_days(document.querySelectorAll(".next-water"));
convert_days(document.querySelectorAll(".next-feed"));


const input = document.getElementById("new-cactus-name");
const button = document.querySelector("#new-cactus button");
input.addEventListener("input", () => {
	const oldLength = input.value.length;
	let newValue = "";

	for (let i = 0; i < input.value.length; i++) {
		const key = input.value.substring(i, i+1).toLowerCase();

		if (key.charCodeAt(0) > 96 && key.charCodeAt(0) < 123) {
			newValue += key;
		}
	}

	const selectionStart = input.selectionStart;
	const selectionEnd = input.selectionEnd;
	input.value = newValue;
	input.setSelectionRange(selectionStart - (oldLength - newValue.length), selectionEnd - (oldLength - newValue.length));

	if (input.value.length > 0) {
		button.disabled = false;
	} else {
		button.disabled = true;
	}
});

const form = document.querySelector("#new-cactus form");
form.addEventListener("submit", (e) => {
	e.preventDefault();

	fetch(form.action, {
		method: form.method,
		body: new FormData(form)
	})
		.then(r => r.text())
		.then(text => {
			if (text !== "success") {
				form.querySelector(".error").innerText = text;
			} else {
				const div = document.createElement("div");
				div.className = "cactus";

				div.innerHTML = '<div><input type="text" class="cactus-name" name="cactus_name" autocomplete="off" placeholder="Name" required><p class="error"></p></div><div class="next-water">0</div><div class="next-feed">0</div><div><button class="water"><ion-icon name="water-outline"></ion-icon></button><button class="feed"><ion-icon name="restaurant-outline"></ion-icon></button><button class="remove"><ion-icon name="remove-circle-outline"></ion-icon></button></div>';
				
				const input = div.querySelector("input");
				input.value = form.querySelector("input").value;
				input.setAttribute("data-name", input.value);
				form.querySelector("input").value = "";
				form.querySelector("button").disabled = true;
				
				const nextWater = document.querySelectorAll(".next-water")[0];
				if (nextWater == undefined) {
					location.reload();
				} else if (nextWater.innerText === "Dry Soil") {
					div.querySelector(".next-water").innerText = "Dry Soil";
					div.querySelector(".next-feed").innerText = "Spring";
				}
				convert_days(div.querySelectorAll(".next-water"));
				convert_days(div.querySelectorAll(".next-feed"));

				document.getElementById("cacti").appendChild(div);

				waterListener(div.querySelector(".water"));
				feedListener(div.querySelector(".feed"));
				removeListener(div.querySelector(".remove"));
			}
		});
});



document.querySelectorAll(".cactus-name").forEach(input => {
	input.addEventListener("change", () => {
		const newName = input.value;
		const oldName = input.getAttribute("data-name");

		if(newName !== null && newName.length !== 0) {
			const data = new FormData();
			data.append("old_name", oldName);
			data.append("new_name", newName);

			input.disabled = true;
			input.style.color = "#777";

			fetch("/api/changename", {
				method: "POST",
				body: data
			})
				.then(r => r.text())
				.then(text => {
					if (text !== "success") {
						input.nextElementSibling.innerText = text;
					} else {
						input.setAttribute("data-name", newName);
						input.nextElementSibling.innerText = "";
					}
					input.disabled = false;
					input.style.color = "#000";
				});
		}
	});

	input.addEventListener("input", () => {
		const oldLength = input.value.length;
		let newValue = "";

		for (let i = 0; i < input.value.length; i++) {
			const key = input.value.substring(i, i+1).toLowerCase();

			if (key.charCodeAt(0) > 96 && key.charCodeAt(0) < 123) {
				newValue += key;
			}
		}

		const selectionStart = input.selectionStart;
		const selectionEnd = input.selectionEnd;
		input.value = newValue;
		input.setSelectionRange(selectionStart - (oldLength - newValue.length), selectionEnd - (oldLength - newValue.length));
	});
});


function waterListener(button) {
	button.addEventListener("click", () => {
		if (confirm("Are you sure you watered this cactus?")) {
			const data = new FormData();
			data.append("cactus_name", button.parentElement.parentElement.children[0].children[0].value);

			fetch("/api/watercactus", {
				method: "POST",
				body: data
			})
				.then(r => r.json())
				.then(data => {
					if (document.querySelectorAll(".next-feed")[0].innerText !== "Spring") {
						const nextWater = button.parentElement.parentElement.children[1];
						const nextFeed = button.parentElement.parentElement.children[2];
						nextWater.innerText = data["next_water"];
						nextFeed.innerText = data["next_feed"];
						convert_days([nextWater, nextFeed]);
					}
				});
		}
	});
}
document.querySelectorAll(".water").forEach(button => { waterListener(button) });

function feedListener(button) {
	button.addEventListener("click", () => {
		if (confirm("Are you sure you fed this cactus?")) {
			const data = new FormData();
			data.append("cactus_name", button.parentElement.parentElement.children[0].children[0].value);


			fetch("/api/feedcactus", {
				method: "POST",
				body: data
			})
				.then(r => r.json())
				.then(data => {
					if (document.querySelectorAll(".next-feed")[0].innerText !== "Spring") {
						const nextWater = button.parentElement.parentElement.children[1];
						const nextFeed = button.parentElement.parentElement.children[2];
						nextWater.innerText = data["next_water"];
						nextFeed.innerText = data["next_feed"];
						convert_days([nextWater, nextFeed]);
					}
				});
		}
	});
}
document.querySelectorAll(".feed").forEach(button => { feedListener(button) });

function removeListener(button) {
	button.addEventListener("click", () => {
		if (confirm("Are you sure you want to remove this cactus?")) {
			const data = new FormData();
			data.append("cactus_name", button.parentElement.parentElement.children[0].children[0].value);

			button.parentElement.parentElement.remove();

			fetch("/api/removecactus", {
				method: "POST",
				body: data
			});
		}
	});
}
document.querySelectorAll(".remove").forEach(button => { removeListener(button) });