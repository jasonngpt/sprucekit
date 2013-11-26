//* removes alerts after 4 seconds */
window.setTimeout(function() {
	$(".alert").fadeTo(4500, 0).slideUp(500, function(){
		$(this).remove();
	});
}, 4000);

function checkEmail() {
	if (document.emailform.email.value === "") {
		alert("Email Address is empty!");
		return false;
	}
	else {
		return true;
	}
}
