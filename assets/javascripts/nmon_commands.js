//zM to close all folds
//probs not needed

//Variables
var home = "http://karl.galileosuite.com:10999/api/v1/customer";

var customer = "";

var cols = [
  { id:"USER"    ,  header:"User"    ,sort:"string"},
  { id:"PID"     ,  header:"PID"     ,sort:"int"},
  { id:"PPID"    ,  header:"PPID"    ,sort:"int"},
  { id:"NLWP"    ,  header:"NLWP"    ,sort:"int"},
  { id:"TIME"    ,  header:"TIME"    ,sort:"string"},
  { id:"ELAPSED" ,  header:"Elapsed" ,sort:"string"},
  { id:"%CPU"    ,  header:"%CPU"    ,sort:"int"},
  { id:"%MEM"    ,  header:"%MEM"    ,sort:"int"},
  { id:"RSS"     ,  header:"RSS"     ,sort:"int"},
  { id:"VSZ"     ,  header:"VSZ"     ,sort:"int"},
  { id:"PAGEIN"  ,  header:"PAGEIN"  ,sort:"int"},
  { id:"COMMAND" ,  header:"Command" ,sort:"string"},
  { id:"ARGS"    ,  header:"ARGS"    ,sort:"string"}
]

var d = new Date();

d.setHours(d.getHours() - 1)

var str_date = webix.Date.strToDate("%Y-%m-%d %H:%i");

var file_to_date = webix.Date.strToDate("%Y-%m-%d-%H-%i-%s");

var myformat = webix.Date.dateToStr("%Y-%m-%d at %H:%i");

var file_date = new RegExp(/\.(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})(\d{2})\.([A-Z]{3})/);
//functions

//convert epoc to date
var epoc_to_date = function(secs) {
  secs = secs * 1000;
  d = new Date(secs);
  return d
}

//get http request
function http_request(url, callback) {
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

// add a key to a hashes in an array
function change_key(arr, from, to) {
  //takes an array of objects and changes each key in each object from -> to
  arr.map(function(o) {
    var value = o[from];
    o[to] = value;
  })
    return arr
};

//webix objects
var start_picker = {
  view:"datepicker", value: d, timepicker:true, label:"Start Date",
  id: "start", name:"start", stringResult:true, format:"%d %M %Y at %H:%i", width: 275
};

var end_picker   = {
  view:"datepicker", value: new Date(), timepicker:true, label:"End Date",
  name:"end", id: "end", stringResult:true, format:"%d %M %Y at %H:%i", width: 275
}

var customer = {
  view:"combo", id:"customer", width:275, label:'Customers',
  options:{
    filter:function(item, value){
      if(item.name.toString().toLowerCase().indexOf(value.toLowerCase())===0)
        return true;
        return false;
    },
    body:{ template:"#name#", yCount:10, data: "" }
  }
}

var uuid = {
  view:"combo", id:"uuid", width:275, label:'UUIDs', value:1,
  options:{
    filter:function(item, value){
      if(item.name.toString().toLowerCase().indexOf(value.toLowerCase())===0)
        return true;
        return false;
    },
    body:{ template:"#name#", yCount:10, data: "" }
  }
}

var submit = {
    view: "button", label: "Submit", width: 90, click: gen_file_url
}

var files = {
  view:"list", id:"files", template:"#name#",
  data: "", select:true, height: 100
};

var table = {
  view:"datatable",
  id: "table",
  columns: cols,
  data: ""
}

//webix ui
webix.ui({
  container: "app",
  rows:[
    { cols: [ start_picker, end_picker, customer, uuid, submit, {}] },
    { cols:[ files ]},
    { cols:[ table ]}
  ]
}).show();


//fetching customer
var customers = [];
http_request(home, function() {
    data.forEach( o => customers.push({name: o, id: o}) )
    $$("customer").getPopup().getList().parse(customers)
})

//getting data for UUID and names
$$("customer").attachEvent("onchange", function(new_value, old_value){
  http_request(home.concat("/", new_value, "/details"), function() {
    $$("uuid").getPopup().getList().clearAll();
    data = change_key(data, "uuid", "id")
    $$("uuid").getPopup().getList().parse(data)
  });
});

// get files list
function gen_file_url() {
  customer = $$("customer").getText();
  var uuid_choice = $$("uuid").getValue();
  var start_time = str_date($$("start").getValue()).getTime();
  var end_time = str_date($$("end").getValue()).getTime();

  current_url = home.concat("/", customer, "/files/", uuid_choice)
  console.log(current_url)
  http_request(current_url, function() {
    //parsing data to pass to list with proper date name and file
    var files = [];
    data.sort().forEach(function(o) {
      var date = file_date.exec(o);
      var zone = date[7]
      date = myformat(file_to_date(date.slice(1,6).join("-"))).concat(" ", zone)
      files.push({name: date, id: o})
    });
    $$("files").clearAll();
    $$("files").parse(files);
  })
}
i = 0
var cached_tables = [];

//  loading tables from list
$$("files").attachEvent("onSelectChange", function(id, e, node){
  var item = this.getItem(id);
  $$("table").clearAll();
  url = home.concat("/", customer, "/psdata?filename=", item.id)
  console.log(url)
  http_request(url, function() {
    console.log("loading uncached table")
    $$("table").parse(data)
  })
})

/*
$$("files").attachEvent("onSelectChange", function(id, e, node){;
  var item = this.getItem(id);
  $$("table").clearAll();

  console.log("selected file  " + item.id)
  //console.log(cached_tables)

  if (item.name in cached_tables) {
    console.log("loading cached table " + item.name)
    $$("table").parse(cached_tables[item.name])
  } else {
    url = home.concat("/", customer, "/psdata?filename=", item.id)
    console.log(url)
    http_request(url, function() {
      console.log("loading uncached table")

      $$("table").parse(data)
      cached_tables[item.name] = data
    })
  }
})
*/

