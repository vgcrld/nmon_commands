
grid_data = []

start_picker = { view:"datepicker", timepicker:true, label:"Start Date", name:"start", stringResult:true, format:"%d %M %Y at %H:%i", width: 500 }
end_picker   = { view:"datepicker", timepicker:true, label:"End Date",   name:"end",   stringResult:true, format:"%d %M %Y at %H:%i", width: 500 }
range = {
  view:"daterangepicker", name:"default", label:"Default",
  value:{ start: new Date(), end: webix.Date.add(new Date(), 1, "month") }
}
submit = { view: "button", label: "Submit", width: 200 }

webix.ui({
  container: "app",
  rows:[
    { cols: [ start_picker, end_picker, submit ] },
    { view: "datatable" }
  ]
});
