document.querySelector("#user ion-icon").addEventListener("click", () => {
	document.getElementById("dropdown").classList.toggle("show");
});

document.querySelector("#navbar select").addEventListener("change", (e) => {
	const data = new FormData();
	data.append("hemisphere", ["north", "south"][e.target.selectedIndex]);

	fetch("/api/changehemisphere", {
		method: "POST",
		body: data
	})
		.then(() => {
			if (location.href.includes("dashboard")) {
				location.reload();
			}
		});
});

document.querySelector("#navbar #delete-all").addEventListener("click", () => {
	if (confirm("Are you sure that you want to delete all the saved data relating to your account?")) {
		fetch("/api/deletedata", {
			method: "POST"
		})
			.then(() => {
				location.href = "/";
			});
		}
});

document.querySelector("#navbar #log-out").addEventListener("click", () => {
	location.href = "/logout";
});