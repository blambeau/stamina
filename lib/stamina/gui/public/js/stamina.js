var tabs, go, editor;
function stamina_init() {
  menu = $("#menu");
  menu.accordion();
  $("#menu a.example").click(function(obj) {
    stamina_load_example(obj.srcElement.pathname);
    return false;
  });

  tabs = $("#center");
  tabs.tabs({ 
    cache: false 
  });

  go   = $("#go");
  go.button();
  go.click(function(){ 
    stamina_go();
    return false;
  });

  editor = ace.edit("editor");
  //editor.setTheme("ace/theme/textmate");
  //editor.setTheme("ace/theme/twilight");
  editor.setTheme("ace/theme/eclipse");
  var RubyMode = require("ace/mode/ruby").Mode;
  editor.getSession().setMode(new RubyMode());
};

function stamina_go() {
  $.ajax({
    type: 'POST',
    url: '/go',
    data: {src: editor.getSession().getValue()},
    contentType: "application/x-www-form-urlencoded",
    success: function(data) {
      stamina_refresh_tabs(data);
    },
    error: function(xhr, ajaxOptions, thrownError){
      stamina_error(xhr.responseText);
    }
  });
};

function stamina_clean_tabs() {
  while (tabs.tabs("length") > 1) {
    tabs.tabs("remove", tabs.tabs("length") - 1);
  };
};

function stamina_refresh_tabs(variables) {
  stamina_clean_tabs();
  $.each(variables, function(i, x){
    tabs.tabs("add", "/image/" + x, x);
  });
  tabs.tabs("select", 1);
};

function stamina_error(text) {
  stamina_clean_tabs();
  tabs.tabs({
    load: function(event, ui){ 
      $("#feedback").html(text);
    }
  });
  tabs.tabs("add", "/feedback.html", "Error");
  tabs.tabs("select", 1);
};

function stamina_load_example(path) {
  stamina_clean_tabs();
  $.get("/examples" + path, function(data){
    editor.getSession().setValue(data);
  });
};
