
var grid_data = [
  { id:"name",  header:"Interval", width:100},
  { id:"file_path",  header:"Location", width:500}
]

//Variables
var home = "http://karl.galileosuite.com:10999";
var d = new Date();
d.setHours(d.getHours() - 1)
var str_date = webix.Date.strToDate("%Y-%m-%d %H:%i");

//functions

var myformat = webix.Date.dateToStr("%Y-%m-%dT%H:%i:%s");

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

  current_url = home.concat("/getdates/", customer, "/", uuid_choice, "/",  start_time, "/", end_time)
    console.log(current_url)
  http_request(current_url, function() {
      console.log(data)
      $$("files").clearAll();
      $$("files").parse(data);
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

var submit = {
    view: "button", label: "Submit", width: 90, click: gen_file_url
}

var files = {
  view:"list",
  id:"files",
  template:"#interval_date#",
  data: "",
  select:true,
  width: 100
};

var intervals = {
  view:"list",
  id:"intervals",
  template:"#interval_date#",
  data: "",
  select:true,
  width: 100
};

var table = {
  view:"datatable",
  id: "table",
  columns: grid_data,
  data: ""
}

var table_gen = function(data="")  {
  var table = {
      view:"datatable",
      columns: grid_data,
      data: data
  }
  return table
}

//webix ui
webix.ui({
  container: "app",
  rows:[
    { cols: [ start_picker, end_picker, customer, uuid, submit ] },
    { cols:[ { header:"Times", width: 200, body: files }, { header:"Interval", width: 150, body: intervals }, table ]}
  ]
}).show();

function arr_diff (a1, a2) {

  var a = [], diff = [];

  for (var i = 0; i < a1.length; i++) {
    a[a1[i]] = true;
  }

  for (var i = 0; i < a2.length; i++) {
    if (a[a2[i]]) {
      delete a[a2[i]];
  } else {
    a[a2[i]] = true;
  }
  }

  for (var k in a) {
    diff.push(k);
  }

  return diff;
}

//events
$$("customer").attachEvent("onchange", function(new_value, old_value){
  http_request(home.concat("/uuid/", new_value), function() {
    $$("uuid").getPopup().getList().clearAll();
    $$("uuid").getPopup().getList().parse(data)
  });
});

i = 0
var cached_tables = [];

//  loading tables from list

$$("interval").attachEvent("onSelectChange", function(id, e, node){;
  var item = this.getItem(id);

  $$("table").clearAll();

  console.log("selected interval " + item.interval_date)
  console.log(cached_tables)
  if (item.interval_date in cached_tables) {
    console.log("loading cached table " + cached_tables[item.interval_date])
    $$("table").parse(cached_tables[item.interval_date])
  } else {
    http_request(home.concat("/gettable/", item.interval, "/", item.id, "/", item.file), function() {
      console.log("loading UNcached table")
      $$("table").parse(data)
      cached_tables[item.interval_date] = data
    })
  }
})
