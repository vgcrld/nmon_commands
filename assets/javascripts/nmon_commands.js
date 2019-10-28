//zM to close all folds
//probs not needed

//Variables

const cols = [
  { id:"time"    ,  header:["Interval"] , sort:"string",  width:90 },
  { id:"USER"    ,  header:["User"    ] , sort:"string",  width:120, },
  { id:"PID"     ,  header:["PID"     ] , sort:"int"   ,  width:80, },
  { id:"PPID"    ,  header:["PPID"    ] , sort:"int"   ,  width:80, },
  { id:"NLWP"    ,  header:["NLWP"    ] , sort:"int"   ,  width:80, },
  { id:"TIME"    ,  header:["TIME"    ] , sort:"string",  width:100, },
  { id:"ELAPSED" ,  header:["Elapsed" ] , sort:"string",  width:120, },
  { id:"%CPU"    ,  header:["%CPU"    ] , sort:"int"   ,  width:100, },
  { id:"%MEM"    ,  header:["%MEM"    ] , sort:"int"   ,  width:80, },
  { id:"RSS"     ,  header:["RSS"     ] , sort:"int"   ,  width:100, },
  { id:"VSZ"     ,  header:["VSZ"     ] , sort:"int"   ,  width:100, },
  { id:"PAGEIN"  ,  header:["PAGEIN"  ] , sort:"int"   ,  width:100, },
  { id:"COMMAND" ,  header:["Command" ] , sort:"string",  width:200, },
  { id:"ARGS"    ,  header:"ARGS"       , sort:"string",  width:1500, }
];

// const default_struc = {
//   "rows":["USER","PID"],
//   "columns":[],
//   "values":[
//     {"name":"TIME","text":"TIME","id":1572125101547,"operation":["count"]},
//     {"name":"%CPU","text":"%CPU","id":1572125101549,"operation":["avr"]},
//     {"name":"%MEM","text":"%MEM","id":1572125101550,"operation":["avr"]},
//     {"name":"VSZ","text":"VSZ","id":1572125101552,"operation":["avr"]},
//     {"name":"PAGEIN","text":"PAGEIN","id":1572125101553,"operation":["avr"]},
//     {"name":"ELAPSED","text":"ELAPSED","id":1572125101548,"operation":["avr"]}
//   ],
// };

const default_struc = {
  filters: [
  ],
  rows: [ "USER" ],
  columns: [ "time" ],
  values:[
    { name: "%CPU", "text": "%CPU", "id": 1572125101549, "operation": ["avr"] }
  ],
};

const structures = [{name:"Default", id:1, structure:default_struc}]

var d = new Date();
d.setHours(d.getHours() - 4)

const str_date = webix.Date.strToDate("%Y-%m-%d %H:%i");

const date_str = webix.Date.dateToStr("%Y-%m-%d %H:%i");

const file_to_date = webix.Date.strToDate("%Y-%m-%d-%H-%i-%s");

const myformat = webix.Date.dateToStr("%Y-%m-%d at %H:%i");

const file_date = new RegExp(/\.(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})(\d{2})\.([A-Z]{3})/);

//functions

//convert epoc to date
var epoc_to_date = function(secs) {
  secs = secs * 1000;
  d = new Date(secs);
  return d
}

// http request
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
    let value = o[from];
    o[to] = value;
  })
    return arr
};

//get stuctures used in console
function get_struct() {
   console.log(JSON.stringify($$("table").getStructure()))
};

//webix objects
let start_picker = {
  view:"datepicker", value: d, timepicker:true, label:"Start Date",
  id: "start", name:"start", stringResult:true, format:"%d %M %Y at %H:%i", width: 275
};

let end_picker  = {
  view:"datepicker", value: new Date(), timepicker:true, label:"End Date",
  name:"end", id: "end", stringResult:true, format:"%d %M %Y at %H:%i", width: 275
}

let customer = {
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

let uuid = {
  view:"combo", id:"uuid", width:255, label:"Name", value:1, labelWidth:50,
  options:{
    filter:function(item, value){
      if(item.name.toString().toLowerCase().indexOf(value.toLowerCase())===0)
        return true;
        return false;
    },
    body:{ template:"#name#", yCount:10, data: "" }
  }
}

let structures_list = {
  view:"list", id:"struct_list", template:"#name#",
  data: structures, select:true, rowHeight:10, height:200
};

let files = {
  multi:true, view:"accordion",
  cols:[
    { header:"Files", width: 200,
      body:{
        rows:[{
            view:"list", id:"files", template:"#name#",
            data: "", select:true, rowHeight:10
          }]
    }}
]};

let table = {
  view: "pivot",
  id: "table",
  columns: cols,
  structure: default_struc
}

//webix ui
webix.ui({
  container: "app",
  rows:[
    { cols: [ start_picker, {width:50}, end_picker, {width:50}, customer,{width:50}, uuid, {width:50}, {}] },
    {height: 10},
    { cols:[files, table]}
  ]
}).show();

//initial customer fetching
const customers = [];
http_request(home, function() {
    data.forEach( o => customers.push({name: o, id: o}) )
    $$("customer").getPopup().getList().parse(customers)
})

//adding avg operation
$$("table").addOperation("avr", function(data) {
      let sum = 0;
      for (let i = 0; i < data.length; i++) {
                if( data[i] )
                  sum += window.parseFloat(data[i], 10);
            }
      return data.length?(sum/data.length):0;
});

//getting data for UUID and names
$$("customer").attachEvent("onchange", function(new_value, old_value){
  $$("uuid").setValue();
  $$("table").clearAll();
  $$("files").clearAll();

  let url = home + "/" + new_value + "/details";
  http_request(url, function() {
    $$("uuid").getPopup().getList().clearAll();
    data = change_key(data, "uuid", "id")
    $$("uuid").getPopup().getList().parse(data)
  });
});

// load file list
$$("start").attachEvent("onchange", function(new_value, old_value){
  let customer = $$("customer").getText();
  let uuid = $$("uuid").getValue();
  let start = str_date(new_value).getTime()/1000;
  let end = str_date($$("end").getValue()).getTime()/1000;

  if (uuid==1) {
    webix.message("Choose a server")
  }else{
    get_list(customer, uuid, start, end)
  }
});
$$("end").attachEvent("onchange", function(new_value, old_value){
  let customer = $$("customer").getText();
  let uuid = $$("uuid").getValue();
  let start = str_date($$("start").getValue()).getTime()/1000;
  let end = str_date($$("end").getValue()).getTime()/1000;

  if (uuid==1) {
    webix.message("choose a server")
  }else{
    get_list(customer, uuid, start, end)
  }
});
$$("uuid").attachEvent("onchange", function(new_value, old_value){
  let customer = $$("customer").getText();
  let uuid = new_value
  let start = str_date($$("start").getValue()).getTime()/1000;
  let end = str_date($$("end").getValue()).getTime()/1000;

  get_list(customer, uuid, start, end)
});

//get list function
function get_list(customer, uuid, start, end) {
  $$("table").clearAll();
  let url = home + "/" + customer + "/files/" + uuid + "?start_time=" + start + "&end_time=" + end;
  console.log(url)

  http_request(url, function() {
    //parsing data to pass to list with proper date name and file
    $$("files").clearAll();
    if (data.length == 0) {
      webix.message("No data in that time range")
    } else {
    let files = [];
    data.sort().forEach(function(o) {
      let date = file_date.exec(o);
      let zone = date[7]
      date = myformat(file_to_date(date.slice(1,6).join("-"))).concat(" ", zone)
      files.push({name: date, id: o})
    });
    $$("files").parse(files);
    }
  });
}

// http request to get and load table
$$("files").attachEvent("onSelectChange", function(id, e, node)  {
  $$("table").clearAll();
  let item = this.getItem(id);
  let customer = $$("customer").getText();
  let url = home + "/" + customer + "/psdata?filename=" + item.id
  console.log(url)
  http_request(url, function() {
    if (data.length == 0) {
      webix.message("File did not return data")
    } else {
      $$("table").parse(data)
      $$("table").$$("data").closeAll();
    }
  })
});

// Not in use
/* used to set structures
$$("struct_list").attachEvent("onSelectChange", function(id, e, node)  {
  console.log("gay")
  let item = this.getItem(id);
  $$("table").setStructure(item.structure)
});
*/
