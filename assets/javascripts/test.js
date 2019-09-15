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
//variables
var home = "http://karl.galileosuite.com:10999";
var d = new Date();
d.setHours(d.getHours() - 1)
var str_date = webix.Date.strToDate("%Y-%m-%d %H:%i");

//functions
test =  "2019-09-08T02:00:01+00:00"
var myformat = webix.Date.dateToStr("%Y-%m-%dT%H:%i:%s");
console.log(myformat(test))
var epoc_to_date = function(secs) {
  secs = secs * 1000;
  d = new Date(secs);
  return d
}
var gen_file_url = function() {
  var customer = $$("customer").getText();
  var uuid_choice = $$("uuid").getText();
  var start_time = str_date($$("start").getValue()).getTime();
  var end_time = str_date($$("end").getValue()).getTime();

  console.log("customer: ".concat(customer))
  console.log("uuid: ".concat(uuid_choice))
  console.log("start: ".concat(start_time))
  console.log("end: ".concat(end_time))

  current_url = home.concat("/getdates/", customer, "/", uuid_choice, "/",  start_time, "/", end_time)
    console.log(current_url)
  http_request(current_url, function() {
      console.log(data)
      $$("uuid_times").clearAll();
      $$("uuid_times").parse(data);
    }
  )
}


http_request = function(url, callback) {
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
//webix objects

var start_picker = {
    view:"datepicker",
    value: d,
    timepicker:true,
    label:"Start Date",
    id: "start",
    name:"start",
    stringResult:true,
    format:"%d %M %Y at %H:%i",
    width: 275
};

var end_picker   = {
    view:"datepicker",
    value: new Date(),
    timepicker:true,
    label:"End Date",
    name:"end",
    id: "end",
    stringResult:true,
    format:"%d %M %Y at %H:%i",
    width: 275
}
var submit = {
    view: "button", label: "Submit", width: 90, click: gen_file_url
}
var customer = {
  view:"combo", id:"customer", width:275, label:'Customers',
  options:{
    filter:function(item, value){
      if(item.name.toString().toLowerCase().indexOf(value.toLowerCase())===0)
        return true;
        return false;
    },
    body:{
      template:"#name#",
      yCount:10,
      data: customers,
    }
  }
}

var uuid = {
  view:"combo", id:"uuid", width:275, label:'UUIDs',
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

var table = {
    view:"datatable",
    columns: grid_data,
    data: customers
}

var tabview = {
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

var uuid_times = {
    view:"list",
    id:"uuid_times",
    template:"#interval_date#",
    data: "",
    select:true
  };

//webix ui
webix.ui({
  container: "app",
  rows:[
    { cols: [ start_picker, end_picker, customer, uuid, submit ] },
    { cols:[ { header:"Times", width: 300, body: uuid_times  } , table ]}

  ]
}).show();

//events
$$("customer").attachEvent("onchange", function(new_value, old_value){
  http_request(home.concat("/uuid/", new_value), function() {
    $$("uuid").getPopup().getList().clearAll();
    $$("uuid").getPopup().getList().parse(data)
  });
});

$$("uuid_times").attachEvent("onItemClick", function(id, e, node){;
   var item = this.getItem(id);
   http_request(home.concat("/gettable/", item.interval, "/", item.file), function() {
     //process table object here
     console.log(data)
   })
});


