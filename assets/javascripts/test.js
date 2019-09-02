grid_data = [
  { id:"uid",   header:"UID",   width:60},
  { id:"pid",   header:"PID",   width:60},
  { id:"ppid",  header:"PPID",  width:60},
  { id:"c",     header:"C",     width:60},
  { id:"stime", header:"STIME", width:120},
  { id:"tty",   header:"TTY",   width:60},
  { id:"time",  header:"TIME" , width:60},
  { id:"cmd",   header:"CMD",   width:500},
]
grid_data = [
  { id:"name",  header:"Customer", width:500}
]
var d = new Date();
d.setHours(d.getHours() - 1)

var http_request = function(url, callback) {
    var Http = new XMLHttpRequest();
    Http.open("GET", url, true);
    Http.send();

    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) {
            data = JSON.parse(Http.response)
            callback(data);
        }
    }
}
start_picker = {
    view:"datepicker",
    value: d,
    timepicker:true,
    label:"Start Date",
    name:"start",
    stringResult:true,
    format:"%d %M %Y at %H:%i",
    width: 275
}
end_picker   = {
    view:"datepicker",
    value: new Date(),
    timepicker:true,
    label:"End Date",
    name:"end",
    stringResult:true,
    format:"%d %M %Y at %H:%i",
    width: 275
}
submit = {
    view: "button", label: "Submit", width: 90,
}
customer = {
  view:"combo", id:"customer", width:200, label:'Customers',
  name:"fruit1",
  value:1,
  options:{
    filter:function(item, value){
      if(item.name.toString().toLowerCase().indexOf(value.toLowerCase())===0)
        return true;
        return false;
    },
    body:{
      template:"#name#",
      yCount:10,
      data: customers
    }
  }
}
uuid = {
  view:"combo", id:"uuid", width:300, label:'Customers',
  value:1,
  options:{
    filter:function(item, value){
      if(item.name.toString().toLowerCase().indexOf(value.toLowerCase())===0)
        return true;
        return false;
    },
    body:{
      template:"#name#",
      yCount:10,
      data: "",
    }
  }
}
table = {
    view:"datatable",
    columns: grid_data,
    autoheight:true,
    autowidth:true,
    data: customers
}
tabview = {
  borderless: true,
  view: "tabview",
  cells: [
  {
    header: "empty",
    body: table
  },
  {
    header: "empty",
    body: {}
  }]
}
webix.ui({
  container: "app",
  rows:[
    { cols: [ start_picker, end_picker, customer, uuid, submit ] },
    tabview
  ]
}).show();

var home = "http://localhost:10888";

$$("customer").attachEvent("onchange", function(new_value, old_value){
  http_request(home.concat("/uuid/", new_value), function() {$$("uuid").getPopup().getList().parse(data)});
})



