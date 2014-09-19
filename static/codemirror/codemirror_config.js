$(document).ready(function() {
    var editor = new CodeMirror.fromTextArea("id_code", {
        width: "90%",
        height: "500px",
        mode: "python",
        content: document.getElementById("id_code").value
    });

    $("#id_code").addClass("testclass");
    $("#id_code").css( "border","3px solid red" );
    confirm('jquery().ready done')
});