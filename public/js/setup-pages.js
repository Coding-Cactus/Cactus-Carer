const pages = [
	{
		title: "Adding the skill",
		content: '<p>First you need add the skill to your alexa enabled device. There are 3 ways you can do this:</p><ol><li>Go to <a href="">REMEMBER TO ADD LINK HERE</a> and click "Enable"</li><li>On the Alexa app on your mobile device, go to the "Skills & Games" section and search "Cactus Carer". Then tap the skill and press "Enable Use"</li><li>Say to your Amazon Echo "Alexa, enable Cactus Carer"</li></ol>'
	},

	{
		title: "Adding cacti",
		content: '<p>For cactus carer to look after your cacti, you need to tell it that you have some. You do this by saying "Alexa, tell cactus carer I have a cactus called {name}". You can add as many cacti as you want, there is no limit to how many cactus carer can look after. Make sure you remember which cactus you give what name as that will be how cactus carer identifies them.</p>'
	},

	{
		title: "Caring for cacti",
		content: '<p>Once you\'ve added your cacti, they can start being looked after. There are a number of things you can say to get information regarding caring for you cacti:</p><ul><li>"Alexa, ask cactus carer what do I need to do for my cacti today?"</li><li>"Alexa, ask cactus carer what should I do for {name}?"</li><li>"Alexa, ask cactus carer when is the next cactus to be watered?"</li><li>"Alexa, ask cactus carer when is the next cactus to be fed?"</li></ul>'
	},

	{
		title: "Using the website",
		content: '<p>Everything that can be done with alexa can be done on this website too. To log in to this website you will need your account\'s unique user code. To get this code say "Alexa, ask cactus carer what is my user code?" and alexa will read out your 6 letter user code. Do not share this with anyone as it will give them complete access to your cactus carer account. Once you have this code, click "Log In" bellow.</p>'
	}
]


const buttons = document.querySelectorAll("#setup nav button");
const back = buttons[0];
const forward = buttons[1];

let index = 0;

function change_page(direction) {
	index += direction;
	if (index >= pages.length) {
		location.href = "/login";
	} else {
		if (index < 0) { index = 0 }

		back.style.opacity = "1";
		back.style.pointerEvents = "all";
		forward.children[0].innerText = "Next Step";

		if (index == 0) {
			back.style.opacity = "0";
			back.style.pointerEvents = "none";
		} else if (index == pages.length-1) {
			forward.children[0].innerText = "Log In";
		}

		const contentWrapper = document.getElementById("content-wrapper");
		contentWrapper.style.opacity = "0";
		setTimeout(() => {
			document.getElementById("content").innerHTML = pages[index]["content"];
			document.getElementById("title").innerText = pages[index]["title"];
			contentWrapper.style.opacity = "1";
		}, 300);
	}
}

back.addEventListener("click", () => { change_page(-1) });
forward.addEventListener("click", () => { change_page(1) });