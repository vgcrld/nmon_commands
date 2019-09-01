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

start_picker = { view:"datepicker", timepicker:true, label:"Start Date", name:"start", stringResult:true, format:"%d %M %Y at %H:%i", width: 300 }
end_picker   = { view:"datepicker", timepicker:true, label:"End Date",   name:"end",   stringResult:true, format:"%d %M %Y at %H:%i", width: 300 }
range = {
  view:"daterangepicker", name:"default", label:"Default",
  value:{ start: new Date(), end: webix.Date.add(new Date(), 1, "month") }
}
submit = { view: "button", label: "Submit", width: 100 }
combo = {
  view:"combo", id:"combo1", width:300, label:'Customers',
  name:"fruit1",
  value:1,
  options:{
    body:{
      template:"#name#",
      yCount:10,
      data: customers
    }
  }
}
table = {
    view:"datatable",
    columns: grid_data,
    autoheight:true,
    autowidth:true,
    data: customers
      //{ uid:"0", pid:"1", ppid:"0", c:"0", stime:"1Aug19", tty:"??", time:"32:20.55", cmd:"/sbin/launchd" } ]
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
    { cols: [ start_picker, end_picker, combo, submit ] },
    tabview
  ]
}).show();
