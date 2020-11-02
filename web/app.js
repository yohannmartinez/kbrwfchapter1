require('!!file-loader?name=[name].[ext]!./index.html')
require('!!file-loader?name=[name].[ext]!./tuto.webflow/orders.html')
require('!!file-loader?name=[name].[ext]!./tuto.webflow/order.html')

/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')

var orders = [
  { remoteid: "000000189", custom: { customer: { full_name: "TOTO & CIE" }, billing_address: "Some where in the world" }, items: 2 },
  { remoteid: "000000190", custom: { customer: { full_name: "Looney Toons" }, billing_address: "The Warner Bros Company" }, items: 3 },
  { remoteid: "000000191", custom: { customer: { full_name: "Asterix & Obelix" }, billing_address: "Armorique" }, items: 29 },
  { remoteid: "000000192", custom: { customer: { full_name: "Lucky Luke" }, billing_address: "A Cowboy doesn't have an address. Sorry" }, items: 0 },
]

var orders = orders.map(order => (<JSXZ in="orders" sel=".table-line">
  <Z sel=".table-col1">{order.remoteid}</Z>
  <Z sel=".table-col2">{order.custom.customer.full_name}</Z>
  <Z sel=".table-col3">{order.custom.billing_address}</Z>
  <Z sel=".table-col4">{order.items}</Z>
  <Z sel=".table-col5">{"->"}</Z>
  <Z sel=".table-col6">pay</Z>
</JSXZ>))

var Page = createReactClass({
  render: function () {
    return (
      <JSXZ in="orders" sel=".container">
        <Z sel=".table-body">{orders}</Z>
      </JSXZ>
    )
  }
})

ReactDOM.render(<Page />, document.getElementById('root'));

/* required css for our application */
require('./tuto.webflow/css/tuto.webflow.css');