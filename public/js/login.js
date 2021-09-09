
const form = document.querySelector("form");
const input = document.querySelector("input");
const button = document.querySelector("button");

window.onload = () => { document.getElementById("login-wrapper").style.transform = ""; }

input.addEventListener("input", () => {
	const oldLength = input.value.length;
	let newValue = "";

	for (let i = 0; i < input.value.length; i++) {
		const key = input.value.substring(i, i+1).toUpperCase();

		if (key.charCodeAt(0) > 64 && key.charCodeAt(0) < 91 && Number(input.getAttribute("maxlength")) > newValue.length) {
			newValue += key;
		}
	}

	const selectionStart = input.selectionStart;
	const selectionEnd = input.selectionEnd;
	input.value = newValue;
	input.setSelectionRange(selectionStart - (oldLength - newValue.length), selectionEnd - (oldLength - newValue.length));

	if (Number(input.getAttribute("maxlength")) === input.value.length) {
		button.disabled = false;
	} else {
		button.disabled = true;
	}
});


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
				document.getElementById("login-wrapper").style.transform = "translateX(100%) translateY(100%)";
				setTimeout(() => {
					window.location.href = "/dashboard";
				}, 1000);
			}
		});
});